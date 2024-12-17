///////////////////////////////////////////////////////////////////
// OpenTibia - an opensource roleplaying game
////////////////////////////////////////////////////////////////////////
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
////////////////////////////////////////////////////////////////////////

#include "otpch.h"

#if defined(WIN32) && defined(CRASH_HANDLER)

#include "tools.h"

#include <windows.h>
#include <winsock2.h>
#include <fstream>

#ifdef _MSC_VER
#pragma warning (push)
#pragma warning (disable:4091) // warning C4091: 'typedef ': ignored on left of '' when no variable is declared
#include <imagehlp.h>
#pragma warning (pop)
#else
#include <imagehlp.h>
#endif

template<typename... Args>
std::string exformat(const std::string& format, const Args&... args)
{
#ifdef _MSC_VER
	int n = _snprintf(nullptr, 0, format.data(), args...);
#else
	int n = snprintf(nullptr, 0, format.data(), args...);
#endif
	assert(n != -1);
	std::string buffer(n + 1, '\0');
#ifdef _MSC_VER
	n = _snprintf(&buffer[0], buffer.size(), format.data(), args...);
#else
	n = snprintf(&buffer[0], buffer.size(), format.data(), args...);
#endif
	assert(n != -1);
	buffer.resize(n);
	return buffer;
}

const char* getExceptionName(DWORD exceptionCode)
{
	switch (exceptionCode) {
		case EXCEPTION_ACCESS_VIOLATION:         return "Access violation";
		case EXCEPTION_DATATYPE_MISALIGNMENT:    return "Datatype misalignment";
		case EXCEPTION_BREAKPOINT:               return "Breakpoint";
		case EXCEPTION_SINGLE_STEP:              return "Single step";
		case EXCEPTION_ARRAY_BOUNDS_EXCEEDED:    return "Array bounds exceeded";
		case EXCEPTION_FLT_DENORMAL_OPERAND:     return "Float denormal operand";
		case EXCEPTION_FLT_DIVIDE_BY_ZERO:       return "Float divide by zero";
		case EXCEPTION_FLT_INEXACT_RESULT:       return "Float inexact result";
		case EXCEPTION_FLT_INVALID_OPERATION:    return "Float invalid operation";
		case EXCEPTION_FLT_OVERFLOW:             return "Float overflow";
		case EXCEPTION_FLT_STACK_CHECK:          return "Float stack check";
		case EXCEPTION_FLT_UNDERFLOW:            return "Float underflow";
		case EXCEPTION_INT_DIVIDE_BY_ZERO:       return "Integer divide by zero";
		case EXCEPTION_INT_OVERFLOW:             return "Integer overflow";
		case EXCEPTION_PRIV_INSTRUCTION:         return "Privileged instruction";
		case EXCEPTION_IN_PAGE_ERROR:            return "In page error";
		case EXCEPTION_ILLEGAL_INSTRUCTION:      return "Illegal instruction";
		case EXCEPTION_NONCONTINUABLE_EXCEPTION: return "Noncontinuable exception";
		case EXCEPTION_STACK_OVERFLOW:           return "Stack overflow";
		case EXCEPTION_INVALID_DISPOSITION:      return "Invalid disposition";
		case EXCEPTION_GUARD_PAGE:               return "Guard page";
		case EXCEPTION_INVALID_HANDLE:           return "Invalid handle";
	}
	return "Unknown exception";
}

