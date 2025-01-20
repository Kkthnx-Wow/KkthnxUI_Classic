local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Bags")

local Unfit = K.LibUnfit
local cargBags = K.cargBags

local table_wipe = table.wipe
local ipairs, strmatch, unpack, ceil = ipairs, string.match, unpack, math.ceil

local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_NewItems_IsNewItem, C_NewItems_RemoveNewItem = C_NewItems.IsNewItem, C_NewItems.RemoveNewItem
local ClearCursor = ClearCursor
local CreateFrame = CreateFrame
local DeleteCursorItem = DeleteCursorItem
local GetContainerItemID = C_Container and C_Container.GetContainerItemID or GetContainerItemID
local GetContainerNumSlots = C_Container and C_Container.GetContainerNumSlots or GetContainerNumSlots
local GetInventoryItemID = GetInventoryItemID
local GetItemInfo = C_Item.GetItemInfo
local ITEM_STARTS_QUEST = ITEM_STARTS_QUEST
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsControlKeyDown, IsAltKeyDown, DeleteCursorItem = IsControlKeyDown, IsAltKeyDown, DeleteCursorItem
local LE_ITEM_CLASS_QUIVER, LE_ITEM_CLASS_CONTAINER = LE_ITEM_CLASS_QUIVER, LE_ITEM_CLASS_CONTAINER
local LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_RARE = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_RARE
local NUM_BAG_SLOTS = NUM_BAG_SLOTS or 4
local NUM_BANKBAGSLOTS = NUM_BANKBAGSLOTS or 7
local PickupContainerItem = C_Container and C_Container.PickupContainerItem or PickupContainerItem
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT
local SortBankBags, SortBags, ClearCursor = SortBankBags, SortBags, ClearCursor
local SplitContainerItem = C_Container and C_Container.SplitContainerItem or SplitContainerItem

local anchorCache = {}

function Module:UpdateBagsAnchor(parent, bags)
	table_wipe(anchorCache)

	local index = 1
	local perRow = C["Inventory"].BagsPerRow
	anchorCache[index] = parent

	for i = 1, #bags do
		local bag = bags[i]
		if bag:GetHeight() > 45 then
			bag:Show()
			index = index + 1

			bag:ClearAllPoints()
			if (index - 1) % perRow == 0 then
				bag:SetPoint("BOTTOMRIGHT", anchorCache[index - perRow], "BOTTOMLEFT", -6, 0)
			else
				bag:SetPoint("BOTTOMLEFT", anchorCache[index - 1], "TOPLEFT", 0, 6)
			end
			anchorCache[index] = bag
		else
			bag:Hide()
		end
	end
end

function Module:UpdateBankAnchor(parent, bags)
	table_wipe(anchorCache)

	local index = 1
	local perRow = C["Inventory"].BankPerRow
	anchorCache[index] = parent

	for i = 1, #bags do
		local bag = bags[i]
		if bag:GetHeight() > 45 then
			bag:Show()
			index = index + 1

			bag:ClearAllPoints()
			if index <= perRow then
				bag:SetPoint("BOTTOMLEFT", anchorCache[index - 1], "TOPLEFT", 0, 6)
			elseif index == perRow + 1 then
				bag:SetPoint("TOPLEFT", anchorCache[index - 1], "TOPRIGHT", 6, 0)
			elseif (index - 1) % perRow == 0 then
				bag:SetPoint("TOPLEFT", anchorCache[index - perRow], "TOPRIGHT", 6, 0)
			else
				bag:SetPoint("TOPLEFT", anchorCache[index - 1], "BOTTOMLEFT", 0, -6)
			end
			anchorCache[index] = bag
		else
			bag:Hide()
		end
	end
end

local function highlightFunction(button, match)
	button.searchOverlay:SetShown(not match)
end

local function IsItemMatched(str, text)
	if not str or str == "" then
		return
	end
	return strmatch(strlower(str), text)
end

local BagSmartFilter = {
	default = function(item, text)
		text = strlower(text)
		if text == "boe" then
			return item.bindOn == "equip"
		else
			return IsItemMatched(item.subType, text) or IsItemMatched(item.equipLoc, text) or IsItemMatched(item.name, text)
		end
	end,
	_default = "default",
}

function Module:CreateInfoFrame()
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 6, -8)
	infoFrame:SetSize(160, 18)

	local icon = infoFrame:CreateTexture(nil, "ARTWORK")
	icon:SetSize(22, 22)
	icon:SetPoint("LEFT", 0, 2)
	icon:SetTexture("Interface\\Minimap\\Tracking\\None")

	local hl = infoFrame:CreateTexture(nil, "HIGHLIGHT")
	hl:SetSize(22, 22)
	hl:SetPoint("LEFT", 0, 2)
	hl:SetTexture("Interface\\Minimap\\Tracking\\None")

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 6)
	search:DisableDrawLayer("BACKGROUND")
	search:CreateBackdrop()
	search.textFilters = BagSmartFilter

	local currencyTag = self:SpawnPlugin("TagDisplay", "[currencies]", infoFrame)
	currencyTag:SetFontObject(K.UIFontOutline)
	currencyTag:SetFont(select(1, currencyTag:GetFont()), 13, select(3, currencyTag:GetFont()))
	currencyTag:SetPoint("TOP", _G.KKUI_BackpackBag, "BOTTOM", 0, -6)

	infoFrame.title = SEARCH
	K.AddTooltip(infoFrame, "ANCHOR_TOPLEFT", K.InfoColorTint .. "|nClick to search your bag items.|nYou can type in item names or item equip locations.|n|n'boe' for items that bind on equip and 'quest' for quest items.")
end

