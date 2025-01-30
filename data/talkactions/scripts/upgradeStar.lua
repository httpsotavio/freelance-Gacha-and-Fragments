function onSay(player, words, param)
	local vocation = player:getVocation()
	player:setVocationStar(vocation:getId(), param)
	return false
end
