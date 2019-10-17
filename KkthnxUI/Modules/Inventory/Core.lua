local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Bags")
local cargBags = cargBags or K.cargBags

local ceil = _G.ceil
local ipairs = _G.ipairs
local strmatch = _G.strmatch
local unpack = _G.unpack

local BAG_ITEM_QUALITY_COLORS = _G.BAG_ITEM_QUALITY_COLORS
local C_NewItems_IsNewItem = _G.C_NewItems.IsNewItem
local C_NewItems_RemoveNewItem = _G.C_NewItems.RemoveNewItem
local C_Timer_After = _G.C_Timer.After
local ClearCursor = _G.ClearCursor
local CreateFrame = _G.CreateFrame
local DeleteCursorItem = _G.DeleteCursorItem
local GetContainerItemID = _G.GetContainerItemID
local GetContainerItemInfo = _G.GetContainerItemInfo
local GetContainerNumSlots = _G.GetContainerNumSlots
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local LE_ITEM_CLASS_ARMOR = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_QUIVER = _G.LE_ITEM_CLASS_QUIVER
local LE_ITEM_CLASS_WEAPON = _G.LE_ITEM_CLASS_WEAPON
local LE_ITEM_QUALITY_POOR = _G.LE_ITEM_QUALITY_POOR
local LE_ITEM_QUALITY_RARE = _G.LE_ITEM_QUALITY_RARE
local PickupContainerItem = _G.PickupContainerItem
local SortBags = _G.SortBags
local SortBankBags = _G.SortBankBags

local bagsFont = K.GetFont(C["UIFonts"].InventoryFonts)
local goldProfit, goldSpent, sortCache, deleteEnable, favouriteEnable = 0, 0, {}

function Module:ReverseSort()
	for bag = 0, 4 do
		local numSlots = GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local texture, _, locked = GetContainerItemInfo(bag, slot)
			if (slot <= numSlots / 2) and texture and not locked and not sortCache["b"..bag.."s"..slot] then
				ClearCursor()
				PickupContainerItem(bag, slot)
				PickupContainerItem(bag, numSlots + 1 - slot)
				sortCache["b"..bag.."s"..slot] = true
				C_Timer_After(0.1, Module.ReverseSort)
				return
			end
		end
	end

	KKUI_Backpack.isSorting = false
	KKUI_Backpack:BAG_UPDATE()
end

function Module:UpdateAnchors(parent, bags)
	local anchor = parent
	for _, bag in ipairs(bags) do
		if bag:GetHeight() > 45 then
			bag:Show()
		else
			bag:Hide()
		end

		if bag:IsShown() then
			bag:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, 5)
			anchor = bag
		end
	end
end

local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or .3)
end

