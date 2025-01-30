function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	local split = param:split(",")
	local rawPlayer = split[1]
	if (not rawPlayer) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Uso: /setkeys player, quantidade")
		return false
	end	
	
	local count = tonumber(split[2])
	if (not count) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Uso: /setkeys player, quantidade")
		return false
	end
	
	local targetPlayer = Player(rawPlayer)
	if (not targetPlayer) then
		player:sendTextMessage(MESSAGE_STATUS_CONSOLE_RED, "Uso: /setkeys player, quantidade")
		return false
	end

	targetPlayer:setStorageValue(10521, count)
	return false
end
