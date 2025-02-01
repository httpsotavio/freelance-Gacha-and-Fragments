#pragma once

#include <map>

#include "enums.h"

extern const std::map<vocationClass_t, std::map<tier_t, std::map<int, double>>> tierHPBonusData;
extern const std::map<vocationClass_t, std::map<tier_t, std::map<int, double>>> tierATKBonusData;
extern const std::map<vocationClass_t, std::map<tier_t, std::map<int, double>>> tierDEFBonusData;