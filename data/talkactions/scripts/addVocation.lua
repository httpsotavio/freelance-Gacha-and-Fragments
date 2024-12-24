function onSay(player, words, param)
	if not player:getGroup():getAccess() then
		return true
	end

	player:addVocation(param, 10)
	return false
end
