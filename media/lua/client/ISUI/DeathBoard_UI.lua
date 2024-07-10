local OnISEquippedItemInitialize = ISEquippedItem.initialise

local deathboardIcon = getTexture("media/ui/Deathboard_Icon_Off.png")
local deathboardIconOn = getTexture("media/ui/Deathboard_Icon_On.png")
local deathboardButton
local deathboardWindow

local function getTableLength(table)
	local count = 0
	for _ in pairs(table) do count = count + 1 end
	return count
end

ISDeathboardUI = ISPanel:derive("ISDeathboardUI")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

function ISDeathboardUI:initialise()
	ISPanel.initialise(self)
	local btnWid = 80
	local btnHgt = FONT_HGT_SMALL + 2

	local y = 10 + FONT_HGT_SMALL + 24
	self.playerList = ISScrollingListBox:new(10, y, self.width - 20, self.height - (5 + btnHgt + 5) - y)
	self.playerList:initialise()
	self.playerList:instantiate()
	self.playerList.itemheight = FONT_HGT_SMALL + 2 * 2
	self.playerList.selected = 0
	self.playerList.joypadParent = self
	self.playerList.font = UIFont.NewSmall
	self.playerList.doDrawItem = self.drawPlayers
	self.playerList.drawBorder = true
	self.playerList:addColumn('#', 0)
	self.playerList:addColumn('Sobrevivente', 42)
	self.playerList:addColumn('Mortes', 200)
	self.playerList.onRightMouseUp = ISDeathboardUI.onRightMousePlayerList
	self:addChild(self.playerList)

	self.closeWindowBtn = ISButton:new(self.playerList.x + self.playerList.width - btnWid, self.playerList.y + self.playerList.height + 5, btnWid, btnHgt, 'Fechar', self, ISDeathboardUI.onClick)
	self.closeWindowBtn.internal = "Fechar"
	self.closeWindowBtn.anchorTop = false
	self.closeWindowBtn.anchorBottom = true
	self.closeWindowBtn:initialise()
	self.closeWindowBtn:instantiate()
	self.closeWindowBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9}
	self:addChild(self.closeWindowBtn)
end

function ISDeathboardUI:onRightMousePlayerList(x, y)
	local row = self:rowAt(x, y)
	if row < 1 or row > #self.items then return end
	self.selected = row
	local deathboard = self.parent
	deathboard:doPlayerListContextMenu(self.items[row].item, self:getX() + x, self:getY() + y)
end

function ISDeathboardUI:doPlayerListContextMenu(selectedEntry, x,y)
	local playerObj = getPlayer()
	local playerNum = self.admin:getPlayerNum()
	local context = ISContextMenu.get(playerNum, x + self:getAbsoluteX(), y + self:getAbsoluteY())
	context:addOption("Convidar para Duelo", self, ISDeathboardUI.onCommand, playerObj, selectedEntry, "inviteToDuel")
end

function ISDeathboardUI:onCommand(playerObj, selectedEntry, command)
	print('%%%%%%%%%%%%%%%%%%%%%%% onCommand %%%%%%%%%%%%%%%%%%%%%%')
	print('command ', command)
	local args = { player = selectedEntry }
	sendClientCommand(playerObj, "DuelTime", command, args)
	print('%%%%%%%%%%%%%%%%%%%%%%% after %%%%%%%%%%%%%%%%%%%%%%')
end

function ISDeathboardUI:populateList()
	if not deathboardWindow then return end
	self.playerList:clear()

	table.sort(DuelTime.board, function(a, b) return a.deathCount > b.deathCount end)

	if getTableLength(DuelTime.board) == 0 then
		local entry = {}
		entry.displayName = 'Sem Sobreviventes'
		entry.deathCount = 0
		self.playerList:addItem(entry.displayName, entry)
		return
	end

	local listSize = 0
	for i,player in ipairs(DuelTime.board) do
		if not player.untracked then
			local entry = {}
			entry.displayName = player.displayName
			entry.deathCount = player.deathCount
			self.playerList:addItem(entry.displayName, entry)
			listSize = listSize + 1
		end
	end

	if listSize == 0 then
		local entry = {}
		entry.displayName = 'Sem Sobreviventes'
		entry.deathCount = 0
		self.playerList:addItem(entry.displayName, entry)
	end