function Module:CreateInfoFrame()
	local infoFrame = CreateFrame("Button", nil, self)
	infoFrame:SetPoint("TOPLEFT", 10, 0)
	infoFrame:SetSize(200, 32)

	local icon = infoFrame:CreateTexture()
	icon:SetSize(24, 24)
	icon:SetPoint("LEFT")
	icon:SetTexture("Interface\\Minimap\\Tracking\\None")
	icon:SetTexCoord(1, 0, 0, 1)

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search.highlightFunction = highlightFunction
	search.isGlobal = true
	search:SetPoint("LEFT", 0, 5)
	search:DisableDrawLayer("BACKGROUND")
	search:CreateBackdrop()
	search.Backdrop:SetPoint("TOPLEFT", -5, -7)
	search.Backdrop:SetPoint("BOTTOMRIGHT", 5, 7)

	-- local tag = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
	-- tag:SetFont(C.Media.Font, 12, "OUTLINE")
	-- tag:SetShadowOffset(0, 0)
	-- tag:SetPoint("RIGHT", -5, 0)

	-- Need to turn this into a plugin.
	do
		local gold = CreateFrame("Button", nil, infoFrame)
		gold:RegisterForClicks("AnyUp")

		gold.text = infoFrame:CreateFontString(nil, "OVERLAY")
		gold.text:SetPoint("RIGHT", -5, 0)
		gold.text:SetFontObject(bagsFont)
		gold.text:SetFont(select(1, gold.text:GetFont()), 12, select(3, gold.text:GetFont()))

		gold:SetAllPoints(gold.text)

		local function OnGoldEvent(self)
			if not _G.IsLoggedIn() then
				return
			end

			local NewMoney = GetMoney()
			KkthnxUIData = KkthnxUIData or {}
			KkthnxUIData["Gold"] = KkthnxUIData["Gold"] or {}
			KkthnxUIData["Gold"][K.Realm] = KkthnxUIData["Gold"][K.Realm] or {}
			KkthnxUIData["Gold"][K.Realm][K.Name] = KkthnxUIData["Gold"][K.Realm][K.Name] or NewMoney

			KkthnxUIData["Class"] = KkthnxUIData["Class"] or {}
			KkthnxUIData["Class"][K.Realm] = KkthnxUIData["Class"][K.Realm] or {}
			KkthnxUIData["Class"][K.Realm][K.Name] = K.Class

			local OldMoney = KkthnxUIData["Gold"][K.Realm][K.Name] or NewMoney

			local Change = NewMoney - OldMoney -- Positive If We Gain Money
			if OldMoney > NewMoney then -- Lost Money
				goldSpent = goldSpent - Change
			else -- Gained Moeny
				goldProfit = goldProfit + Change
			end

			self.text:SetText(K.FormatMoney(NewMoney))

			KkthnxUIData["Gold"][K.Realm][K.Name] = NewMoney
		end

		local function OnGoldClick(self, btn)
			if btn == "RightButton" then
				if IsShiftKeyDown() then
					KkthnxUIData.Gold = nil
					OnGoldEvent(self)
					GameTooltip:Hide()
				elseif _G.IsControlKeyDown() then
					goldProfit = 0
					goldSpent = 0
					GameTooltip:Hide()
				end
			end
		end

		local myGold = {}
		local function OnGoldEnter(self)
			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint(K.GetAnchors(self))
			GameTooltip:ClearLines()

			GameTooltip:AddLine("Session:")
			GameTooltip:AddDoubleLine("Earned:", K.FormatMoney(goldProfit), 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine("Spent:", K.FormatMoney(goldSpent), 1, 1, 1, 1, 1, 1)
			if goldProfit < goldSpent then
				GameTooltip:AddDoubleLine("Deficit:", K.FormatMoney(goldProfit - goldSpent), 1, 0, 0, 1, 1, 1)
			elseif (goldProfit - goldSpent)>0 then
				GameTooltip:AddDoubleLine("Profit:", K.FormatMoney(goldProfit - goldSpent), 0, 1, 0, 1, 1, 1)
			end
			GameTooltip:AddLine(" ")

			local totalGold = 0
			GameTooltip:AddLine("Character: ")

			table.wipe(myGold)
			for k, _ in pairs(KkthnxUIData["Gold"][K.Realm]) do
				if KkthnxUIData["Gold"][K.Realm][k] then
					local class = KkthnxUIData["Class"][K.Realm][k] or "PRIEST"
					local color = class and (_G.CUSTOM_CLASS_COLORS and _G.CUSTOM_CLASS_COLORS[class] or _G.RAID_CLASS_COLORS[class])
					table.insert(myGold, {name = k, amount = KkthnxUIData["Gold"][K.Realm][k], amountText = K.FormatMoney(KkthnxUIData["Gold"][K.Realm][k]), r = color.r, g = color.g, b = color.b,})
				end
				totalGold = totalGold + KkthnxUIData["Gold"][K.Realm][k]
			end

			for _, g in ipairs(myGold) do
				GameTooltip:AddDoubleLine(g.name == K.Name and g.name.." |TInterface\\COMMON\\Indicator-Green:14|t" or g.name, g.amountText, g.r, g.g, g.b, 1, 1, 1)
			end

			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Server: ")
			GameTooltip:AddDoubleLine("Total: ", K.FormatMoney(totalGold), 1, 1, 1, 1, 1, 1)

			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(string.join("", "|cffaaaaaa", "Reset Counters: Hold Shift + Left Click", "|r"))
			GameTooltip:AddLine(string.join("", "|cffaaaaaa", "Reset Data: Hold Shift + Right Click", "|r"))

			GameTooltip:Show()
		end

		local function OnGoldLeave()
			GameTooltip:Hide()
		end

		gold:RegisterEvent("PLAYER_ENTERING_WORLD")
		gold:RegisterEvent("PLAYER_MONEY")
		gold:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
		gold:RegisterEvent("SEND_MAIL_COD_CHANGED")
		gold:RegisterEvent("PLAYER_TRADE_MONEY")
		gold:RegisterEvent("TRADE_MONEY_CHANGED")

		gold:SetScript("OnEvent", OnGoldEvent)
		gold:SetScript("OnMouseUp", OnGoldClick)
		gold:SetScript("OnEnter", OnGoldEnter)
		gold:SetScript("OnLeave", OnGoldLeave)
	end
end

function Module:CreateBagBar(settings, columns)
	local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
	local width, height = bagBar:LayoutButtons("grid", columns, 5, 5, -5)
	bagBar:SetSize(width + 10, height + 10)
	bagBar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -5)
	bagBar:CreateBorder()
	bagBar.highlightFunction = highlightFunction
	bagBar.isGlobal = true
	bagBar:Hide()

	self.BagBar = bagBar