local HideWidgets = true
local function ToggleWidgetButtons(self)
	HideWidgets = not HideWidgets

	local buttons = self.__owner.widgetButtons

	for index, button in pairs(buttons) do
		if index > 2 then
			button:SetShown(not HideWidgets)
		end
	end

	if HideWidgets then
		self:SetPoint("RIGHT", buttons[2], "LEFT", -1, 0)
		K.SetupArrow(self.__texture, "left")
		self.moneyTag:Show()
	else
		self:SetPoint("RIGHT", buttons[#buttons], "LEFT", -1, 0)
		K.SetupArrow(self.__texture, "right")
		self.moneyTag:Hide()
	end

	self:Show()
end

function Module:CreateCollapseArrow()
	local collapseArrow = CreateFrame("Button", nil, self)
	collapseArrow:SetSize(16, 16)

	collapseArrow.Icon = collapseArrow:CreateTexture()
	collapseArrow.Icon:SetAllPoints()
	K.SetupArrow(collapseArrow.Icon, "right")
	collapseArrow.__texture = collapseArrow.Icon

	local moneyTag = self:SpawnPlugin("TagDisplay", "[money]", self)
	moneyTag:SetFontObject(K.UIFontOutline)
	moneyTag:SetFont(select(1, moneyTag:GetFont()), 13, select(3, moneyTag:GetFont()))
	moneyTag:SetPoint("RIGHT", collapseArrow, "LEFT", -12, 0)

	local moneyTagFrame = CreateFrame("Frame", nil, UIParent)
	moneyTagFrame:SetParent(self)
	moneyTagFrame:SetAllPoints(moneyTag)
	moneyTagFrame:SetScript("OnEnter", K.GoldButton_OnEnter)
	moneyTagFrame:SetScript("OnLeave", K.GoldButton_OnLeave)

	collapseArrow.moneyTag = moneyTag

	collapseArrow.__owner = self
	HideWidgets = not HideWidgets -- reset before toggle
	ToggleWidgetButtons(collapseArrow)
	collapseArrow:SetScript("OnClick", ToggleWidgetButtons)

	collapseArrow.title = "Widgets Toggle"
	K.AddTooltip(collapseArrow, "ANCHOR_TOP")

	self.widgetArrow = collapseArrow
end

local function updateBagBar(bar)
	local spacing = 6
	local offset = 6
	local width, height = bar:LayoutButtons("grid", bar.columns, spacing, offset, -offset)
	bar:SetSize(width + offset * 2, height + offset * 2)
end

function Module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -6)
	bagBar:CreateBorder()
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()
	bagBar.columns = columns
	bagBar.UpdateAnchor = updateBagBar
	bagBar:UpdateAnchor()

	self.BagBar = bagBar
end

local function CloseOrRestoreBags(self, btn)
	if btn == "RightButton" then
		local bag = self.__owner.main
		local bank = self.__owner.bank
		KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][bag:GetName()] = nil
		KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][bank:GetName()] = nil
		bag:ClearAllPoints()
		bag:SetPoint(unpack(bag.__anchor))
		bank:ClearAllPoints()
		bank:SetPoint(unpack(bank.__anchor))
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	else
		CloseAllBags()
	end
end

function Module:CreateCloseButton(f)
	local closeButton = CreateFrame("Button", nil, self)
	closeButton:RegisterForClicks("AnyUp")
	closeButton:SetSize(18, 18)
	closeButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, { 0.85, 0.25, 0.25 })
	closeButton:StyleButton()
	closeButton.__owner = f

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32")
	closeButton.Icon:SetAllPoints()

	closeButton:SetScript("OnClick", CloseOrRestoreBags)
	closeButton.title = CLOSE .. "/" .. _G.RESET
	K.AddTooltip(closeButton, "ANCHOR_TOP")

	return closeButton
end

local function ToggleBackpacks(self)
	local parent = self.__owner
	K.TogglePanel(parent.BagBar)
	if parent.BagBar:IsShown() then
		self.KKUI_Border:SetVertexColor(1, 0.8, 0)
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
		if parent.keyring and parent.keyring:IsShown() then
			parent.keyToggle:Click()
		end
	else
		K.SetBorderColor(self.KKUI_Border)
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	end
end

function Module:CreateBagToggle(click)
	local bagToggleButton = CreateFrame("Button", nil, self)
	bagToggleButton:SetSize(18, 18)
	bagToggleButton:CreateBorder()
	bagToggleButton:StyleButton()

	bagToggleButton.Icon = bagToggleButton:CreateTexture(nil, "ARTWORK")
	bagToggleButton.Icon:SetAllPoints()
	bagToggleButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	bagToggleButton.Icon:SetTexture("Interface\\Buttons\\Button-Backpack-Up")

	bagToggleButton.__owner = self
	bagToggleButton:SetScript("OnClick", ToggleBackpacks)
	bagToggleButton.title = BACKPACK_TOOLTIP
	K.AddTooltip(bagToggleButton, "ANCHOR_TOP")

	if click then
		ToggleBackpacks(bagToggleButton)
	end

	return bagToggleButton
end

function Module:CreateKeyToggle(click)
	local keyToggleButton = CreateFrame("Button", nil, self)
	keyToggleButton:SetSize(18, 18)
	keyToggleButton:CreateBorder()
	keyToggleButton:StyleButton()

	keyToggleButton.Icon = keyToggleButton:CreateTexture(nil, "ARTWORK")
	keyToggleButton.Icon:SetAllPoints()
	keyToggleButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	keyToggleButton.Icon:SetTexture("Interface\\ICONS\\INV_Misc_Key_03")

	keyToggleButton.__owner = self
	keyToggleButton:SetScript("OnClick", function()
		ToggleFrame(self.keyring)
		if self.keyring:IsShown() then
			keyToggleButton.KKUI_Border:SetVertexColor(1, 0.8, 0)
			PlaySound(SOUNDKIT.KEY_RING_OPEN)
			if self.BagBar and self.BagBar:IsShown() then
				self.bagToggle:Click()
			end
		else
			K.SetBorderColor(keyToggleButton.KKUI_Border)
			PlaySound(SOUNDKIT.KEY_RING_CLOSE)
		end
	end)
	keyToggleButton.title = KEYRING
	K.AddTooltip(keyToggleButton, "ANCHOR_TOP")

	return keyToggleButton
end

