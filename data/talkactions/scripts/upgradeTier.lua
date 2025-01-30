function onSay(player, words, param)
	local vocation = player:getVocation()
	if (not ENUMTIERS[param]) then
		return false
	end
	player:setVocationTier(vocation:getId(), param)
	return false
end