end

function Module:CreateCloseButton()
	local closeButton = CreateFrame("Button", nil, self)
	closeButton:SetSize(18, 18)
	closeButton:CreateBorder()
	closeButton:CreateInnerShadow()
	closeButton:StyleButton()

	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetAllPoints()
	closeButton.Icon:SetTexCoord(unpack(K.TexCoords))
	closeButton.Icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32")

	closeButton:SetScript("OnClick", CloseAllBags)
	closeButton.title = CLOSE
	K.AddTooltip(closeButton, "ANCHOR_TOP")

	return closeButton
end

function Module:CreateRestoreButton(f)
	local restoreButton = CreateFrame("Button", nil, self)
	restoreButton:SetSize(18, 18)
	restoreButton:CreateBorder()
	restoreButton:CreateInnerShadow()
	restoreButton:StyleButton()

	restoreButton.Icon = restoreButton:CreateTexture(nil, "ARTWORK")
	restoreButton.Icon:SetAllPoints()
	restoreButton.Icon:SetTexCoord(unpack(K.TexCoords))
	restoreButton.Icon:SetAtlas("transmog-icon-revert")

	restoreButton:SetScript("OnClick", function()
		KkthnxUIData[K.Realm][K.Name]["TempAnchor"][f.main:GetName()] = nil
		KkthnxUIData[K.Realm][K.Name]["TempAnchor"][f.bank:GetName()] = nil
		f.main:ClearAllPoints()
		f.main:SetPoint("BOTTOMRIGHT", -50, 320)
		f.bank:ClearAllPoints()
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -10, 0)
		PlaySound(SOUNDKIT.IG_MINIMAP_OPEN)
	end)
	restoreButton.title = RESET
	K.AddTooltip(restoreButton, "ANCHOR_TOP")

	return restoreButton
end

function Module:CreateBagToggle()
	local bagToggleButton = CreateFrame("Button", nil, self)
	bagToggleButton:SetSize(18, 18)
	bagToggleButton:CreateBorder()
	bagToggleButton:CreateInnerShadow()
	bagToggleButton:StyleButton()

	bagToggleButton.Icon = bagToggleButton:CreateTexture(nil, "ARTWORK")
	bagToggleButton.Icon:SetAllPoints()
	bagToggleButton.Icon:SetTexCoord(unpack(K.TexCoords))
	bagToggleButton.Icon:SetTexture("Interface\\Buttons\\Button-Backpack-Up")

	bagToggleButton:SetScript("OnClick", function()
		ToggleFrame(self.BagBar)
		if self.BagBar:IsShown() then
			bagToggleButton:SetBackdropBorderColor(1, .8, 0)
			PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
		else
			bagToggleButton:SetBackdropBorderColor()
			PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
		end
	end)
	bagToggleButton.title = BACKPACK_TOOLTIP
	K.AddTooltip(bagToggleButton, "ANCHOR_TOP")

	return bagToggleButton
end

function Module:CreateSortButton(name)
	local sortButton = CreateFrame("Button", nil, self)
	sortButton:SetSize(18, 18)
	sortButton:CreateBorder()
	sortButton:CreateInnerShadow()
	sortButton:StyleButton()

	sortButton.Icon = sortButton:CreateTexture(nil, "ARTWORK")
	sortButton.Icon:SetAllPoints()
	sortButton.Icon:SetTexCoord(unpack(K.TexCoords))
	sortButton.Icon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\INV_Pet_Broom.blp")

	sortButton:SetScript("OnClick", function()
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end

		if name == "Bank" then
			SortBankBags()
		else
			if C["Inventory"].ReverseSort then
				SortBags()
				wipe(sortCache)
				KKUI_Backpack.isSorting = true
				C_Timer_After(0.5, Module.ReverseSort)
			else
				SortBags()
			end
		end
	end)
	sortButton.title = "Sort"
	K.AddTooltip(sortButton, "ANCHOR_TOP")

	return sortButton
