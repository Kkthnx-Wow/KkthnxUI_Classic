local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local math_floor = math.floor
local table_insert = table.insert

local ADD = ADD
local CLOSE = CLOSE
local CreateFrame = CreateFrame
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local GameTooltip = GameTooltip
local GetInventoryItemTexture = GetInventoryItemTexture
local GetItemInfo = C_Item.GetItemInfo
local INVTYPE_CLOAK = INVTYPE_CLOAK
local INVTYPE_FINGER = INVTYPE_FINGER
local INVTYPE_TRINKET = INVTYPE_TRINKET
local INVTYPE_WAIST = INVTYPE_WAIST
local KEY_NUMLOCK_MAC = KEY_NUMLOCK_MAC
local NO = NO
local OKAY = OKAY
local PlaySound = PlaySound
local RESET = RESET
local ReloadUI = ReloadUI
local SOUNDKIT = SOUNDKIT
local SlashCmdList = SlashCmdList
local StaticPopupDialogs = StaticPopupDialogs
local StaticPopup_Show = StaticPopup_Show
local UIErrorsFrame = UIErrorsFrame
local UISpecialFrames = UISpecialFrames
local YES = YES

local r, g, b = K.r, K.g, K.b
local f

local function clearEditBoxFocus(self)
	if self.ClearFocus then
		self:ClearFocus()
	end
end