function Module:CreateSortButton(name)
	local sortButton = CreateFrame("Button", nil, self)
	sortButton:SetSize(18, 18)
	sortButton:CreateBorder()
	sortButton:StyleButton()

	sortButton.Icon = sortButton:CreateTexture(nil, "ARTWORK")
	sortButton.Icon:SetAllPoints()
	sortButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	sortButton.Icon:SetAtlas("bags-button-autosort-up")

	sortButton:SetScript("OnClick", function()
		if name == "Bank" then
			SortBankBags()
		else
			SortBags()
		end
	end)
	sortButton.title = "Sort"
	K.AddTooltip(sortButton, "ANCHOR_TOP")

	return sortButton
end

function Module:GetContainerEmptySlot(bagID, bagGroup)
	if cargBags.BagGroups[bagID] == bagGroup then
		for slotID = 1, GetContainerNumSlots(bagID) do
			if not GetContainerItemID(bagID, slotID) then
				return slotID
			end
		end
	end
end

function Module:GetEmptySlot(bagType, bagGroup)
	if bagType == "Bag" then
		for bagID = 0, NUM_BAG_SLOTS do
			local slotID = Module:GetContainerEmptySlot(bagID, bagGroup)
			if slotID then
				return bagID, slotID
			end
		end
	elseif bagType == "Bank" then
		local slotID = Module:GetContainerEmptySlot(-1, bagGroup)
		if slotID then
			return -1, slotID
		end
		for bagID = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do
			local slotID = Module:GetContainerEmptySlot(bagID, bagGroup)
			if slotID then
				return bagID, slotID
			end
		end
	end
end

function Module:FreeSlotOnDrop()
	local bagID, slotID = Module:GetEmptySlot(self.__owner.Settings.BagType, self.__owner.bagGroup)
	if slotID then
		PickupContainerItem(bagID, slotID)
	end
end

local freeSlotContainer = {
	["Bag"] = 0,
	["Bank"] = 0,
	["AmmoItem"] = K.Class == "WARLOCK" and 1 or K.Class == "HUNTER" and -1,
	["bankAmmoItem"] = K.Class == "WARLOCK" and 1 or K.Class == "HUNTER" and -1,
}

function Module:CreateFreeSlots()
	local name = self.name
	local bagGroup = freeSlotContainer[name]
	if not bagGroup then
		return
	end
	self.bagGroup = bagGroup

	local slot = CreateFrame("Button", name .. "FreeSlot", self)
	slot:SetSize(self.iconSize, self.iconSize)
	slot:CreateBorder(nil, nil, nil, nil, nil, nil, "Interface\\PaperDoll\\UI-PaperDoll-Slot-Bag", nil, nil, nil, { 1, 1, 1 })
	slot:StyleButton()
	slot:SetScript("OnMouseUp", Module.FreeSlotOnDrop)
	slot:SetScript("OnReceiveDrag", Module.FreeSlotOnDrop)
	K.AddTooltip(slot, "ANCHOR_RIGHT", "FreeSlots")
	slot.__owner = self

	local tag = self:SpawnPlugin("TagDisplay", "|cff5C8BCF[space]|r", slot)
	tag:SetFontObject(K.UIFontOutline)
	tag:SetFont(select(1, tag:GetFont()), 16, select(3, tag:GetFont()))
	tag:SetPoint("CENTER", 0, 0)
	tag.__owner = self
	slot.tag = tag

	self.freeSlot = slot
end

local toggleButtons = {}
function Module:SelectToggleButton(id)
	for index, button in pairs(toggleButtons) do
		if index ~= id then
			button.__turnOff()
		end
	end
end

local splitEnable
local function saveSplitCount(self)
	local count = self:GetText() or ""
	KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount = tonumber(count) or 1
end

local function editBoxClearFocus(self)
	self:ClearFocus()
end

function Module:CreateSplitButton()
	local enabledText = K.SystemColor .. L["StackSplitEnable"]

	local splitFrame = CreateFrame("Frame", nil, self)
	splitFrame:SetSize(100, 50)
	splitFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -6)
	K.CreateFontString(splitFrame, 14, L["Split Count"], "", "system", "TOP", 1, -5)
	splitFrame:CreateBorder()
	splitFrame:Hide()

	local editBox = CreateFrame("EditBox", nil, splitFrame)
	editBox:CreateBorder()
	editBox:SetWidth(90)
	editBox:SetHeight(20)
	editBox:SetAutoFocus(false)
	editBox:SetTextInsets(5, 5, 0, 0)
	editBox:SetFontObject(K.UIFontOutline)
	editBox:SetPoint("BOTTOMLEFT", 5, 5)
	editBox:SetScript("OnEscapePressed", editBoxClearFocus)
	editBox:SetScript("OnEnterPressed", editBoxClearFocus)
	editBox:SetScript("OnTextChanged", saveSplitCount)

	local splitButton = CreateFrame("Button", nil, self)
	splitButton:SetSize(18, 18)
	splitButton:CreateBorder()
	splitButton:StyleButton()

	splitButton.Icon = splitButton:CreateTexture(nil, "ARTWORK")
	splitButton.Icon:SetPoint("TOPLEFT", -1, 3)
	splitButton.Icon:SetPoint("BOTTOMRIGHT", 1, -3)
	splitButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	splitButton.Icon:SetTexture("Interface\\HELPFRAME\\ReportLagIcon-AuctionHouse")

	splitButton.__turnOff = function()
		K.SetBorderColor(splitButton.KKUI_Border)
		splitButton.Icon:SetDesaturated(false)
		splitButton.text = nil
		splitFrame:Hide()
		splitEnable = nil
	end

	splitButton:SetScript("OnClick", function(self)
		Module:SelectToggleButton(1)
		splitEnable = not splitEnable
		if splitEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
			splitFrame:Show()
			editBox:SetText(KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount)
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	splitButton:SetScript("OnHide", splitButton.__turnOff)
	splitButton.title = L["Quick Split"]
	K.AddTooltip(splitButton, "ANCHOR_TOP")

	toggleButtons[1] = splitButton

	return splitButton
end

local function splitOnClick(self)
	if not splitEnable then
		return
	end

	PickupContainerItem(self.bagId, self.slotId)

	local info = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local itemCount = info and info.stackCount
	local locked = info and info.isLocked
	if texture and not locked and itemCount and itemCount > KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount then
		SplitContainerItem(self.bagId, self.slotId, KkthnxUIDB.Variables[K.Realm][K.Name].SplitCount)

		local bagID, slotID = Module:GetEmptySlot("Bag")
		if slotID then
			PickupContainerItem(bagID, slotID)
		end
	end
end

local favouriteEnable

local function GetCustomGroupTitle(index)
	return KkthnxUIDB.Variables[K.Realm][K.Name].CustomNames[index] or (CUSTOM .. " " .. FILTER .. " " .. index)
end

StaticPopupDialogs["KKUI_RENAMECUSTOMGROUP"] = {
	text = BATTLE_PET_RENAME,
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function(self)
		local index = Module.selectGroupIndex
		local text = self.editBox:GetText()
		KkthnxUIDB.Variables[K.Realm][K.Name].CustomNames[index] = text ~= "" and text or nil

		Module.CustomMenu[index + 2].text = GetCustomGroupTitle(index)
		Module.ContainerGroups["Bag"][index].label:SetText(GetCustomGroupTitle(index))
		Module.ContainerGroups["Bank"][index].label:SetText(GetCustomGroupTitle(index))
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	whileDead = 1,
	showAlert = 1,
	hasEditBox = 1,
	editBoxWidth = 250,
}

function Module:RenameCustomGroup(index)
	Module.selectGroupIndex = index
	StaticPopup_Show("KKUI_RENAMECUSTOMGROUP")
end

function Module:MoveItemToCustomBag(index)
	local itemID = Module.selectItemID
	if index == 0 then
		if KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID] then
			KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID] = nil
		end
	else
		KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID] = index
	end
	Module:UpdateAllBags()