end

function Module:CreateDeleteButton()
	local enabledText = K.SystemColor..L["Delete Mode Enabled"]

	local deleteButton = CreateFrame("Button", nil, self)
	deleteButton:SetSize(18, 18)
	deleteButton:CreateBorder()
	deleteButton:CreateInnerShadow()
	deleteButton:StyleButton()

	deleteButton.Icon = deleteButton:CreateTexture(nil, "ARTWORK")
	deleteButton.Icon:SetPoint("TOPLEFT", 3, -2)
	deleteButton.Icon:SetPoint("BOTTOMRIGHT", -1, 2)
	deleteButton.Icon:SetTexCoord(unpack(K.TexCoords))
	deleteButton.Icon:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")

	deleteButton:SetScript("OnClick", function(self)
		deleteEnable = not deleteEnable
		if deleteEnable then
			self:SetBackdropBorderColor(1, .8, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			self:SetBackdropBorderColor()
			self.Icon:SetDesaturated(false)
			self.text = nil
		end
		self:GetScript("OnEnter")(self)
	end)
	deleteButton.title = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t"..L["Item Delete Mode"]
	K.AddTooltip(deleteButton, "ANCHOR_TOP")

	return deleteButton
end

local function deleteButtonOnClick(self)
	if not deleteEnable then
		return
	end

	local texture, _, _, quality = GetContainerItemInfo(self.bagID, self.slotID)
	if IsControlKeyDown() and IsAltKeyDown() and texture and (quality < LE_ITEM_QUALITY_RARE) then
		PickupContainerItem(self.bagID, self.slotID)
		DeleteCursorItem()
	end
end

function Module:CreateFavouriteButton()
	local enabledText = K.SystemColor..L["Favourite Mode Enabled"]

	local favouriteButton = CreateFrame("Button", nil, self)
	favouriteButton:SetSize(18, 18)
	favouriteButton:CreateBorder()
	favouriteButton:CreateInnerShadow()
	favouriteButton:StyleButton()

	favouriteButton.Icon = favouriteButton:CreateTexture(nil, "ARTWORK")
	favouriteButton.Icon:SetPoint("TOPLEFT", -5, 0)
	favouriteButton.Icon:SetPoint("BOTTOMRIGHT", 5, -5)
	favouriteButton.Icon:SetTexCoord(unpack(K.TexCoords))
	favouriteButton.Icon:SetTexture("Interface\\Common\\friendship-heart")

	favouriteButton:SetScript("OnClick", function(self)
		favouriteEnable = not favouriteEnable
		if favouriteEnable then
			self:SetBackdropBorderColor(1, .8, 0)
			self.Icon:SetDesaturated(true)
			self.text = enabledText
		else
			self:SetBackdropBorderColor()
			self.Icon:SetDesaturated(false)
			self.text = nil
		end
		self:GetScript("OnEnter")(self)
	end)
	favouriteButton.title = L["Favourite Mode"]
	K.AddTooltip(favouriteButton, "ANCHOR_TOP")

	return favouriteButton
end

local function favouriteOnClick(self)
	if not favouriteEnable then
		return
	end

	local texture, _, _, quality, _, _, _, _, _, itemID = GetContainerItemInfo(self.bagID, self.slotID)
	if texture and quality > LE_ITEM_QUALITY_POOR then
		if KkthnxUIData[K.Realm][K.Name].FavouriteItems[itemID] then
			KkthnxUIData[K.Realm][K.Name].FavouriteItems[itemID] = nil
		else
			KkthnxUIData[K.Realm][K.Name].FavouriteItems[itemID] = true
		end
		ClearCursor()
		KKUI_Backpack:BAG_UPDATE()
	end
end

function Module:ButtonOnClick(btn)
	if btn ~= "LeftButton" then
		return
	end

	deleteButtonOnClick(self)
	favouriteOnClick(self)
end

function Module:GetContainerEmptySlot(bagID)
	local bagType = Module.BagsType[bagID]
	for slotID = 1, GetContainerNumSlots(bagID) do
		if not GetContainerItemID(bagID, slotID) and bagType == 0 then
			return slotID
		end
	end
end

function Module:GetEmptySlot(name)
	if name == "Main" then
		for bagID = 0, 4 do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	elseif name == "Bank" then
		local slotID = Module:GetContainerEmptySlot(-1)
		if slotID then
			return -1, slotID
		end

		for bagID = 5, 11 do
			local slotID = Module:GetContainerEmptySlot(bagID)
			if slotID then
				return bagID, slotID
			end
		end
	end
end

function Module:FreeSlotOnDrop()
	local bagID, slotID = Module:GetEmptySlot(self.__name)
	if slotID then
		PickupContainerItem(bagID, slotID)
	end
end

local freeSlotContainer = {
	["Main"] = true,
	["Bank"] = true,
}

function Module:CreateFreeSlots()
	local name = self.name
	if not freeSlotContainer[name] then
		return
	end

	local slot = CreateFrame("Button", name.."FreeSlot", self)
	slot:SetSize(self.iconSize, self.iconSize)
	slot:CreateBorder()
	slot:CreateInnerShadow()
	slot:SetScript("OnMouseUp", Module.FreeSlotOnDrop)
	slot:SetScript("OnReceiveDrag", Module.FreeSlotOnDrop)
	K.AddTooltip(slot, "ANCHOR_RIGHT", "FreeSlots")
	slot.__name = name

	local tag = self:SpawnPlugin("TagDisplay", "[space]", slot)
	tag:SetFontObject(bagsFont)
	tag:SetFont(select(1, tag:GetFont()), 16, select(3, tag:GetFont()))
	tag:SetPoint("CENTER", 1, 0)
	tag.__name = name

	self.freeSlot = slot
end

function Module:OnEnable()
	if not C["Inventory"].Enable then
		return
	end

	-- Settings
	local bagsWidth = C["Inventory"].BagsWidth
	local bankWidth = C["Inventory"].BankWidth
	local iconSize = C["Inventory"].IconSize
	local showItemLevel = C["Inventory"].BagsiLvl
	local deleteButton = C["Inventory"].DeleteButton
	-- local itemSetFilter = C["Inventory"].ItemSetFilter

	-- Init
	local Backpack = cargBags:NewImplementation("KKUI_Backpack")
	Backpack:RegisterBlizzard()
	Backpack:SetScale(1)

	Backpack:HookScript("OnShow", function()
		PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
	end)

	Backpack:HookScript("OnHide", function()
		PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
	end)

	Module.BagsType = {}
	Module.BagsType[0] = 0
	Module.BagsType[-1] = 0

	local f = {}
	local onlyBags, bagAmmo, bagEquipment, bagConsumble, bagTradeGoods, bagQuestItem, bagsJunk, onlyBank, bankAmmo, bankLegendary, bankEquipment, bankConsumble, onlyReagent, bagFavourite, bankFavourite = self:GetFilters()
	function Backpack:OnInit()
		local MyContainer = self:GetContainerClass()

		f.main = MyContainer:New("Main", {Columns = bagsWidth, Bags = "bags"})
		f.main:SetFilter(onlyBags, true)
		f.main:SetPoint("BOTTOMRIGHT", -50, 320)

		f.junk = MyContainer:New("Junk", {Columns = bagsWidth, Parent = f.main})
		f.junk:SetFilter(bagsJunk, true)

		f.bagFavourite = MyContainer:New("BagFavourite", {Columns = bagsWidth, Parent = f.main})
		f.bagFavourite:SetFilter(bagFavourite, true)

		f.ammoItem = MyContainer:New("AmmoItem", {Columns = bagsWidth, Parent = f.main})
		f.ammoItem:SetFilter(bagAmmo, true)

		f.equipment = MyContainer:New("Equipment", {Columns = bagsWidth, Parent = f.main})
		f.equipment:SetFilter(bagEquipment, true)

		f.consumble = MyContainer:New("Consumble", {Columns = bagsWidth, Parent = f.main})
		f.consumble:SetFilter(bagConsumble, true)

		f.tradegoods = MyContainer:New("TradeGoods", {Columns = bagsWidth, Parent = f.main})
		f.tradegoods:SetFilter(bagTradeGoods, true)

		f.questitem = MyContainer:New("QuestItem", {Columns = bagsWidth, Parent = f.main})
		f.questitem:SetFilter(bagQuestItem, true)

		f.bank = MyContainer:New("Bank", {Columns = bankWidth, Bags = "bank"})
		f.bank:SetFilter(onlyBank, true)
		f.bank:SetPoint("BOTTOMRIGHT", f.main, "BOTTOMLEFT", -10, 0)
		f.bank:Hide()

		f.bankFavourite = MyContainer:New("BankFavourite", {Columns = bankWidth, Parent = f.bank})
		f.bankFavourite:SetFilter(bankFavourite, true)

		f.bankAmmoItem = MyContainer:New("BankAmmoItem", {Columns = bankWidth, Parent = f.bank})
		f.bankAmmoItem:SetFilter(bankAmmo, true)

		f.bankLegendary = MyContainer:New("BankLegendary", {Columns = bankWidth, Parent = f.bank})
		f.bankLegendary:SetFilter(bankLegendary, true)

		f.bankEquipment = MyContainer:New("BankEquipment", {Columns = bankWidth, Parent = f.bank})
		f.bankEquipment:SetFilter(bankEquipment, true)

		f.bankConsumble = MyContainer:New("BankConsumble", {Columns = bankWidth, Parent = f.bank})
		f.bankConsumble:SetFilter(bankConsumble, true)
	end

	function Backpack:OnBankOpened()
		self:GetContainer("Bank"):Show()
	end

	function Backpack:OnBankClosed()
		self:GetContainer("Bank"):Hide()
	end

	local MyButton = Backpack:GetItemButtonClass()
	MyButton:Scaffold("Default")

	function MyButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)
		self:SetSize(iconSize, iconSize)

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))
		self.Count:SetPoint("BOTTOMRIGHT", 1, 1)
		self.Count:SetFontObject(bagsFont)

		self:CreateBorder()
		self:CreateInnerShadow()

		self.junkIcon = self:CreateTexture(nil, "ARTWORK")
		self.junkIcon:SetAtlas("bags-junkcoin")
		self.junkIcon:SetSize(20, 20)
		self.junkIcon:SetPoint("TOPRIGHT", 1, 0)

		self.Quest = self:CreateTexture(nil, "ARTWORK")
		self.Quest:SetSize(26, 26)
		self.Quest:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
		self.Quest:ClearAllPoints()
		self.Quest:SetPoint("LEFT", self, "LEFT", 0, 1)

		self.Favourite = self:CreateTexture(nil, "OVERLAY", nil, 2)
		self.Favourite:SetAtlas("collections-icon-favorites")
		self.Favourite:SetSize(24, 24)
		self.Favourite:SetPoint("TOPLEFT", -12, 9)

		if showItemLevel then
			self.iLvl = K.CreateFontString(self, 12, "", "OUTLINE", false, "BOTTOMLEFT", 1, 1)
			self.iLvl:SetFontObject(bagsFont)
			self.iLvl:SetFont(select(1, self.iLvl:GetFont()), 12, select(3, self.iLvl:GetFont()))
		end

		self.glowFrame = self:CreateTexture(nil, "OVERLAY")
		self.glowFrame:SetInside(self, 0, 0)
		self.glowFrame:SetAtlas("bags-glow-white")

		self.glowFrame.Animation = self.glowFrame:CreateAnimationGroup()
		self.glowFrame.Animation:SetLooping("BOUNCE")

		self.glowFrame.Animation.FadeOut = self.glowFrame.Animation:CreateAnimation("Alpha")
		self.glowFrame.Animation.FadeOut:SetFromAlpha(1)
		self.glowFrame.Animation.FadeOut:SetToAlpha(0.3)
		self.glowFrame.Animation.FadeOut:SetDuration(0.6)
		self.glowFrame.Animation.FadeOut:SetSmoothing("IN_OUT")

		self:HookScript("OnHide", function()
			if self.glowFrame and self.glowFrame.Animation:IsPlaying() then
				self.glowFrame.Animation:Stop()
				self.glowFrame.Animation.Playing = false
				self.glowFrame:Hide()
			end
		end)

		self:HookScript("OnClick", Module.ButtonOnClick)
	end

	function MyButton:ItemOnEnter()
		if self.glowFrame and self.glowFrame.Animation then
			self.glowFrame.Animation:Stop()
			self.glowFrame.Animation.Playing = false
			self.glowFrame:Hide()
			-- Clear things on blizzard side too.
			C_NewItems_RemoveNewItem(self.bagID, self.slotID)
		end
	end

	local bagTypeColor = {
		[-1] = {.67, .83, .45, .25},
		[0] = {0, 0, 0, .25},
		[1] = {.53, .53, .93, .25},
		[2] = {0, .5, 0, .25},
		[3] = {0, .5, .8, .25},
	}

	function MyButton:OnUpdate(item)
		if MerchantFrame:IsShown() then
			if item.isInSet then
				self:SetAlpha(.5)
			else
				self:SetAlpha(1)
			end
		end

		if MerchantFrame:IsShown() and item.rarity == LE_ITEM_QUALITY_POOR and item.sellPrice > 0 then
			self.junkIcon:SetAlpha(1)
		else
			self.junkIcon:SetAlpha(0)
		end

		if KkthnxUIData[K.Realm][K.Name].FavouriteItems[item.id] then
			self.Favourite:SetAlpha(1)
		else
			self.Favourite:SetAlpha(0)
		end

		if showItemLevel then
			if item.link and item.level and item.rarity > 1 and (item.classID == LE_ITEM_CLASS_WEAPON or item.classID == LE_ITEM_CLASS_ARMOR) then
				local level = item.level
				local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
				self.iLvl:SetText(level)
				self.iLvl:SetTextColor(color.r, color.g, color.b)
			else
				self.iLvl:SetText("")
			end
		end

		if self.glowFrame then
			if C_NewItems_IsNewItem(item.bagID, item.slotID) and self.glowFrame and self.glowFrame.Animation then
				self.glowFrame:Show()
				self.glowFrame.Animation:Play()
				self.glowFrame.Animation.Playing = true
			else
				self.glowFrame.Animation:Stop()
				self.glowFrame.Animation.Playing = false
				self.glowFrame:Hide()
			end
		end

		if not C["Inventory"].SpecialBagsColor then
			local bagType = Module.BagsType[item.bagID]
			local color = bagTypeColor[bagType] or bagTypeColor[0]
			self:SetBackdropColor(unpack(color))
		else
			self:SetBackdropColor(0.04, 0.04, 0.04, 0.9)
		end
	end

	function MyButton:OnUpdateQuest(item)
		self.Quest:SetAlpha(0)

		if item.isQuestItem then
			self:SetBackdropBorderColor(1, 0.30, 0.30)
			self.glowFrame:SetVertexColor(1, 0.30, 0.30)
			self.Quest:SetAlpha(1)
		elseif item.rarity and item.rarity > -1 then
			local color = BAG_ITEM_QUALITY_COLORS[item.rarity]
			self:SetBackdropBorderColor(color.r, color.g, color.b)
			self.glowFrame:SetVertexColor(color.r, color.g, color.b)
		else
			self:SetBackdropBorderColor()
		end
	end

	local MyContainer = Backpack:GetContainerClass()
	function MyContainer:OnContentsChanged()
		self:SortButtons("bagSlot")

		local columns = self.Settings.Columns
		local offset = 38
		local spacing = 5
		local xOffset = 5
		local yOffset = -offset + spacing
		local width, height = self:LayoutButtons("grid", columns, spacing, xOffset, yOffset)
		if self.freeSlot then
			if C["Inventory"].GatherEmpty then
				local numSlots = #self.buttons + 1
				local row = ceil(numSlots / columns)
				local col = numSlots % columns
				if col == 0 then
					col = columns
				end

				local xPos = (col-1) * (iconSize + spacing)
				local yPos = -1 * (row-1) * (iconSize + spacing)

				self.freeSlot:ClearAllPoints()
				self.freeSlot:SetPoint("TOPLEFT", self, "TOPLEFT", xPos+xOffset, yPos+yOffset)
				self.freeSlot:Show()

				if height < 0 then
					width, height = columns * (iconSize+spacing)-spacing, iconSize
				elseif col == 1 then
					height = height + iconSize + spacing
				end
			else
				self.freeSlot:Hide()
			end
		end
		self:SetSize(width + xOffset * 2, height + offset)

		Module:UpdateAnchors(f.main, {f.ammoItem, f.equipment, f.bagFavourite, f.consumble, f.tradegoods, f.questitem, f.junk})
		Module:UpdateAnchors(f.bank, {f.bankAmmoItem, f.bankEquipment, f.bankLegendary, f.bankFavourite, f.bankConsumble})
	end

	function MyContainer:OnCreate(name, settings)
		self.Settings = settings
		self:SetParent(settings.Parent or Backpack)
		self:SetFrameStrata("HIGH")
		self:SetClampedToScreen(true)
		self:CreateBorder()
		K.CreateMoverFrame(self, settings.Parent, true)

		local label
		if strmatch(name, "AmmoItem$") then
			label = K.Class == "HUNTER" and INVTYPE_AMMO or SOUL_SHARDS
		elseif strmatch(name, "Equipment$") then
			--if itemSetFilter then
			--	label = L["Equipement Set"]
			--else
			label = BAG_FILTER_EQUIPMENT
			--end
		elseif name == "BankLegendary" then
			label = LOOT_JOURNAL_LEGENDARIES
		elseif strmatch(name, "Consumble$") then
			label = BAG_FILTER_CONSUMABLES
		elseif strmatch(name, "TradeGoods$") then
			label = BAG_FILTER_TRADE_GOODS
		elseif strmatch(name, "QuestItem$") then
			label = AUCTION_CATEGORY_QUEST_ITEMS
		elseif name == "Junk" then
			label = BAG_FILTER_JUNK
		elseif strmatch(name, "Favourite") then
			label = PREFERENCES
		end

		if label then
			K.CreateFontString(self, 13, label, "OUTLINE", true, "TOPLEFT", 5, -8)
			-- self:SetFontObject(bagsFont)
			-- self:SetFont(select(1, self:GetFont()), 18, select(3, self:GetFont()))
			return
		end

		Module.CreateInfoFrame(self)

		local buttons = {}
		buttons[1] = Module.CreateCloseButton(self)
		if name == "Main" then
			Module.CreateBagBar(self, settings, 4)
			buttons[2] = Module.CreateRestoreButton(self, f)
			buttons[3] = Module.CreateBagToggle(self)
			buttons[4] = Module.CreateSortButton(self, name)
			buttons[5] = Module.CreateFavouriteButton(self)
			if deleteButton then
				buttons[6] = Module.CreateDeleteButton(self)
			end
		elseif name == "Bank" then
			Module.CreateBagBar(self, settings, 7)
			buttons[2] = Module.CreateBagToggle(self)
			buttons[3] = Module.CreateSortButton(self, name)
		end

		for i = 1, 6 do
			local bu = buttons[i]
			if not bu then break end
			if i == 1 then
				bu:SetPoint("TOPRIGHT", -6, -6)
			else
				bu:SetPoint("RIGHT", buttons[i-1], "LEFT", -5, 0)
			end
		end

		self:HookScript("OnShow", K.RestoreMoverFrame)

		self.iconSize = iconSize
		Module.CreateFreeSlots(self)
	end

	local BagButton = Backpack:GetClass("BagButton", true, "BagButton")
	function BagButton:OnCreate()
		self:SetNormalTexture(nil)
		self:SetPushedTexture(nil)

		self:SetSize(iconSize, iconSize)
		self:CreateBorder()
		self:CreateInnerShadow()

		self.Icon:SetAllPoints()
		self.Icon:SetTexCoord(unpack(K.TexCoords))
	end

	function BagButton:OnUpdate()
		local id = GetInventoryItemID("player", (self.GetInventorySlot and self:GetInventorySlot()) or self.invID)
		if not id then
			return
		end

		local _, _, quality, _, _, _, _, _, _, _, _, classID, subClassID = GetItemInfo(id)
		quality = quality or 0
		if quality == 1 then
			quality = 0
		end

		local color = BAG_ITEM_QUALITY_COLORS[quality]
		if not self.hidden and not self.notBought then
			self:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			self:SetBackdropBorderColor()
		end

		if classID == LE_ITEM_CLASS_CONTAINER then
			Module.BagsType[self.bagID] = subClassID or 0
		elseif classID == LE_ITEM_CLASS_QUIVER then
			Module.BagsType[self.bagID] = -1
		else
			Module.BagsType[self.bagID] = 0
		end
	end

	-- Fixes
	ToggleAllBags()
	ToggleAllBags()
	BankFrame.GetRight = function()
		return f.bank:GetRight()
	end
	BankFrameItemButton_Update = K.Noop

	SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
	SetInsertItemsLeftToRight(false)
end