void Stacktrace(LPEXCEPTION_POINTERS e, std::ostringstream& ss)
{
	STACKFRAME sf;
	HANDLE process, thread;
	ULONG_PTR dwModBase, Disp;
	BOOL more = FALSE;
	DWORD machineType;
	int count = 0;
	char modname[MAX_PATH];
	char symBuffer[sizeof(IMAGEHLP_SYMBOL) + 255];

	PIMAGEHLP_SYMBOL pSym = (PIMAGEHLP_SYMBOL)symBuffer;

	ZeroMemory(&sf, sizeof(sf));
#ifdef _WIN64
	sf.AddrPC.Offset = e->ContextRecord->Rip;
	sf.AddrStack.Offset = e->ContextRecord->Rsp;
	sf.AddrFrame.Offset = e->ContextRecord->Rbp;
	machineType = IMAGE_FILE_MACHINE_AMD64;
#else
	sf.AddrPC.Offset = e->ContextRecord->Eip;
	sf.AddrStack.Offset = e->ContextRecord->Esp;
	sf.AddrFrame.Offset = e->ContextRecord->Ebp;
	machineType = IMAGE_FILE_MACHINE_I386;
#endif

	sf.AddrPC.Mode = AddrModeFlat;
	sf.AddrStack.Mode = AddrModeFlat;
	sf.AddrFrame.Mode = AddrModeFlat;

	process = GetCurrentProcess();
	thread = GetCurrentThread();

	while (true) {
		more = StackWalk(machineType, process, thread, &sf, e->ContextRecord, nullptr, SymFunctionTableAccess, SymGetModuleBase, nullptr);
		if (!more || sf.AddrFrame.Offset == 0) {
			break;
		}

		dwModBase = SymGetModuleBase(process, sf.AddrPC.Offset);
		if (dwModBase) {
			GetModuleFileName((HINSTANCE)dwModBase, (LPWSTR)modname, MAX_PATH);
		} else {
			strcpy(modname, "Unknown");
		}

		Disp = 0;
		pSym->SizeOfStruct = sizeof(symBuffer);
		pSym->MaxNameLength = 254;

		if (SymGetSymFromAddr(process, sf.AddrPC.Offset, &Disp, pSym)) {
			ss << exformat("    %d: %s(%s+%#0lx) [0x%016lX]\n", count, modname, pSym->Name, Disp, sf.AddrPC.Offset);
		} else {
			ss << exformat("    %d: %s [0x%016lX]\n", count, modname, sf.AddrPC.Offset);
		}
		++count;
	}
	GlobalFree(pSym);
}

LONG CALLBACK ExceptionHandler(LPEXCEPTION_POINTERS e)
{
	// generate crash report
	SymInitialize(GetCurrentProcess(), nullptr, TRUE);

	std::ostringstream ss;
	ss << "== application crashed\n";
	ss << exformat("crash date: %s\n", formatDate(time(nullptr)));
	ss << exformat("exception: %s (0x%08lx)\n", getExceptionName(e->ExceptionRecord->ExceptionCode), e->ExceptionRecord->ExceptionCode);
	ss << exformat("exception address: 0x%08lx\n", (size_t)e->ExceptionRecord->ExceptionAddress);
	ss << exformat("  backtrace:\n");

	Stacktrace(e, ss);
	ss << "\n";
	SymCleanup(GetCurrentProcess());

	// print in stdout
	std::cout << ss.str();

	// write stacktrace to crashreport.log
	char dir[MAX_PATH];
	GetCurrentDirectory(sizeof(dir) - 1, (LPWSTR)dir);
	const std::string fileName = exformat("%s\\crashreport.log", dir);

	std::ofstream fout(fileName.c_str(), std::ios::out | std::ios::app);
	if (fout.is_open() && fout.good()) {
		fout << ss.str();
		fout.close();
		std::cout << exformat("Crash report saved to file %s", fileName);
	} else {
		std::cout << "Failed to save crash report!";
	}

	// inform the user
	/*
	const std::string msg = utils::format(
		"The application has crashed.\n\n"
		"A crash report has been written to:\n"
		"%s", fileName.data());
	MessageBox(nullptr, msg.data(), "Application crashed", 0);
	*/

	// this seems to silently close the application
	//return EXCEPTION_EXECUTE_HANDLER;

	// this triggers the microsoft "application has crashed" error dialog
	//return EXCEPTION_CONTINUE_SEARCH;
	return EXCEPTION_EXECUTE_HANDLER;
}

void installCrashHandler()
{
	SetUnhandledExceptionFilter(ExceptionHandler);
}

#endif