end

function Module:IsItemInCustomBag()
	local index = self.arg1
	local itemID = Module.selectItemID
	return (index == 0 and not KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID]) or (KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[itemID] == index)
end

function Module:CreateFavouriteButton()
	local menuList = {
		{
			text = "",
			icon = 134400,
			isTitle = true,
			notCheckable = true,
			tCoordLeft = 0.08,
			tCoordRight = 0.92,
			tCoordTop = 0.08,
			tCoordBottom = 0.92,
		},
		{ text = NONE, arg1 = 0, func = Module.MoveItemToCustomBag, checked = Module.IsItemInCustomBag },
	}
	for i = 1, 5 do
		tinsert(menuList, {
			text = GetCustomGroupTitle(i),
			arg1 = i,
			func = Module.MoveItemToCustomBag,
			checked = Module.IsItemInCustomBag,
			hasArrow = true,
			menuList = { { text = BATTLE_PET_RENAME, arg1 = i, func = Module.RenameCustomGroup } },
		})
	end
	Module.CustomMenu = menuList

	local enabledText = K.SystemColor .. L["Custom Filter Mode Enabled"]

	local favouriteButton = CreateFrame("Button", nil, self)
	favouriteButton:SetSize(18, 18)
	favouriteButton:CreateBorder()
	favouriteButton:StyleButton()

	favouriteButton.Icon = favouriteButton:CreateTexture(nil, "ARTWORK")
	favouriteButton.Icon:SetPoint("TOPLEFT", -2, 2)
	favouriteButton.Icon:SetPoint("BOTTOMRIGHT", 2, -2)
	favouriteButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	favouriteButton.Icon:SetAtlas("PetJournal-FavoritesIcon", true)

	favouriteButton.__turnOff = function()
		K.SetBorderColor(favouriteButton.KKUI_Border)
		favouriteButton.Icon:SetDesaturated(false)
		favouriteButton.text = nil
		favouriteEnable = nil
	end

	favouriteButton:SetScript("OnClick", function(self)
		Module:SelectToggleButton(2)
		favouriteEnable = not favouriteEnable
		if favouriteEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			self.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	favouriteButton:SetScript("OnHide", favouriteButton.__turnOff)
	favouriteButton.title = L["Custom Filter Mode"]
	K.AddTooltip(favouriteButton, "ANCHOR_TOP")

	toggleButtons[2] = favouriteButton

	return favouriteButton
end

local function favouriteOnClick(self)
	if not favouriteEnable then
		return
	end

	local info = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local quality = info and info.quality
	local link = info and info.hyperlink
	local itemID = info and info.itemID
	if texture and quality > Enum.ItemQuality.Poor then
		ClearCursor()
		Module.selectItemID = itemID
		Module.CustomMenu[1].text = link
		Module.CustomMenu[1].icon = texture
		K.LibEasyMenu.Create(Module.CustomMenu, K.EasyMenu, self, 0, 0, "MENU")
	end
end

StaticPopupDialogs["KKUI_WIPE_JUNK_LIST"] = {
	text = "Are you sure you want to clear the custom junk list?",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		wipe(KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList)
	end,
	whileDead = 1,
}

local customJunkEnable
function Module:CreateJunkButton()
	local enabledText = K.InfoColor .. "|nClick an item to tag it as junk.|n|nIf 'Module Autosell' is enabled, these items will be sold as well.|n|nThe list is saved account-wide."

	local JunkButton = CreateFrame("Button", nil, self)
	JunkButton:SetSize(18, 18)
	JunkButton:CreateBorder()
	JunkButton:StyleButton()

	JunkButton.Icon = JunkButton:CreateTexture(nil, "ARTWORK")
	JunkButton.Icon:SetPoint("TOPLEFT", 1, -2)
	JunkButton.Icon:SetPoint("BOTTOMRIGHT", -1, -2)
	JunkButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	JunkButton.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Coin-Up")

	JunkButton.__turnOff = function()
		K.SetBorderColor(JunkButton.KKUI_Border)
		JunkButton.Icon:SetDesaturated(false)
		JunkButton.text = nil
		customJunkEnable = nil
	end

	JunkButton:SetScript("OnClick", function(self)
		if IsAltKeyDown() and IsControlKeyDown() then
			StaticPopup_Show("KKUI_WIPE_JUNK_LIST")
			return
		end

		Module:SelectToggleButton(3)
		customJunkEnable = not customJunkEnable
		if customJunkEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			JunkButton.__turnOff()
		end
		Module:UpdateAllBags()
		self:GetScript("OnEnter")(self)
	end)
	JunkButton:SetScript("OnHide", JunkButton.__turnOff)
	JunkButton.title = "Custom Junk List"
	K.AddTooltip(JunkButton, "ANCHOR_TOP")

	toggleButtons[3] = JunkButton

	return JunkButton
end

local function customJunkOnClick(self)
	if not customJunkEnable then
		return
	end

	local info = C_Container_GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local itemID = info and info.itemID
	local price = select(11, GetItemInfo(itemID))
	if texture and price > 0 then
		if KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID] then
			KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID] = nil
		else
			KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID] = true
		end
		ClearCursor()
		Module:UpdateAllBags()
	end
