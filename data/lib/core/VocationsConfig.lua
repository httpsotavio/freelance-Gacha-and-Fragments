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

function getRandomVocation()
  local validIndices = {}
  for index, _ in pairs(VocationsConfig) do
    table.insert(validIndices, index)
  end

  local randomIndex = validIndices[math.random(1, #validIndices)]

  return randomIndex
end

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