local function dropdownOptionOnClick(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	local options = self.__owner.options
	for _, option in ipairs(options) do
		if option == self then
			option.KKUI_Background:SetVertexColor(1, 0.8, 0, 0.3)
			option.selected = true
		else
			option.KKUI_Background:SetVertexColor(0.04, 0.04, 0.04, 0.9)
			option.selected = false
		end
	end
	self.__owner.Text:SetText(self.text)
	self:GetParent():Hide()
end

local function dropdownOptionOnEnter(self)
	if not self.selected then
		self.KKUI_Background:SetVertexColor(1, 1, 1, 0.25)
	end
end

local function dropdownOptionOnLeave(self)
	if not self.selected then
		self.KKUI_Background:SetVertexColor(0.04, 0.04, 0.04, 0.9)
	end
end

local function dropdownButtonOnShow(self)
	self.__list:Hide()
end

local function dropdownButtonOnClick(self)
	PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	K.TogglePanel(self.__list)
end

-- Elements
local function createLabel(parent, text, tooltip)
	local label = K.CreateFontString(parent, 14, text, "", "system", "CENTER", 0, 25)
	if tooltip then
		local frame = CreateFrame("Frame", nil, parent)
		frame:SetAllPoints(label)
		frame.text = text
		frame.tip = tooltip
		frame:SetScript("OnEnter", function(self)
			GameTooltip:ClearLines()
			GameTooltip:SetOwner(self:GetParent(), "ANCHOR_RIGHT", 0, 3)
			GameTooltip:AddLine(self.text)
			GameTooltip:AddLine(self.tip, 0.5, 0.7, 1, 1)
			GameTooltip:Show()
		end)
		frame:SetScript("OnLeave", K.HideTooltip)
	end
	return label
end

local function createEditBox(parent, label, posX, posY, tooltip, width, height)
	width = width or 90
	height = height or 24
	local editBox = CreateFrame("EditBox", nil, parent)
	editBox:SetSize(width, height)
	editBox:SetPoint("TOPLEFT", posX, posY)
	editBox:SetAutoFocus(false)
	editBox:SetTextInsets(5, 5, 0, 0)
	editBox:SetFontObject(K.UIFont)
	editBox:SetMaxLetters(255)
	createLabel(editBox, label, tooltip)
	editBox.bg = CreateFrame("Frame", nil, editBox, "BackdropTemplate")
	editBox.bg:SetAllPoints(editBox)
	editBox.bg:SetFrameLevel(editBox:GetFrameLevel())
	editBox.bg:CreateBorder()
	editBox:SetScript("OnEscapePressed", clearEditBoxFocus)
	editBox:SetScript("OnEnterPressed", clearEditBoxFocus)
	editBox.Type = "EditBox"
	return editBox
end

local function createCheckBox(parent, label, posX, posY, tooltip)
	local checkBox = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	checkBox:SetSize(20, 20)
	checkBox:SetPoint("TOPLEFT", posX, posY)
	checkBox:SetHitRectInsets(-5, -5, -5, -5)
	createLabel(checkBox, label, tooltip)
	checkBox:SetNormalTexture(0)
	checkBox:SetPushedTexture(0)
	local bg = CreateFrame("Frame", nil, checkBox, "BackdropTemplate")
	bg:SetAllPoints(checkBox)
	bg:SetFrameLevel(parent:GetFrameLevel())
	bg:CreateBorder()
	checkBox.bg = bg
	checkBox:SetHighlightTexture(checkBox:IsObjectType("CheckButton") and "Interface\\Buttons\\CheckButtonHilight" or "Interface\\Buttons\\ButtonHilight-Square")
	local hl = checkBox:GetHighlightTexture()
	hl:SetBlendMode("ADD")
	hl:SetAllPoints()
	local checkMark = checkBox:GetCheckedTexture()
	checkMark:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\UI-CheckBox-Check")
	checkMark:SetTexCoord(0, 1, 0, 1)
	checkMark:SetDesaturated(true)
	checkMark:SetVertexColor(1, 1, 0)
	checkBox.Type = "CheckBox"
	return checkBox
end

local function createDropdown(parent, label, posX, posY, optionsData, tooltip, width, height)
	width = width or 90
	height = height or 24
	local dropdown = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	dropdown:SetSize(width, height)
	dropdown:SetPoint("TOPLEFT", posX, posY)
	createLabel(dropdown, label, tooltip)
	dropdown:CreateBorder()
	dropdown.Text = K.CreateFontString(dropdown, 14, "", "", false, "LEFT", 5, 0)
	dropdown.Text:SetPoint("RIGHT", -30, 0)
	dropdown.options = {}
	local button = CreateFrame("Button", nil, dropdown)
	button:SetPoint("RIGHT", -4, 0)
	K.ReskinArrow(button, "down")
	button:SetSize(16, 16)
	local list = CreateFrame("Frame", nil, dropdown, "BackdropTemplate")
	list:SetPoint("TOP", dropdown, "BOTTOM", 0, -6)
	list:CreateBorder()
	list:Hide()
	button.__list = list
	button:SetScript("OnShow", dropdownButtonOnShow)
	button:SetScript("OnClick", dropdownButtonOnClick)
	dropdown.button = button
	local options = {}
	local index = 0
	for key, value in pairs(optionsData) do
		options[key] = CreateFrame("Button", nil, list, "BackdropTemplate")
		options[key]:SetPoint("TOPLEFT", 4, -4 - (key - 1) * (height + 6))
		options[key]:SetSize(width - 8, height)
		options[key]:CreateBorder()
		local optionText = K.CreateFontString(options[key], 14, value, "", false, "LEFT", 5, 0)
		optionText:SetPoint("RIGHT", -5, 0)
		options[key].text = value
		options[key].index = key
		options[key].__owner = dropdown
		options[key]:SetScript("OnClick", dropdownOptionOnClick)
		options[key]:SetScript("OnEnter", dropdownOptionOnEnter)
		options[key]:SetScript("OnLeave", dropdownOptionOnLeave)
		dropdown.options[key] = options[key]
		index = index + 1
	end
	list:SetSize(width, index * (height + 5) + 6)
	dropdown.Type = "Dropdown"
	return dropdown
end

local function clearInputs(element)
	if element.Type == "EditBox" then
		element:ClearFocus()
		element:SetText("")
	elseif element.Type == "CheckBox" then
		element:SetChecked(false)
	elseif element.Type == "Dropdown" then
		element.Text:SetText("")
		for _, option in ipairs(element.options) do
			option.selected = false
		end
	end
end

local function createPageFrame(title)
	local page = CreateFrame("Frame", nil, f, "BackdropTemplate")
	page:SetPoint("TOPLEFT", 160, -70)
	page:SetSize(620, 380)
	page:CreateBorder()
	K.CreateFontString(page, 15, title, "", false, "TOPLEFT", 5, 20)
	page:Hide()
	return page
end

local function createScrollFrame(parent, width, height, title)
	local scroll = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
	scroll:SetSize(width, height)
	scroll:SetPoint("BOTTOMLEFT", 10, 10)
	local bg = CreateFrame("Frame", nil, scroll, "BackdropTemplate")
	bg:SetAllPoints(scroll)
	bg:SetFrameLevel(scroll:GetFrameLevel())
	bg:CreateBorder()
	if title then
		K.CreateFontString(scroll, 15, title, "", false, "TOPLEFT", 5, 20)
	end
	scroll.child = CreateFrame("Frame", nil, scroll)
	scroll.child:SetSize(width, 1)
	scroll:SetScrollChild(scroll.child)
	scroll.ScrollBar:SkinScrollBar()
	return scroll
end

local function createAuraBarWidgets(parent, texture)
	local iconFrame = CreateFrame("Frame", nil, parent)
	iconFrame:SetSize(22, 22)
	iconFrame:SetPoint("LEFT", 5, 0)
	iconFrame:CreateBorder()
	local iconTexture = iconFrame:CreateTexture(nil, "ARTWORK")
	iconTexture:SetAllPoints(iconFrame)
	iconTexture:SetTexCoord(unpack(K.TexCoords))
	iconTexture:SetTexture(texture)
	local closeButton = CreateFrame("Button", nil, parent)
	closeButton:SetSize(20, 20)
	closeButton:SetPoint("RIGHT", -5, 0)
	closeButton.Icon = closeButton:CreateTexture(nil, "ARTWORK")
	closeButton.Icon:SetAllPoints()
	closeButton.Icon:SetTexture("Interface\\BUTTONS\\UI-GroupLoot-Pass-Up")
	closeButton:SetHighlightTexture(closeButton.Icon:GetTexture())
	return iconFrame, closeButton
end

local function auraWatchShow()
	SlashCmdList.AuraWatch("move")
end

local function auraWatchHide()
	SlashCmdList.AuraWatch("lock")
end

local function CreatePanel()
	if f then
		f:Show()
		return
	end

	-- Structure
	f = CreateFrame("Frame", "KKUI_AuraWatchGUI", UIParent)
	f:SetPoint("CENTER")
	f:SetSize(800, 500)
	f:CreateBorder()
	K.CreateMoverFrame(f)
	K.CreateFontString(f, 17, L["AuraWatchGUI Title"], "", true, "TOP", 0, -10)
	K.CreateFontString(f, 15, L["Groups"], "", true, "TOPLEFT", 30, -50)
	f:SetFrameStrata("HIGH")
	f:SetFrameLevel(5)
	table_insert(UISpecialFrames, "KKUI_AuraWatchGUI")

	local helpInfo = CreateFrame("Button", nil, f)
	helpInfo:SetPoint("TOPLEFT", 20, -5)
	helpInfo:SetSize(40, 40)
	helpInfo.Icon = helpInfo:CreateTexture(nil, "ARTWORK")
	helpInfo.Icon:SetAllPoints()
	helpInfo.Icon:SetTexture(616343)
	helpInfo:SetHighlightTexture(616343)
	helpInfo.title = L["Tips"]
	K.AddTooltip(helpInfo, "ANCHOR_BOTTOMLEFT", L["AuraWatchGUI Tips"], "info")

	auraWatchShow()
	f:HookScript("OnShow", auraWatchShow)
	f:HookScript("OnHide", auraWatchHide)

	f.Close = CreateFrame("Button", nil, f, "BackdropTemplate")
	f.Close:SetSize(80, 22)
	f.Close:SetPoint("BOTTOMRIGHT", -20, 15)
	f.Close:SkinButton()
	f.Close.text = K.CreateFontString(f.Close, 12, CLOSE, "", true)
	f.Close:SetScript("OnClick", function()
		f:Hide()
	end)

	f.Complete = CreateFrame("Button", nil, f, "BackdropTemplate")
	f.Complete:SetSize(80, 22)
	f.Complete:SetPoint("RIGHT", f.Close, "LEFT", -10, 0)
	f.Complete:SkinButton()
	f.Complete.text = K.CreateFontString(f.Complete, 12, OKAY, "", true)
	f.Complete:SetScript("OnClick", function()
		f:Hide()
		StaticPopup_Show("KKUI_CHANGES_RELOAD")
	end)

	f.Reset = CreateFrame("Button", nil, f, "BackdropTemplate")
	f.Reset:SetSize(80, 22)
	f.Reset:SetPoint("BOTTOMLEFT", 25, 15)
	f.Reset:SkinButton()
	f.Reset.text = K.CreateFontString(f.Reset, 12, RESET, "", true)
	StaticPopupDialogs["RESET_KKUI_AWLIST"] = {
		text = "Reset your AuraWatch List?",
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList = {}
			KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD = {}
			ReloadUI()
		end,
		whileDead = 1,
	}
	f.Reset:SetScript("OnClick", function()
		StaticPopup_Show("RESET_KKUI_AWLIST")
	end)

	local barTable = {}
	local function SortBars(index)
		local num, onLeft, onRight = 1, 1, 1
		for k in pairs(barTable[index]) do
			if (index < 7 and KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList[index][k]) or (index == 7 and KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD[k]) then
				local bar = barTable[index][k]
				if num == 1 then
					bar:SetPoint("TOPLEFT", 10, -10)
				elseif num > 1 and num / 2 ~= math_floor(num / 2) then
					bar:SetPoint("TOPLEFT", 10, -10 - 35 * onLeft)
					onLeft = onLeft + 1
				elseif num == 2 then
					bar:SetPoint("TOPLEFT", 295, -10)
				elseif num > 2 and num / 2 == math_floor(num / 2) then
					bar:SetPoint("TOPLEFT", 295, -10 - 35 * onRight)
					onRight = onRight + 1
				end
				num = num + 1
			end
		end
	end

	local slotIndex = {
		[6] = INVTYPE_WAIST,
		[8] = INVTYPE_FEET,
		[10] = INVTYPE_HAND,
		[11] = INVTYPE_FINGER .. "1",
		[12] = INVTYPE_FINGER .. "2",
		[13] = INVTYPE_TRINKET .. "1",
		[14] = INVTYPE_TRINKET .. "2",
		[15] = INVTYPE_CLOAK,
	}

	local function iconOnEnter(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 3)
		if self.typeID == "SlotID" then
			GameTooltip:SetInventoryItem("player", self.spellID)
		else
			GameTooltip:SetSpellByID(self.spellID)
		end
		GameTooltip:Show()
	end

	local function AddAura(parent, index, data)
		local typeID, spellID, unitID, caster, stack, amount, timeless, combat, text, flash = unpack(data)
		local name, _, texture = GetSpellInfo(spellID)
		if typeID == "SlotID" then
			texture = GetInventoryItemTexture("player", spellID)
			name = slotIndex[spellID]
		elseif typeID == "TotemID" then
			texture = "Interface\\ICONS\\Spell_Totem_WardOfDraining"
			name = L["TotemSlot"] .. spellID
		end

		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(270, 30)
		bar:CreateBorder()
		barTable[index][spellID] = bar

		local icon, close = createAuraBarWidgets(bar, texture)
		icon.typeID = typeID
		icon.spellID = spellID
		if typeID ~= "TotemID" then
			icon:SetScript("OnEnter", iconOnEnter)
			icon:SetScript("OnLeave", K.HideTooltip)
		end

		close:SetScript("OnClick", function()
			bar:Hide()
			KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList[index][spellID] = nil
			barTable[index][spellID] = nil
			SortBars(index)
		end)

		local spellName = K.CreateFontString(bar, 14, name, "", false, "LEFT", 30, 0)
		spellName:SetWidth(180)
		spellName:SetJustifyH("LEFT")
		K.CreateFontString(bar, 14, text, "", false, "RIGHT", -30, 0)
		K.AddTooltip(bar, "ANCHOR_TOP", L["Type*"] .. " " .. typeID, "system")

		typeID = typeID .. " = " .. spellID
		unitID = unitID and ', UnitID = "' .. unitID .. '"' or ""
		caster = caster and ', Caster = "' .. caster .. '"' or ""
		stack = stack and ", Stack = " .. stack or ""
		amount = amount and ", Value = true" or ""
		timeless = timeless and ", Timeless = true" or ""
		combat = combat and ", Combat = true" or ""
		flash = flash and ", Flash = true" or ""
		text = text and text ~= "" and ', Text = "' .. text .. '"' or ""
		local output = "{" .. typeID .. unitID .. caster .. stack .. amount .. timeless .. combat .. flash .. text .. "}"
		bar:SetScript("OnMouseUp", function()
			local editBox = ChatEdit_ChooseBoxForSend()
			_G.ChatEdit_ActivateChat(editBox)
			editBox:SetText(output .. ",")
			editBox:HighlightText()
		end)

		SortBars(index)
	end

	local function AddInternal(parent, index, data)
		local intID, duration, trigger, unit, itemID = unpack(data)
		local name, _, texture = GetSpellInfo(intID)
		if itemID then
			name = GetItemInfo(itemID)
		end

		local bar = CreateFrame("Frame", nil, parent, "BackdropTemplate")
		bar:SetSize(270, 30)
		bar:CreateBorder()
		barTable[index][intID] = bar

		local icon, close = createAuraBarWidgets(bar, texture)
		K.AddTooltip(icon, "ANCHOR_RIGHT", intID)
		close:SetScript("OnClick", function()
			bar:Hide()
			KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD[intID] = nil
			barTable[index][intID] = nil
			SortBars(index)
		end)

		local spellName = K.CreateFontString(bar, 14, name, "", false, "LEFT", 30, 0)
		spellName:SetWidth(180)
		spellName:SetJustifyH("LEFT")
		K.CreateFontString(bar, 14, duration, "", false, "RIGHT", -30, 0)
		K.AddTooltip(bar, "ANCHOR_TOP", L["Trigger"] .. trigger .. " - " .. unit, "system")

		SortBars(index)
	end

	local function createGroupSwitcher(parent, index)
		local bu = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
		bu:SetSize(20, 20)
		bu:SetPoint("TOPRIGHT", -36, -138)
		bu:SetHitRectInsets(-100, 0, 0, 0)

		bu:SetNormalTexture(0)
		bu:SetPushedTexture(0)

		local bg = CreateFrame("Frame", nil, bu, "BackdropTemplate")
		bg:SetAllPoints(bu)
		bg:SetFrameLevel(parent:GetFrameLevel())
		bg:CreateBorder()
		bu.bg = bg

		local hl = bu:GetHighlightTexture()
		bu:SetHighlightTexture(bu:IsObjectType("CheckButton") and "Interface\\Buttons\\CheckButtonHilight" or "Interface\\Buttons\\ButtonHilight-Square")
		hl:SetBlendMode("ADD")
		hl:SetAllPoints()

		local ch = bu:GetCheckedTexture()
		ch:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\UI-CheckBox-Check")
		ch:SetTexCoord(0, 1, 0, 1)
		ch:SetDesaturated(true)
		ch:SetVertexColor(1, 1, 0)

		bu:SetChecked(KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.Switcher[index])
		bu:SetScript("OnClick", function()
			KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.Switcher[index] = bu:GetChecked()
		end)
		K.CreateFontString(bu, 15, "|cffff0000" .. L["AuraWatch Switcher"], "", false, "RIGHT", -30, 0)
	end

	-- Main
	local groups = {
		L["Special Aura"], -- 1 SPECIAL
		L["Warning"], -- 2 Warning
		L["Spell Cooldown"], -- 3 CD
		L["Enchant Aura"], -- 4 Enchant
		L["Raid Buff"], -- 5 RaidBuff
		L["Raid Debuff"], -- 6 RaidDebuff
		L["InternalCD"], -- 7 InternalCD
	}

	local preSet = {
		[1] = { 1, true },
		[2] = { 2, false },
		[3] = { 1, false },
		[4] = { 1, false },
		[5] = { 1, false },
		[6] = { 1, false },
	}

	local tabs = {}
	local function tabOnClick(self)
		for i = 1, #tabs do
			if self == tabs[i] then
				tabs[i].Page:Show()
				tabs[i].KKUI_Background:SetVertexColor(r, g, b, 0.3)
				tabs[i].selected = true
			else
				tabs[i].Page:Hide()
				tabs[i].KKUI_Background:SetVertexColor(0.04, 0.04, 0.04, 0.9)
				tabs[i].selected = false
			end
		end
	end

	local function tabOnEnter(self)
		if self.selected then
			return
		end
		self.KKUI_Background:SetVertexColor(r, g, b, 0.3)
	end

	local function tabOnLeave(self)
		if self.selected then
			return
		end
		self.KKUI_Background:SetVertexColor(0.04, 0.04, 0.04, 0.9)
	end

	for i, group in pairs(groups) do
		if not KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList[i] then
			KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList[i] = {}
		end
		barTable[i] = {}

		tabs[i] = CreateFrame("Button", "$parentTab" .. i, f, "BackdropTemplate")
		tabs[i]:SetPoint("TOPLEFT", 20, -40 - i * 34)
		tabs[i]:SetSize(130, 28)
		tabs[i]:CreateBorder()
		local label = K.CreateFontString(tabs[i], 15, group, "", "system", "LEFT", 10, 0)
		if i == 7 then
			label:SetTextColor(0, 0.8, 0.3)
		end
		tabs[i].Page = createPageFrame(group)
		tabs[i].List = createScrollFrame(tabs[i].Page, 575, 200, L["AuraWatch List"])

		local Option = {}
		if i < 7 then
			for _, v in pairs(KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList[i]) do
				AddAura(tabs[i].List.child, i, v)
			end
			Option[1] = createDropdown(tabs[i].Page, L["Type*"], 20, -30, { "AuraID", "SpellID", "SlotID", "TotemID" }, L["Type Intro"])
			Option[2] = createEditBox(tabs[i].Page, "ID*", 140, -30, L["ID Intro"])
			Option[3] = createDropdown(tabs[i].Page, L["Unit*"], 260, -30, { "player", "target", "focus", "pet" }, L["Unit Intro"])
			Option[4] = createDropdown(tabs[i].Page, L["Caster"], 380, -30, { "player", "target", "pet" }, L["Caster Intro"])
			Option[5] = createEditBox(tabs[i].Page, L["Stack"], 500, -30, L["Stack Intro"])
			Option[6] = createCheckBox(tabs[i].Page, L["Value"], 40, -95, L["Value Intro"])
			Option[7] = createCheckBox(tabs[i].Page, L["Timeless"], 120, -95, L["Timeless Intro"])
			Option[8] = createCheckBox(tabs[i].Page, L["Combat"], 200, -95, L["Combat Intro"])
			Option[9] = createEditBox(tabs[i].Page, L["Text"], 340, -90, L["Text Intro"])
			Option[10] = createCheckBox(tabs[i].Page, L["Flash"], 280, -95, L["Flash Intro"])
			Option[11] = createDropdown(tabs[i].Page, L["Slot*"], 140, -30, { slotIndex[6], slotIndex[8], slotIndex[10], slotIndex[11], slotIndex[12], slotIndex[13], slotIndex[14], slotIndex[15] }, L["Slot Intro"])
			Option[12] = createDropdown(tabs[i].Page, L["Totem*"], 140, -30, { L["TotemSlot"] .. "1", L["TotemSlot"] .. "2", L["TotemSlot"] .. "3", L["TotemSlot"] .. "4" }, L["Totem Intro"])

			for j = 2, 12 do
				Option[j]:Hide()
			end

			for j = 1, #Option[1].options do
				Option[1].options[j]:HookScript("OnClick", function()
					for k = 2, 12 do
						Option[k]:Hide()
						clearInputs(Option[k])
					end

					local optionText = Option[1].Text:GetText()
					if optionText == "AuraID" then
						for k = 2, 10 do
							Option[k]:Show()
						end
						Option[3].options[preSet[i][1]]:Click()
						if preSet[i][2] then
							Option[4].options[1]:Click()
						end
					elseif optionText == "SpellID" then
						Option[2]:Show()
					elseif optionText == "SlotID" then
						Option[11]:Show()
					elseif optionText == "TotemID" then
						Option[12]:Show()
					end
				end)
			end
		elseif i == 7 then
			for _, v in pairs(KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD) do
				AddInternal(tabs[i].List.child, i, v)
			end
			Option[13] = createEditBox(tabs[i].Page, L["IntID*"], 20, -30, L["IntID Intro"])
			Option[14] = createEditBox(tabs[i].Page, L["Duration*"], 140, -30, L["Duration Intro"])
			Option[15] = createDropdown(tabs[i].Page, L["Trigger"] .. "*", 260, -30, { "OnAuraGain", "OnCastSuccess" }, L["Trigger Intro"], 130)
			Option[16] = createDropdown(tabs[i].Page, L["Unit*"], 420, -30, { "Player", "All" }, L["Trigger Unit Intro"])
			Option[17] = createEditBox(tabs[i].Page, L["ItemID"], 20, -95, L["ItemID Intro"])
		end

		local clear = CreateFrame("Button", nil, tabs[i].Page, "BackdropTemplate")
		clear:SetSize(60, 25)
		clear:SkinButton()
		clear.text = K.CreateFontString(clear, 12, KEY_NUMLOCK_MAC, "", true)
		clear:SetPoint("TOPRIGHT", -100, -90)
		clear:SetScript("OnClick", function()
			if i < 7 then
				for j = 2, 12 do
					clearInputs(Option[j])
				end
			elseif i == 7 then
				for j = 13, 17 do
					clearInputs(Option[j])
				end
			end
		end)

		local slotTable = { 6, 8, 10, 11, 12, 13, 14, 15 }
		local add = CreateFrame("Button", nil, tabs[i].Page, "BackdropTemplate")
		add:SetSize(60, 25)
		add:SkinButton()
		add.text = K.CreateFontString(add, 12, ADD, "", true)
		add:SetPoint("TOPRIGHT", -30, -90)
		add:SetScript("OnClick", function()
			if i < 7 then
				local typeID, spellID, unitID, slotID, totemID = Option[1].Text:GetText(), tonumber(Option[2]:GetText()), Option[3].Text:GetText()
				for i = 1, #Option[11].options do
					if Option[11].options[i].selected then
						slotID = slotTable[i]
						break
					end
				end
				for i = 1, #Option[12].options do
					if Option[12].options[i].selected then
						totemID = i
						break
					end
				end

				if not typeID then
					UIErrorsFrame:AddMessage(K.InfoColor .. L["Choose a Type"])
					return
				end
				if (typeID == "AuraID" and (not spellID or not unitID)) or (typeID == "SpellID" and not spellID) or (typeID == "SlotID" and not slotID) or (typeID == "TotemID" and not totemID) then
					UIErrorsFrame:AddMessage(K.InfoColor .. L["Incomplete Input"])
					return
				end
				if (typeID == "AuraID" or typeID == "SpellID") and not GetSpellInfo(spellID) then
					UIErrorsFrame:AddMessage(K.InfoColor .. L["Incorrect SpellID"])
					return
				end

				local realID = spellID or slotID or totemID
				if KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList[i][realID] then
					UIErrorsFrame:AddMessage(K.InfoColor .. L["Existing ID"])
					return
				end

				KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList[i][realID] = { typeID, realID, unitID, Option[4].Text:GetText(), tonumber(Option[5]:GetText()) or false, Option[6]:GetChecked(), Option[7]:GetChecked(), Option[8]:GetChecked(), Option[9]:GetText(), Option[10]:GetChecked() }
				AddAura(tabs[i].List.child, i, KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList[i][realID])
				for i = 2, 12 do
					clearInputs(Option[i])
				end
			elseif i == 7 then
				local intID, duration, trigger, unit, itemID = tonumber(Option[13]:GetText()), tonumber(Option[14]:GetText()), Option[15].Text:GetText(), Option[16].Text:GetText(), tonumber(Option[17]:GetText())
				if not intID or not duration or not trigger or not unit then
					UIErrorsFrame:AddMessage(K.InfoColor .. L["Incomplete Input"])
					return
				end
				if intID and not GetSpellInfo(intID) then
					UIErrorsFrame:AddMessage(K.InfoColor .. L["Incorrect SpellID"])
					return
				end
				if KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD then
					UIErrorsFrame:AddMessage(K.InfoColor .. L["Existing ID"])
					return
				end

				KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD = { intID, duration, trigger, unit, itemID }
				AddInternal(tabs[i].List.child, i, KkthnxUIDB.Variables[K.Realm][K.Name].InternalCD)
				for i = 13, 17 do
					clearInputs(Option[i])
				end
			end
		end)

		tabs[i]:SetScript("OnClick", tabOnClick)
		tabs[i]:SetScript("OnEnter", tabOnEnter)
		tabs[i]:SetScript("OnLeave", tabOnLeave)
	end

	for i = 1, 7 do
		createGroupSwitcher(tabs[i].Page, i)
	end

	tabs[1]:Click()

	local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if f:IsShown() then
				f:Hide()
				K:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			f:Show()
			K:UnregisterEvent(event, showLater)
		end
	end
	K:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)
end

SlashCmdList["KKUI_AWCONFIG"] = function()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
		return
	end

	CreatePanel()
end
SLASH_KKUI_AWCONFIG1 = "/kkaurawatch"
SLASH_KKUI_AWCONFIG1 = "/kkaw"
