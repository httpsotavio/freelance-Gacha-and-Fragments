local CODE = 201

-- <event type="extendedopcode" name="ChangeCharacterExtended" script="ChangeCharacter/main.lua" />
function onExtendedOpcode(player, opcode, buffer)
  if opcode == CODE then
    local status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )

    -- local pid = player:getId()

    if not status then
      return false
    end

    local action = json_data.action
    local data = json_data.data

    if (action == "getVocationInfo") then
        local retData = {}
        local vocId = tonumber(data.vocationId)
        if (VocationsConfig[vocId]) then
          local tab = VocationsConfig[vocId]
          local desc = tab.description and tab.description or "NO DESCRIPTION"
          table.insert(retData, {description = desc, name = tab.name, class = tab.class, spells = tab.spells, imageName = tab.imageName})
        end
        player:sendExtendedOpcode(CODE, json.encode({action = "fetchVocationInfo", data = retData}))
    end

    if (action == "changeCharacter") then
      player:changeVocation(data.vocationId)
      player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
    end

    if (action == "upgradeStar") then
      local id = tonumber(math.floor(data.vocationId))
      local starc = tonumber(math.floor(player:getVocationStar(id)))
      local fragmentsc = tonumber(math.floor(player:getVocationFragments(id))) 
      local costc = getFragmentsCostToUpgradeStar(starc) or 0
      if (costc ~= 0 and fragmentsc >= costc) then
        player:setVocationFragments(id, fragmentsc - costc)
        player:setVocationStar(id, starc + 1)
        player:getPosition():sendMagicEffect(CONST_ME_MAGIC_BLUE)
      end
    end

    if (action == "updateVocations") then
      if (not data or not data.filter) then
        player:sendVocationList()
        return true
      end
      
      player:sendVocationList(data.filter)
    end
  end
  return true
end

function Player.sendVocationList(self, filter)
  local retData = {}
  local vocationList = self:getVocationList()
  for _, t in pairs(vocationList) do
    local id = tonumber(math.floor(t.vocationId))
    local level = tonumber(math.floor(t.level))    
    local starc = tonumber(math.floor(t.star))
    local tierc = tonumber(math.floor(t.tier))
    local fragmentsc = tonumber(math.floor(t.fragments)) 
    local costc = getFragmentsCostToUpgradeStar(starc) or 0
    local canUpgradeStarsc = false
    if (starc < 5) then
      if (costc > 0) then
        if (fragmentsc >= costc) then canUpgradeStarsc = true end
      end
    end
    local voc = Vocation(id)
    if (voc and VocationsConfig[id]) then
      if (filter) then
        local tab = VocationsConfig[id]

        if (filter == tab.class) then
          table.insert(retData, {vocId = id, lvl = level, name = voc:getName(), star = starc, tier = tierc, fragments = fragmentsc, canUpgradeStars = canUpgradeStarsc, cost = costc})
        end
      else
        table.insert(retData, {vocId = id, lvl = level, name = voc:getName(), star = starc, tier = tierc, fragments = fragmentsc, canUpgradeStars = canUpgradeStarsc, cost = costc})
      end
    end
  end

  table.sort(retData, function (a, b)
    return a.lvl > b.lvl
  end)
  local currentVoc = math.floor(self:getCurrentVocation():getId())
  self:sendExtendedOpcode(CODE, json.encode({action = "fetch", data = {info = retData, currentVocation = currentVoc}}))
end