function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local split = param:split(",")
	local vocation = Vocation(tonumber(split[1]))
	if (not vocation) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Uso: /addVocation vocId, level, stars? = 1 (padrão), tier? = 1 (padrão)")
		return false
	end	
	
	local level = tonumber(split[2])
	if (not level) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Uso: /addVocation vocId, level, stars? = 1 (padrão), tier? = 1 (padrão)")
		return false
	end
	
	local stars = #split >= 3 and tonumber(split[3]) or 1
	local tier = #split >= 4 and tonumber(split[4]) or vocation:getBaseTier()
	player:addVocation(vocation:getId(), level, stars, tier)
	return false
end