end

local deleteEnable
function Module:CreateDeleteButton()
	local enabledText = K.SystemColor .. L["Delete Mode Enabled"]

	local deleteButton = CreateFrame("Button", nil, self)
	deleteButton:SetSize(18, 18)
	deleteButton:CreateBorder()
	deleteButton:StyleButton()

	deleteButton.Icon = deleteButton:CreateTexture(nil, "ARTWORK")
	deleteButton.Icon:SetPoint("TOPLEFT", 3, -2)
	deleteButton.Icon:SetPoint("BOTTOMRIGHT", -1, 2)
	deleteButton.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	deleteButton.Icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")

	deleteButton.__turnOff = function()
		K.SetBorderColor(deleteButton.KKUI_Border)
		deleteButton.Icon:SetDesaturated(false)
		deleteButton.text = nil
		deleteEnable = nil
	end

	deleteButton:SetScript("OnClick", function(self)
		Module:SelectToggleButton(4)
		deleteEnable = not deleteEnable
		if deleteEnable then
			self.KKUI_Border:SetVertexColor(1, 0, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			deleteButton.__turnOff()
		end
		self:GetScript("OnEnter")(self)
	end)
	deleteButton:SetScript("OnHide", deleteButton.__turnOff)
	deleteButton.title = L["Item Delete Mode"]
	K.AddTooltip(deleteButton, "ANCHOR_TOP")

	toggleButtons[4] = deleteButton

	return deleteButton
end

local function deleteButtonOnClick(self)
	if not deleteEnable then
		return
	end

	local info = C_Container.GetContainerItemInfo(self.bagId, self.slotId)
	local texture = info and info.iconFileID
	local quality = info and info.quality

	if IsControlKeyDown() and IsAltKeyDown() and texture and (quality < LE_ITEM_QUALITY_RARE) then
		PickupContainerItem(self.bagId, self.slotId)
		DeleteCursorItem()
	end
end

function Module:ButtonOnClick(btn)
	if btn ~= "LeftButton" then
		return
	end
	splitOnClick(self)
	favouriteOnClick(self)
	customJunkOnClick(self)
	deleteButtonOnClick(self)
end

function Module:UpdateAllBags()
	if self.Bags and self.Bags:IsShown() then
		self.Bags:BAG_UPDATE()
	end
end

function Module:OpenBags()
	OpenAllBags(true)
end

function Module:CloseBags()
	CloseAllBags()
end

local questItemCache = {}
function Module:IsAcceptableQuestItem(link)
	if not link then
		return
	end

	local canAccept = questItemCache[link]
	if not canAccept then
		K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		K.ScanTooltip:SetHyperlink(link)

		for i = 2, K.ScanTooltip:NumLines() do
			local line = _G["KKUI_ScanTooltipTextLeft" .. i]
			local lineText = line and line:GetText()
			if lineText and strmatch(lineText, ITEM_STARTS_QUEST) then
				canAccept = true
				questItemCache[link] = true
				break
			end
		end
	end

	return canAccept
end

function Module:OnEnable()
	local loadInventoryModules = {
		"CreateInventoryBar",
		"CreateAutoRepair",
		"CreateAutoSell",
	}

	for _, funcName in ipairs(loadInventoryModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end

	if not C["Inventory"].Enable then
		return
	end

	if C_AddOns.IsAddOnLoaded("AdiBags") or C_AddOns.IsAddOnLoaded("ArkInventory") or C_AddOns.IsAddOnLoaded("cargBags_Nivaya") or C_AddOns.IsAddOnLoaded("cargBags") or C_AddOns.IsAddOnLoaded("Bagnon") or C_AddOns.IsAddOnLoaded("Combuctor") or C_AddOns.IsAddOnLoaded("TBag") or C_AddOns.IsAddOnLoaded("BaudBag") then
		return
	end

	-- Settings
	local iconSize = C["Inventory"].IconSize
	local showItemLevel = C["Inventory"].BagsItemLevel
	local showBindOnEquip = C["Inventory"].BagsBindOnEquip
	local showNewItem = C["Inventory"].ShowNewItem
	local hasPawn = C_AddOns.IsAddOnLoaded("Pawn")

	-- Init
	local Backpack = cargBags:NewImplementation("KKUI_Backpack")
	Backpack:RegisterBlizzard()
	Backpack:HookScript("OnShow", function()
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
	end)
	Backpack:HookScript("OnHide", function()
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	end)

	Module.Bags = Backpack
	cargBags.BagGroups = {}
	cargBags.BagGroups[0] = 0 -- backpack
	cargBags.BagGroups[-1] = 0 -- bank

	local f = {}
	local filters = Module:GetFilters()
	local MyContainer = Backpack:GetContainerClass()
	Module.ContainerGroups = { ["Bag"] = {}, ["Bank"] = {} }

	local function AddNewContainer(bagType, index, name, filter)
		local newContainer = MyContainer:New(name, { BagType = bagType, Index = index })
		newContainer:SetFilter(filter, true)
		Module.ContainerGroups[bagType][index] = newContainer
	end

	function Backpack:OnInit()
		AddNewContainer("Bag", 11, "Junk", filters.bagsJunk)
		for i = 1, 5 do
			AddNewContainer("Bag", i, "BagCustom" .. i, filters["bagCustom" .. i])
		end
		AddNewContainer("Bag", 6, "AmmoItem", filters.bagAmmo)
		AddNewContainer("Bag", 7, "Equipment", filters.bagEquipment)
		AddNewContainer("Bag", 9, "Consumable", filters.bagConsumable)
		AddNewContainer("Bag", 8, "BagGoods", filters.bagGoods)
		AddNewContainer("Bag", 10, "BagQuest", filters.bagQuest)

		f.main = MyContainer:New("Bag", { Bags = "bags", BagType = "Bag" })
		f.main.__anchor = { "BOTTOMRIGHT", -50, 100 }
		f.main:SetPoint(unpack(f.main.__anchor))
		f.main:SetFilter(filters.onlyBags, true)

		local keyring = MyContainer:New("Keyring", { BagType = "Bag", Parent = f.main })
		keyring:SetFilter(filters.onlyKeyring, true)
		keyring:SetPoint("TOPRIGHT", f.main, "BOTTOMRIGHT", 0, -5)
		keyring:Hide()
		f.main.keyring = keyring

		for i = 1, 5 do
			AddNewContainer("Bank", i, "BankCustom" .. i, filters["bankCustom" .. i])
		end
		AddNewContainer("Bank", 6, "bankAmmoItem", filters.bankAmmo)
		AddNewContainer("Bank", 8, "BankLegendary", filters.bankLegendary)
		AddNewContainer("Bank", 7, "BankEquipment", filters.bankEquipment)
		AddNewContainer("Bank", 10, "BankConsumable", filters.bankConsumable)
		AddNewContainer("Bank", 9, "BankGoods", filters.bankGoods)
		AddNewContainer("Bank", 11, "BankQuest", filters.bankQuest)

		f.bank = MyContainer:New("Bank", { Bags = "bank", BagType = "Bank" })
		f.bank.__anchor = { "BOTTOMLEFT", 25, 50 }
		f.bank:SetPoint(unpack(f.bank.__anchor))
		f.bank:SetFilter(filters.onlyBank, true)
		f.bank:Hide()

		for bagType, groups in pairs(Module.ContainerGroups) do
			for _, container in ipairs(groups) do
				local parent = Backpack.contByName[bagType]
				container:SetParent(parent)
				K.CreateMoverFrame(container, parent, true)
			end
		end
	end

	local initBagType
	function Backpack:OnBankOpened()
		self:GetContainer("Bank"):Show()

		if not initBagType then
			Module:UpdateAllBags() -- Initialize bagType
			Module:UpdateBagSize()
			initBagType = true
		end
	end

	function Backpack:OnBankClosed()
		self:GetContainer("Bank"):Hide()
	end

	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetNormalTexture(0)
		self:SetPushedTexture(0)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		self.Count:SetPoint("BOTTOMRIGHT", 1, 1)
		self.Count:SetFontObject(K.UIFontOutline)

		self.Cooldown:SetPoint("TOPLEFT", 1, -1)
		self.Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)

		self:CreateBorder(nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Slot-Background", nil, nil, nil, { 1, 1, 1 })
		self:StyleButton()

		local parentFrame = CreateFrame("Frame", nil, self)
		parentFrame:SetAllPoints()
		parentFrame:SetFrameLevel(5)

		self.Favourite = parentFrame:CreateTexture(nil, "ARTWORK")
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(30, 30)
		self.Favourite:SetPoint("TOPLEFT", -12, 9)

		self.Quest = parentFrame:CreateTexture(nil, "OVERLAY")
		self.Quest:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
		self.Quest:SetSize(26, 26)
		self.Quest:SetPoint("LEFT", 0, 1)

		self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 0)
		self.iLvl:SetFontObject(K.UIFontOutline)
		self.iLvl:SetFont(select(1, self.iLvl:GetFont()), 12, select(3, self.iLvl:GetFont()))

		self.bindType = K.CreateFontString(self, 12, "", "OUTLINE", false, "TOPLEFT", 1, -2)
		self.bindType:SetFontObject(K.UIFontOutline)
		self.bindType:SetFont(select(1, self.iLvl:GetFont()), 12, select(3, self.iLvl:GetFont()))

		self.usableTexture = self:CreateTexture(nil, "ARTWORK")
		self.usableTexture:SetTexture(C["Media"].Textures.White8x8Texture)
		self.usableTexture:SetAllPoints(self)
		self.usableTexture:SetVertexColor(1, 0, 0)
		self.usableTexture:SetBlendMode("MOD")

		if showNewItem and not self.glowFrame then
			self.glowFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
			self.glowFrame:SetFrameLevel(self:GetFrameLevel() + 2)
			self.glowFrame:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 16 })
			self.glowFrame:SetBackdropBorderColor(1, 223 / 255, 0, 1)
			self.glowFrame:SetPoint("TOPLEFT", self, -6, 6)
			self.glowFrame:SetPoint("BOTTOMRIGHT", self, 6, -6)

			self.glowFrame.Animation = self.glowFrame.Animation or self.glowFrame:CreateAnimationGroup()
			self.glowFrame.Animation:SetLooping("BOUNCE")

			self.glowFrame.Animation.FadeOut = self.glowFrame.Animation.FadeOut or self.glowFrame.Animation:CreateAnimation("Alpha")
			self.glowFrame.Animation.FadeOut:SetFromAlpha(1)
			self.glowFrame.Animation.FadeOut:SetToAlpha(0.1)
			self.glowFrame.Animation.FadeOut:SetDuration(0.6)
			self.glowFrame.Animation.FadeOut:SetSmoothing("IN_OUT")
		end

		self:HookScript("OnClick", Module.ButtonOnClick)
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame and self.glowFrame.Animation then
			local isNewItem = C_NewItems.IsNewItem(self.bagId, self.slotId)
			local isAnimationPlaying = self.glowFrame.Animation:IsPlaying()

			if not isNewItem and isAnimationPlaying then
				self.glowFrame.Animation:Stop()
				self.glowFrame:Hide()
				C_NewItems_RemoveNewItem(self.bagId, self.slotId)
			end
		end
	end

	local bagGroupColor = {
		[-1] = { 0.67, 0.83, 0.45, 1 }, -- Quiver/Ammo Bag
		[0] = { 1, 1, 1, 1 }, -- Container
		[1] = { 0.53, 0.53, 0.93, 1 }, -- Soul Bag
		[2] = { 0, 0.5, 0, 1 }, -- Herb Bag
		[3] = { 0.8, 0, 0.8, 1 }, -- Enchanting Bag
		[4] = { 1, 0.8, 0, 1 }, -- Engineering Bag
		[5] = { 0, 0.8, 0.8, 1 }, -- Gem Bag
		[6] = { 0.5, 0.4, 0, 1 }, -- Mining Bag
		[7] = { 0.8, 0.5, 0.5, 1 }, -- Leatherworking Bag
		[8] = { 0.8, 0.8, 0.8, 1 }, -- Inscription Bag
		[9] = { 0.4, 0.6, 1, 1 }, -- Toolbox
		[10] = { 0.8, 0, 0, 1 }, -- Cooking Bag
	}

	local function isItemNeedsLevel(item)
		return item.link and item.quality > 1 and Module:IsItemHasLevel(item)
	end

	local function UpdatePawnArrow(self, item)
		if not hasPawn then
			return
		end

		if not PawnIsContainerItemAnUpgrade then
			return
		end

		if self.UpgradeIcon then
			self.UpgradeIcon:ClearAllPoints()
			self.UpgradeIcon:SetPoint("TOPRIGHT", 3, 3)
			self.UpgradeIcon:SetShown(PawnIsContainerItemAnUpgrade(item.bagId, item.slotId))
		end
	end

	function MyButton:OnUpdate(item)
		if MerchantFrame:IsShown() then
			if item.isInSet then
				self:SetAlpha(0.5)
			else
				self:SetAlpha(1)
			end
		end

		-- Determine if we can use that item or not?
		if (Unfit:IsItemUnusable(item.link) or item.minLevel and item.minLevel > K.Level) and not item.locked then
			self.usableTexture:Show()
		else
			self.usableTexture:Hide()
		end

		if self.JunkIcon then
			if (item.quality == LE_ITEM_QUALITY_POOR or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[item.id]) and item.hasPrice then
				self.JunkIcon:Show()
			else
				self.JunkIcon:Hide()
			end
		end

		if KkthnxUIDB.Variables[K.Realm][K.Name].CustomItems[item.id] and not C["Inventory"].ItemFilter then
			self.Favourite:Show()
		else
			self.Favourite:Hide()
		end

		self.iLvl:SetText("")
		if showItemLevel and isItemNeedsLevel(item) then
			local level = item.level
			if level and level > 1 then
				local color = K.QualityColors[item.quality]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(color.r, color.g, color.b)
			end
		end

		self.bindType:SetText("")
		if showBindOnEquip then
			local BoE, BoU = item.bindType == 2, item.bindType == 3
			if not item.bound and (BoE or BoU) then
				local color = K.QualityColors[item.quality]
				self.bindType:SetText(BoE and L["BoE"] or L["BoU"]) -- Local these asap
				self.bindType:SetTextColor(color.r, color.g, color.b)
			end
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagId, item.slotId) then
				local color = K.QualityColors[item.quality] or {}
				if item.questID or item.isQuestItem then
					self.glowFrame:SetBackdropBorderColor(1, 0.82, 0.2, 1)
				elseif color.r and color.g and color.b then
					self.glowFrame:SetBackdropBorderColor(color.r, color.g, color.b, 1)
				else
					self.glowFrame:SetBackdropBorderColor(1, 223 / 255, 0, 1)
				end
				self.glowFrame:Show()
				self.glowFrame.Animation:Play()
			else
				self.glowFrame:Hide()
				self.glowFrame.Animation:Stop()
			end
		end

		if C["Inventory"].SpecialBagsColor then
			local bagType = cargBags.BagGroups[item.bagId]
			local color = bagGroupColor[bagType] or bagGroupColor[0]
			self.KKUI_Background:SetVertexColor(unpack(color))
		else
			self.KKUI_Background:SetVertexColor(1, 1, 1, 1)
		end

		-- Hide empty tooltip
		if GameTooltip:GetOwner() == self then
			if item.texture then
				self:UpdateTooltip()
			else
				GameTooltip:Hide()
			end
		end

		-- Support Pawn
		UpdatePawnArrow(self, item)
	end

	function MyButton:OnUpdateQuest(item)
		if item.isQuestItem then
			self.KKUI_Border:SetVertexColor(1, 0.82, 0.2)
		elseif item.quality and item.quality > -1 then
			local color = K.QualityColors[item.quality]
			self.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		else
			K.SetBorderColor(self.KKUI_Border)
		end

		self.Quest:SetShown(item.isQuestItem and Module:IsAcceptableQuestItem(item.link))
	end

	function Module:UpdateAllAnchors()
		Module:UpdateBagsAnchor(f.main, Module.ContainerGroups["Bag"])
		Module:UpdateBankAnchor(f.bank, Module.ContainerGroups["Bank"])
	end

	function Module:GetContainerColumns(bagType)
		if bagType == "Bag" then
			return C["Inventory"].BagsWidth
		elseif bagType == "Bank" then
			return C["Inventory"].BankWidth
		end
	end

	function MyContainer:OnContentsChanged(gridOnly)
		self:SortButtons("bagSlot")

		local columns = Module:GetContainerColumns(self.Settings.BagType)
		local offset = 38
		local spacing = 6
		local xOffset = 6
		local yOffset = -offset + xOffset
		local _, height = self:LayoutButtons("grid", columns, spacing, xOffset, yOffset)
		local width = columns * (iconSize + spacing) - spacing
		if self.freeSlot then
			if C["Inventory"].GatherEmpty and (self.bagGroup == 0 or (self.totalFree > 0 and C["Inventory"].ItemFilter)) then
				local numSlots = #self.buttons + 1
				local row = ceil(numSlots / columns)
				local col = numSlots % columns
				if col == 0 then
					col = columns
				end
				local xPos = (col - 1) * (iconSize + spacing)
				local yPos = -1 * (row - 1) * (iconSize + spacing)

				self.freeSlot:ClearAllPoints()
				self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", xPos + xOffset, yPos + yOffset)
				self.freeSlot:Show()

				if height < 0 then
					height = iconSize
				elseif col == 1 then
					height = height + iconSize + spacing
				end
			else
				self.freeSlot:Hide()
			end
		end
		self:SetSize(width + xOffset * 2, height + offset)

		if not gridOnly then
			Module:UpdateAllAnchors()
		end
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		self:CreateBorder()

		if settings.Bags then
			K.CreateMoverFrame(self, nil, true)
		end

		self.iconSize = iconSize
		Module.CreateFreeSlots(self)

		local label
		if strmatch(name, "AmmoItem$") then
			label = K.Class == "HUNTER" and INVTYPE_AMMO or SOUL_SHARDS
		elseif strmatch(name, "Equipment$") then
			label = BAG_FILTER_EQUIPMENT
		elseif name == "BankLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif strmatch(name, "Consumable$") then
			label = BAG_FILTER_CONSUMABLES
		elseif name == "Junk" then
			label = BAG_FILTER_JUNK
		elseif name == "Keyring" then
			label = KEYRING
		elseif strmatch(name, "Goods") then
			label = AUCTION_CATEGORY_TRADE_GOODS
		elseif strmatch(name, "Quest") then
			label = QUESTS_LABEL
		elseif strmatch(name, "Custom%d") then
			label = GetCustomGroupTitle(settings.Index)
		end
		if label then
			self.label = K.CreateFontString(self, 13, label, "OUTLINE", true, "TOPLEFT", 6, -8)
			return
		end

		Module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = Module.CreateCloseButton(self, f)
		if name == "Bag" then
			Module.CreateBagBar(self, settings, NUM_BAG_SLOTS)
			buttons[2] = Module.CreateSortButton(self, name)
			buttons[3] = Module.CreateBagToggle(self)
			buttons[4] = Module.CreateKeyToggle(self)
			buttons[5] = Module.CreateSplitButton(self)
			buttons[6] = Module.CreateFavouriteButton(self)
			buttons[7] = Module.CreateJunkButton(self)
			buttons[8] = Module.CreateDeleteButton(self)
		elseif name == "Bank" then
			Module.CreateBagBar(self, settings, NUM_BANKBAGSLOTS)
			buttons[2] = Module.CreateBagToggle(self)
			buttons[3] = Module.CreateSortButton(self, name)
		end

		for i = 1, #buttons do
			local bu = buttons[i]
			if not bu then
				break
			end

			if i == 1 then
				bu:SetPoint("TOPRIGHT", -6, -6)
			else
				bu:SetPoint("RIGHT", buttons[i - 1], "LEFT", -6, 0)
			end
		end
		self.widgetButtons = buttons

		if name == "Bag" then
			Module.CreateCollapseArrow(self)
		end

		self:HookScript("OnShow", K.RestoreMoverFrame)
	end

	local function updateBagSize(button)
		button:SetSize(iconSize, iconSize)
		if button.glowFrame then
			button.glowFrame:SetSize(iconSize + 8, iconSize + 8)
		end
	end

	function Module:UpdateBagSize()
		iconSize = C["Inventory"].IconSize
		for _, container in pairs(Backpack.contByName) do
			container:ApplyToButtons(updateBagSize)
			if container.freeSlot then
				container.freeSlot:SetSize(iconSize, iconSize)
			end
			if container.BagBar then
				for _, bagButton in pairs(container.BagBar.buttons) do
					bagButton:SetSize(iconSize, iconSize)
				end
				container.BagBar:UpdateAnchor()
			end
			container:OnContentsChanged(true)
		end
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(0)
		self:SetPushedTexture(0)

		self:SetSize(iconSize, iconSize)
		self:CreateBorder()
		self:StyleButton()

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	end

	function BagButton:OnUpdate()
		local id = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		if not id then
			return
		end
		local _, _, quality, _, _, _, _, _, _, _, _, classID, subClassID = GetItemInfo(id)
		if not quality or quality == 1 then
			quality = 0
		end
		local color = K.QualityColors[quality]
		if not self.hidden and not self.notBought then
			self.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		else
			K.SetBorderColor(self.KKUI_Border)
		end

		if classID == LE_ITEM_CLASS_CONTAINER then
			cargBags.BagGroups[self.bagId] = subClassID or 0
		elseif classID == LE_ITEM_CLASS_QUIVER then
			cargBags.BagGroups[self.bagId] = -1
		else
			cargBags.BagGroups[self.bagId] = 0
		end
	end

	-- Sort order
	SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
	C_Container.SetInsertItemsLeftToRight(false)

	-- Init
	C["Inventory"].GatherEmpty = not C["Inventory"].GatherEmpty
	ToggleAllBags()
	C["Inventory"].GatherEmpty = not C["Inventory"].GatherEmpty
	ToggleAllBags()
	Module.initComplete = true

	K:RegisterEvent("TRADE_SHOW", Module.OpenBags)
	-- K:RegisterEvent("TRADE_CLOSED", Module.CloseBags)
	K:RegisterEvent("AUCTION_HOUSE_SHOW", Module.OpenBags)
	K:RegisterEvent("AUCTION_HOUSE_CLOSED", Module.CloseBags)

	-- Update infobar slots
	if _G.KKUI_GoldDataText then
		Backpack.OnOpen = function()
			if not KkthnxUIDB.ShowSlots then
				return
			end
			K.GoldButton_OnEvent()
		end
	end

	-- Fixes
	BankFrame.GetRight = function()
		return f.bank:GetRight()
	end
	BankFrameItemButton_Update = K.Noop

	-- Delay updates for data jam
	local updater = CreateFrame("Frame", nil, f.main)
	updater:Hide()
	updater:SetScript("OnUpdate", function(self, elapsed)
		self.delay = self.delay - elapsed
		if self.delay < 0 then
			Module:UpdateAllBags()
			self:Hide()
		end
	end)

	K:RegisterEvent("GET_ITEM_INFO_RECEIVED", function()
		updater.delay = 1 -- Set the delay to 1 second
		updater:Show()
	end)
end