end

function ISDeathboardUI:drawPlayers(y, entry, alt)

	local a = 0.9

	self:drawRectBorder(0, (y), self:getWidth(), self.itemheight - 1, a, self.borderColor.r, self.borderColor.g, self.borderColor.b)

	if self.selected == entry.index then
		self:drawRect(0, (y), self:getWidth(), self.itemheight - 1, 0.3, 0.7, 0.35, 0.15)
	end

	self:drawText(tostring(entry.index), 3, y + 2, 1, 1, 1, a, self.font)
	self:drawText(entry.item.displayName, self.columns[2].size + 3, y + 2, 1, 1, 1, a, self.font)
	self:drawText(tostring(entry.item.deathCount), self.columns[3].size + 3, y + 4, 1, 1, 1, a, self.font)

	return y + self.itemheight
end

function ISDeathboardUI:prerender()
	local z = 10
	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
	self:drawText('Placar de Duelos', self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, 'Placar de Duelos') / 2), z, 1,1,1,1, UIFont.Small)
end

function ISDeathboardUI:onClick(button)
	if button.internal == "Fechar" then
		self:close()
		deathboardWindow = nil
		deathboardButton:setImage(deathboardIcon)
	end
end

function ISDeathboardUI:close()
	self:setVisible(false)
	self:removeFromUIManager()
	ISDeathboardUI.instance = nil
end

function ISDeathboardUI:new(x, y, width, height, admin)

	local o = {}
	o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self

	if y == 0 then
		o.y = o:getMouseY() - (height / 2)
		o:setY(o.y)
	end

	if x == 0 then
		o.x = o:getMouseX() - (width / 2)
		o:setX(o.x)
	end

	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	o.backgroundColor = {r=0, g=0, b=0, a=0.8}
	o.width = width
	o.height = height
	o.admin = admin
	o.moveWithMouse = true
	o.deathboard = nil
	o.reverseSorting = false
	ISDeathboardUI.instance = o

	return o
end

local function onPressDeathboardBtn()

	if not deathboardWindow then

		local windowHeight = 100 + (getTableLength(DuelTime.board) * 16)

		if windowHeight > 500 then
			windowHeight = 500
		end

		deathboardWindow = ISDeathboardUI:new(200, 50, 280, windowHeight, getPlayer())
		deathboardWindow:initialise()
		deathboardWindow:addToUIManager()
		deathboardWindow:populateList()
		deathboardButton:setImage(deathboardIconOn)
	else
		deathboardWindow:close()
		deathboardWindow = nil
		deathboardButton:setImage(deathboardIcon)
	end
end

function ISEquippedItem:initialise()

	local menu = OnISEquippedItemInitialize(self)

	if getWorld():getGameMode() == "Multiplayer" then
		local y = self.mapBtn:getY() + self.mapIconOff:getHeightOrig() + 180
		local texWid = deathboardIcon:getWidthOrig()
		local texHgt = deathboardIcon:getHeightOrig()
		deathboardButton = ISButton:new(5, y, texWid, texHgt, "", self, onPressDeathboardBtn)

		deathboardButton:setImage(deathboardIcon)
		deathboardButton.internal = "PlacarDuelo"
		deathboardButton:initialise()
		deathboardButton:instantiate()
		deathboardButton:setDisplayBackground(false)

		deathboardButton.borderColor = {r=1, g=1, b=1, a=0.1}
		deathboardButton:ignoreWidthChange()
		deathboardButton:ignoreHeightChange()

		self:addChild(deathboardButton)
		self:setHeight(deathboardButton:getBottom())
	end

	return menu
end

modalInvite = ISPanel:derive("modalInvite")

