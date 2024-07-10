
local function onLoadCharacter()
	print('%%%%%%%%%%%%%%%%%%%%%%% onLoadCharacter %%%%%%%%%%%%%%%%%%%%%%')
	if not getWorld():getGameMode() == "Multiplayer" then return end
	print('%%%%%%%%%%%%%%%%%%%%%%% Multiplayer %%%%%%%%%%%%%%%%%%%%%%')

	BravensUtilsDB.DelayFunction(function()
		if not DuelTime.board then return end

		local playerUsername = getPlayer():getUsername()
		for i,player in ipairs(DuelTime.board) do
			if player.displayName == playerUsername then
				print('%%%%%%%%%%%%%%%%%%%%%%% found on table %%%%%%%%%%%%%%%%%%%%%%')
				return
			end
		end

		print('%%%%%%%%%%%%%%%%%%%%%%% NOT found table %%%%%%%%%%%%%%%%%%%%%%')
		sendClientCommand(getPlayer(), "DuelTime", "insertOnList", {})
	end, 300)
end

-- quando acerta o hit final
local function onPlayerDeath(playerObj)
	print('%%%%%%%%%%%%%%%%%%%%%%% onPlayerDeath %%%%%%%%%%%%%%%%%%%%%%')
	local playerDisplayname = playerObj:getUsername()
	sendClientCommand(playerObj, "DuelTime", "Increment", {})
end

local function onInitGlobalModData(isNewGame)
	print('%%%%%%%%%%%%%%%%%%%%%%% onInitGlobalModData %%%%%%%%%%%%%%%%%%%%%%')
	if not isClient() then return end

	if ModData.exists("DuelTime.board") then
		ModData.remove("DuelTime.board")
	end

	DuelTime.board = ModData.getOrCreate("DuelTime.board")
	ModData.request("DuelTime.board")
end

local function onReceiveGlobalModData(modDataName, data)
	print('%%%%%%%%%%%%%%%%%%%%%%% onReceiveGlobalModData %%%%%%%%%%%%%%%%%%%%%%')
    if modDataName ~= "DuelTime.board" then return end

	if not (DuelTime.board and type(data) == "table") then return end
    for key, value in pairs(data) do
        DuelTime.board[key] = value
    end

end

Events.OnInitGlobalModData.Add(onInitGlobalModData)
Events.OnReceiveGlobalModData.Add(onReceiveGlobalModData)
Events.OnCreatePlayer.Add(onLoadCharacter)
Events.OnPlayerDeath.Add(onPlayerDeath)
