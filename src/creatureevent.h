/**
 * The Forgotten Server - a free and open-source MMORPG server emulator
 * Copyright (C) 2016  Mark Samman <mark.samman@gmail.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

#ifndef FS_CREATUREEVENT_H_73FCAF4608CB41399D53C919316646A9
#define FS_CREATUREEVENT_H_73FCAF4608CB41399D53C919316646A9

#include "luascript.h"
#include "baseevents.h"
#include "enums.h"

enum CreatureEventType_t {
	CREATURE_EVENT_NONE,
	CREATURE_EVENT_LOGIN,
	CREATURE_EVENT_LOGOUT,
	CREATURE_EVENT_THINK,
	CREATURE_EVENT_PREPAREDEATH,
	CREATURE_EVENT_DEATH,
	CREATURE_EVENT_KILL,
	CREATURE_EVENT_ADVANCE,
	CREATURE_EVENT_MODALWINDOW,
	CREATURE_EVENT_TEXTEDIT,
	CREATURE_EVENT_HEALTHCHANGE,
	CREATURE_EVENT_MANACHANGE,
	CREATURE_EVENT_EXTENDED_OPCODE, // otclient additional network opcodes
	CREATURE_EVENT_EQUIP,
	CREATURE_EVENT_UNEQUIP
};

enum AutoRegister_t : uint8_t {
	AUTOREGISTER_NONE,
	AUTOREGISTER_PLAYERS,
	AUTOREGISTER_MONSTERS,
	AUTOREGISTER_ALL
};

class CreatureEvent;

class CreatureEvents final : public BaseEvents
{
	typedef std::map<std::string, CreatureEvent*> CreatureEventList;

	public:
		CreatureEvents();
		~CreatureEvents();

		// non-copyable
		CreatureEvents(const CreatureEvents&) = delete;
		CreatureEvents& operator=(const CreatureEvents&) = delete;

		// global events
		bool playerLogin(Player* player) const;
		bool playerLogout(Player* player) const;
		bool playerAdvance(Player* player, skills_t, uint32_t, uint32_t);

		CreatureEvent* getEventByName(const std::string& name, bool forceLoaded = true);

		const CreatureEventList& getEvents() {
			return creatureEvents;
		}

	protected:
		LuaScriptInterface& getScriptInterface() final;
		std::string getScriptBaseName() const final;
		Event* getEvent(const std::string& nodeName) final;
		bool registerEvent(Event* event, const pugi::xml_node& node) final;
		void clear() final;

		//creature events
		CreatureEventList creatureEvents;

		LuaScriptInterface scriptInterface;
};

class CreatureEvent final : public Event
{
	public:
		explicit CreatureEvent(LuaScriptInterface* interface);

		bool configureEvent(const pugi::xml_node& node) final;

		CreatureEventType_t getEventType() const {
			return type;
		}
		const std::string& getName() const {
			return eventName;
		}
		bool isLoaded() const {
			return loaded;
		}

		AutoRegister_t getAutoRegister() {
			return autoRegister;
		}

		void clearEvent();
		void copyEvent(CreatureEvent* creatureEvent);

		//scripting
		bool executeOnLogin(Player* player);
		bool executeOnLogout(Player* player);
		bool executeOnThink(Creature* creature, uint32_t interval);
		bool executeOnPrepareDeath(Creature* creature, Creature* killer);
		bool executeOnDeath(Creature* creature, Item* corpse, Creature* killer, Creature* mostDamageKiller, bool lastHitUnjustified, bool mostDamageUnjustified);
		void executeOnKill(Creature* creature, Creature* target);
		bool executeAdvance(Player* player, skills_t, uint32_t, uint32_t);
		void executeModalWindow(Player* player, uint32_t modalWindowId, uint8_t buttonId, uint8_t choiceId);
		bool executeTextEdit(Player* player, Item* item, const std::string& text);
		void executeHealthChange(Creature* creature, Creature* attacker, CombatDamage& damage, bool inherited);
		void executeManaChange(Creature* creature, Creature* attacker, int32_t& manaChange, CombatOrigin origin, bool inherited);
		void executeExtendedOpcode(Player* player, uint8_t opcode, const std::string& buffer);
		void executeEquip(Player* player, uint8_t slot, Item* item, bool isLogInOut);
		//

	protected:
		std::string getScriptEventName() const final;

		std::string eventName;
		CreatureEventType_t type;
		AutoRegister_t autoRegister = AUTOREGISTER_NONE;
		bool loaded;
};

#endif