function modalInvite:initialise(title)
	ISPanel.initialise(self)
	local btnWid = 80
	local btnHgt = FONT_HGT_SMALL + 2
	local y = 10 + FONT_HGT_SMALL + 24

	self.acceptWindowBtn = ISButton:new((btnWid * 2), y + 5, btnWid, btnHgt, 'Aceitar', self, modalInvite.onClick)
	self.acceptWindowBtn.internal = "Aceitar"
	self.acceptWindowBtn.anchorTop = false
	self.acceptWindowBtn.anchorBottom = true
	self.acceptWindowBtn:initialise()
	self.acceptWindowBtn:instantiate()
	self.acceptWindowBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9}
	self:addChild(self.acceptWindowBtn)

	self.closeWindowBtn = ISButton:new(btnWid - 30, y + 5, btnWid, btnHgt, 'Fechar', self, modalInvite.onClick)
	self.closeWindowBtn.internal = "Fechar"
	self.closeWindowBtn.anchorTop = false
	self.closeWindowBtn.anchorBottom = true
	self.closeWindowBtn:initialise()
	self.closeWindowBtn:instantiate()
	self.closeWindowBtn.borderColor = {r=0.4, g=0.4, b=0.4, a=0.9}
	self:addChild(self.closeWindowBtn)

end

function modalInvite:new(x, y, width, height, admin)

	local o = {}
	o = ISPanel:new(x, y, width, height)
	setmetatable(o, self)
	self.__index = self

	if y == 0 then
		o.y = o:getMouseY() - (height / 2)
		o:setY(o.y)
	end

	if x == 0 then
		o.x = o:getMouseX() - (width / 2)
		o:setX(o.x)
	end

	o.borderColor = {r=0.4, g=0.4, b=0.4, a=1}
	o.backgroundColor = {r=0, g=0, b=0, a=0.8}
	o.width = width
	o.height = height
	o.admin = admin
	o.moveWithMouse = true
	ISDeathboardUI.instance = o

	return o
end

local function openModalInvite(title)
	local modal = modalInvite:new(200, 50, 280, 100, getPlayer())
	modal.title = title
	modal:initialise()
	modal:addToUIManager()
end

function modalInvite:onClick(button)
	if button.internal == "Fechar" then
		self:close()
	end
	if button.internal == "Aceitar" then
		self:accept()
	end
end

function modalInvite:close()
	self:setVisible(false)
	self:removeFromUIManager()
	modalInvite.instance = nil
end

local playerInviter = nil
local leftTime = 0
local tickTimer = 0
local timerType = 0
local TIMER_TYPE_BEFORE_DUEL = 1
local TIMER_TYPE_DUEL = 2

function modalInvite:accept()
	print('accept')
	self:setVisible(false)
	self:removeFromUIManager()
	modalInvite.instance = nil
	leftTime = 10
	timerType = TIMER_TYPE_BEFORE_DUEL
	showTimer()
	print('leftTime ', leftTime)
	print('timerType ', timerType)
end

function modalInvite:prerender()
	local z = 10
	self:drawRect(0, 0, self.width, self.height, self.backgroundColor.a, self.backgroundColor.r, self.backgroundColor.g, self.backgroundColor.b)
	self:drawRectBorder(0, 0, self.width, self.height, self.borderColor.a, self.borderColor.r, self.borderColor.g, self.borderColor.b)
	self:drawText(self.title, self.width/2 - (getTextManager():MeasureStringX(UIFont.Small, self.title) / 2), z, 1,1,1,1, UIFont.Small)
end

local function onServerCommand(module, command, arguments)
	if module ~= "DuelTime" then return end

	if command == "updateBoard" then 
		if not isClient() then return end

		if ModData.exists("DuelTime.board") then
			ModData.remove("DuelTime.board")
		end

		DuelTime.board = ModData.getOrCreate("DuelTime.board")
		ModData.request("DuelTime.board")
	end

	if command == "inviteToDuel" then 
		local color = { r = 0.41, g = 0.80, b = 0.41 };
		local title = arguments.howInvited .. ' te convidou para um duelo'
		playerInviter = arguments.playerInviter
		openModalInvite(title)
	end
end

local function showTimer()
	if leftTime > 0 and timerType > 0 then
		print('leftTime ', leftTime)
		print('timerType ', timerType)
		if tickTimer == 100 then
			local player = getPlayer()
			for i = leftTime, 0, -1 do
				local color = { r = 0.41, g = 0.80, b = 0.41 };
				player:setHaloNote(i, color.r * 250, color.g * 250, color.b * 250, 150);
			end
			tickTimer = 0
		end
		tickTimer = tickTimer + 1
	end
end

Events.OnServerCommand.Add(onServerCommand)
