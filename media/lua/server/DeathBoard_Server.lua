DuelTime = {}
DuelTime.board = {}

local function updateClients ()
	print('%%%%%%%%%%%%%%%%%%%%%%% updateClients %%%%%%%%%%%%%%%%%%%%%%')
	local onlinePlayers = getOnlinePlayers()
	for i = 1, onlinePlayers:size() do
		local player = onlinePlayers:get(i - 1)
		if player then
			sendServerCommand(player, "DuelTime", "updateBoard", {})
		end
	end
end

local function updateEntry (playerObj)                                                                                                                                                           
	print('%%%%%%%%%%%%%%%%%%%%%%% updateEntry %%%%%%%%%%%%%%%%%%%%%%')
	if not playerObj then return end
	local playerUsername = playerObj:getUsername()

	if DuelTime.board then
		for i,player in ipairs(DuelTime.board) do
			if player.displayName == playerUsername then
				player.deathCount = player.deathCount + 1
				updateClients()
				return
			end
		end        
	end            

	local playerValues = {displayName = playerUsername, deathCount = 0}
	table.insert(DuelTime.board, playerValues)
	print("Player "..playerUsername.." has been added to the Deathboard!")
	updateClients()
end        

local function inviteToDuel (tableEntry, howInvited)
	print('%%%%%%%%%%%%%%%%% inviteToDuel function %%%%%%%%%%%%%%')
	if not tableEntry then return end
	print('howInvited ', howInvited:getUsername())

	local onlinePlayers = getOnlinePlayers()
	if onlinePlayers then
		for i = 1, onlinePlayers:size() do
			local player = onlinePlayers:get(i - 1)
			if player:getUsername() == tableEntry.displayName then
				local args = {howInvited = howInvited:getUsername(), playerInviter = howInvited}
				print('player ', player:getUsername())
				sendServerCommand(player, "DuelTime", "inviteToDuel", args)
				return
			end
		end
	end

end

local function onInitGlobalModData(isNewGame)
	print('%%%%%%%%%%%%%%%%%%%%%%% onInitGlobalModData %%%%%%%%%%%%%%%%%%%%%%')
	DuelTime.board = ModData.getOrCreate("DuelTime.board")
end

local function onClientCommand(module, command, playerObj, args)
	print('%%%%%%%%%%%%%%%%%%%%%%% onClientCommand server %%%%%%%%%%%%%%%%%%%%%%')
	if module ~= "DuelTime" then return end

	if command == "insertOnList" then
		print('%%%%%%%%%%%%%%%%%%%%%%% InsertOnList %%%%%%%%%%%%%%%%%%%%%%')
		updateEntry(playerObj)
	end

	if command == "inviteToDuel" then
		print('%%%%%%%%%%%%%%%%%%%%%%% InviteToDuel %%%%%%%%%%%%%%%%%%%%%%')
		inviteToDuel(args.player, playerObj)
	end
end

Events.OnClientCommand.Add(onClientCommand)
Events.OnInitGlobalModData.Add(onInitGlobalModData)
