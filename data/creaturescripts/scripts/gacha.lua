local CODE = 222

-- <event type="gacha" name="GachaExtended" script="gacha.lua" />
function onExtendedOpcode(player, opcode, buffer)
  if opcode == CODE then
    local status, json_data =
      pcall(
      function()
        return json.decode(buffer)
      end
    )

    if not status then
      return false
    end

    local action = json_data.action
    local data = json_data.data
    if (action == "getInfo") then
        local keys = player:getStorageValue(10521)
        if (keys < 0) then keys = 0 end
        player:sendExtendedOpcode(CODE, json.encode({action = "fetchInfo", data = {keys = keys}}))
    end

    if (action == "sortVocation") then
      local sortedVocationId = getRandomVocation()
      if (VocationsConfig[sortedVocationId]) then
        local keys = player:getStorageValue(10521)
        if (keys <= 0) then return true end
        local tab = VocationsConfig[sortedVocationId]
        local count = (math.random(100) < 30) and 100 or 20
        local retData = {name = tab.name, image = tab.imageName, count = count, keys = keys - 1}
        player:setStorageValue(10521, keys - 1)
        player:setVocationFragments(sortedVocationId, player:getVocationFragments(sortedVocationId) + count)
        player:sendExtendedOpcode(CODE, json.encode({action = "fetchVocationSort", data = retData}))
      end
  end
  end
  return true
end