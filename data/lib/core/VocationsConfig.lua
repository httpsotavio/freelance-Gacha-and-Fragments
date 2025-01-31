VocationsConfig = {
  [1] = {
    name = "Luffy", class = "Fighter", description = "BASTILE É UM TANK FOCADO EM CONTROLE DE GRUPO COM FORTE DANO EM ÁREA.", imageName = "Luffy",
    spells = {
      [1] = {tooltip = "Bastile dá uma espadada no cara", image = "bastile/firstSkill"},
      [2] = {tooltip = "Bastile dá uma girada no cara", image = "bastile/firstSkill"},
    }
  },
  [2] = {
    name = "Luffy2", class = "Specialist", description = "NAMI É UMA TANK FOCADO EM CONTROLE DE GRUPO COM FORTE DANO EM ÁREA.", imageName = "Luffy",
    spells = {
      [1] = {tooltip = "Nami dá uma espadada no cara", image = "bastile/firstSkill"},
      [2] = {tooltip = "Nami dá uma girada no cara", image = "bastile/firstSkill"},
    }
  },  
  [3] = {
    name = "Luffy2", class = "Specialist", description = "NAMI É UMA TANK FOCADO EM CONTROLE DE GRUPO COM FORTE DANO EM ÁREA.", imageName = "Luffy",
    spells = {
      [1] = {tooltip = "Nami dá uma espadada no cara", image = "bastile/firstSkill"},
      [2] = {tooltip = "Nami dá uma girada no cara", image = "bastile/firstSkill"},
    }
  },  
  [4] = {
    name = "Robin", class = "Shooter", description = "ROBIN É UMA TANK FOCADO EM CONTROLE DE GRUPO COM FORTE DANO EM ÁREA.", imageName = "Robin",
    spells = {
      [1] = {tooltip = "Robin dá uma espadada no cara", image = "bastile/firstSkill"},
      [2] = {tooltip = "Robin dá uma girada no cara", image = "bastile/firstSkill"},
    }
  },
  [7] = {
    name = "Robin2", class = "Shooter", description = "ROBIN É UMA TANK FOCADO EM CONTROLE DE GRUPO COM FORTE DANO EM ÁREA.", imageName = "Robin",
    spells = {
      [1] = {tooltip = "Robin dá uma espadada no cara", image = "bastile/firstSkill"},
      [2] = {tooltip = "Robin dá uma girada no cara", image = "bastile/firstSkill"},
    }
  },
}

Rotation = {
  [7] = {chance = 50}
}

TIER_NONE = 1
TIER_BRONZE = 2
TIER_SILVER = 3
TIER_GOLD = 4
TIER_DIAMOND = 5

ENUMTIERS = {
	[1] = TIER_NONE,
	[2] = TIER_BRONZE,
	[3] = TIER_SILVER,
	[4] = TIER_GOLD,
	[5] = TIER_DIAMOND,
}

function getCostToUpgradeStar(currentStar)
  if (currentStar == 1) then
    return {money = 1800, items = {[2160] = 10}}
  end  
  if (currentStar == 2) then
    return {money = 18000, items = {[2160] = 10}}
  end  
  if (currentStar == 3) then
    return {money = 180000, items = {[2160] = 10}}
  end 
  if (currentStar == 4) then
    return {money = 1800000, items = {[2160] = 10}}
  end
  return nil
end

function getFragmentsCostToUpgradeStar(currentStar)
  if (currentStar == 1) then
    return 40
  end  
  if (currentStar == 2) then
    return 80
  end  
  if (currentStar == 3) then
    return 180
  end 
  if (currentStar == 4) then
    return 500
  end
  return nil
end

math.randomseed(os.time())

local Rotation = {
    -- personagens com menor chance, vem em cima na tabela
                      --fragments = {[quantidade] = chance}
    [1] = {chance = 50, fragments = {[20] = 60, [100] = 40}},
    [2] = {chance = 50, fragments = {[20] = 60, [100] = 40}},
    [3] = {chance = 50, fragments = {[20] = 60, [100] = 40}},
    [4] = {chance = 50, fragments = {[20] = 60, [100] = 40}},
    [7] = {chance = 100, fragments = {[20] = 75, [100] = 25}}
}

local function sortIndex(t)
    local candidates = {}
    local lastIndex, lastData

    for i, v in pairs(t) do
        lastIndex, lastData = i, v

        if math.random(1, 100) <= v.chance then
            table.insert(candidates, {index = i, data = v})
        end
    end

    if #candidates == 0 then
        return lastIndex, lastData
    end

    local selected = candidates[math.random(1, #candidates)]
    return selected.index, selected.data
end

local function sortInternalIndex(fragments)
    local totalChance = 0
    for _, chance in pairs(fragments) do
        totalChance = totalChance + chance
    end

    local sort = math.random(1, totalChance)
    local acumulado = 0

    for index, chance in pairs(fragments) do
        acumulado = acumulado + chance
        if sort <= acumulado then
            return index
        end
    end
end

function randomizeVocationInRotation()
    local sortedIndex, data = sortIndex(Rotation)
    if sortedIndex then
        local sortedInternalIndex = sortInternalIndex(data.fragments)
        return sortedIndex, sortedInternalIndex
    end
    return 0, 0
end