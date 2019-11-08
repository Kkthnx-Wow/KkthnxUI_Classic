local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Miscellaneous")

local _G = _G
local math_min = _G.math.min
local math_floor = _G.math.floor
local table_insert = _G.table.insert

local BNGetGameAccountInfoByGUID = _G.BNGetGameAccountInfoByGUID
local CreateFrame = _G.CreateFrame
local DELETE_ITEM_CONFIRM_STRING = _G.DELETE_ITEM_CONFIRM_STRING
local FRIEND = _G.FRIEND
local GUILD = _G.GUILD
local GetCVar = _G.GetCVar
local GetFileIDFromPath = _G.GetFileIDFromPath
local GetInstanceInfo = _G.GetInstanceInfo
local GetItemInfo = _G.GetItemInfo
local GetItemQualityColor = _G.GetItemQualityColor
local GetMerchantItemLink = _G.GetMerchantItemLink
local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
local GetNetStats = _G.GetNetStats
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsGuildMember = _G.IsGuildMember
local MAX_NUM_QUESTS = _G.MAX_NUM_QUESTS or "25"
local NO = _G.NO
local SetCVar = _G.SetCVar
local StaticPopupDialogs = _G.StaticPopupDialogs
local StaticPopup_Show = _G.StaticPopup_Show
local UIParent = _G.UIParent
local UnitGUID = _G.UnitGUID
local YES = _G.YES
local hooksecurefunc = _G.hooksecurefunc

local ACTIVE_QUEST_ICON_FILEID = GetFileIDFromPath("Interface\\GossipFrame\\ActiveQuestIcon")
local AVAILABLE_QUEST_ICON_FILEID = GetFileIDFromPath("Interface\\GossipFrame\\AvailableQuestIcon")

do
	local AutoSpellQueueTolerance = CreateFrame("Frame", "KkthnxUI_AutoLagTolerance")
	AutoSpellQueueTolerance.cache = GetCVar("SpellQueueWindow")
	AutoSpellQueueTolerance.timer = 0
	local function AutoSpellQueueTolerance_OnUpdate(self, elapsed)
		self.timer = self.timer + elapsed
		if self.timer < 1.0 then
			return
		end

		self.timer = 0

		local latency = math_min(400, select(4, GetNetStats()))

		if latency == 0 then
			return
		end

		if latency == self.cache then
			return
		end

		SetCVar("SpellQueueWindow", latency)
		-- K.Print("SpellQueueWindow has been updated to "..latency) -- DEBUG

		self.cache = latency
	end

	if C["General"].LagTolerance then
		AutoSpellQueueTolerance:SetScript("OnUpdate", AutoSpellQueueTolerance_OnUpdate)
	end
end

-- Grids
do
	local grid
	local boxSize = 32
	local function Grid_Create()
		grid = CreateFrame("Frame", nil, UIParent)
		grid.boxSize = boxSize
		grid:SetAllPoints(UIParent)

		local size = 2
		local width = GetScreenWidth()
		local ratio = width / GetScreenHeight()
		local height = GetScreenHeight() * ratio

		local wStep = width / boxSize
		local hStep = height / boxSize

		for i = 0, boxSize do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			if i == boxSize / 2 then
				tx:SetColorTexture(1, 0, 0, .5)
			else
				tx:SetColorTexture(0, 0, 0, .5)
			end
			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", i*wStep - (size/2), 0)
			tx:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", i*wStep + (size/2), 0)
		end
		height = GetScreenHeight()

		do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetColorTexture(1, 0, 0, .5)
			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2) + (size/2))
			tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2 + size/2))
		end

		for i = 1, math_floor((height/2)/hStep) do
			local tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetColorTexture(0, 0, 0, .5)

			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2+i*hStep) + (size/2))
			tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2+i*hStep + size/2))

			tx = grid:CreateTexture(nil, "BACKGROUND")
			tx:SetColorTexture(0, 0, 0, .5)

			tx:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -(height/2-i*hStep) + (size/2))
			tx:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -(height/2-i*hStep + size/2))
		end
	end

	local function Grid_Show()
		if not grid then
			Grid_Create()
		elseif grid.boxSize ~= boxSize then
			grid:Hide()
			Grid_Create()
		else
			grid:Show()
		end
	end

	local isAligning = false
	SlashCmdList["KKUI_TOGGLEGRID"] = function(arg)
		if isAligning or arg == "1" then
			if grid then grid:Hide() end
			isAligning = false
		else
			boxSize = (math.ceil((tonumber(arg) or boxSize) / 32) * 32)
			if boxSize > 256 then boxSize = 256 end
			Grid_Show()
			isAligning = true
		end
	end

	SLASH_KKUI_TOGGLEGRID1 = "/showgrid"
	SLASH_KKUI_TOGGLEGRID2 = "/align"
	SLASH_KKUI_TOGGLEGRID3 = "/grid"
end

-- Easily hide helm and cloak
function Module:CreateToggleHelmCloak()
	if not C["Misc"].ShowHelmCloak then
		return
	end

	local helmCheck = CreateFrame("CheckButton", "HelmCheckBox", PaperDollFrame, "OptionsCheckButtonTemplate")
	helmCheck:SetSize(14, 14)
	helmCheck:SetPoint("BOTTOMLEFT", CharacterStatFrame1, "TOPLEFT", -2, 4)
	helmCheck:SetScript("OnClick", function()
		ShowHelm(not ShowingHelm())
	end)

	helmCheck.Text = K.CreateFontString(helmCheck, 11, SHOW_HELM)
	helmCheck.Text:SetPoint("LEFT", helmCheck, "RIGHT", 2, 0)

	helmCheck:SetFrameStrata("HIGH")
	helmCheck:SetHitRectInsets(0, 0, 0, 0)
	helmCheck:SkinCheckBox()

	local cloakCheck = CreateFrame("CheckButton", "CloakCheckBox", PaperDollFrame, "OptionsCheckButtonTemplate")
	cloakCheck:SetSize(14, 14)
	cloakCheck:SetPoint("BOTTOMRIGHT", CharacterAttributesFrame, "TOPRIGHT", -2, 1)
	cloakCheck:SetScript("OnClick", function()
		ShowCloak(not ShowingCloak())
	end)

	cloakCheck.Text = K.CreateFontString(cloakCheck, 11, SHOW_CLOAK)
	cloakCheck.Text:SetPoint("RIGHT", cloakCheck, "LEFT", -2, 0)

	cloakCheck:SetFrameStrata("HIGH")
	cloakCheck:SetHitRectInsets(0, 0, 0, 0)
	cloakCheck:SkinCheckBox()

	hooksecurefunc("ShowHelm", function(v)
		helmCheck:SetChecked(v)
	end)

	hooksecurefunc("ShowCloak", function(v)
		cloakCheck:SetChecked(v)
	end)

	local checked_UpdateFrame = CreateFrame("Frame")
	checked_UpdateFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	checked_UpdateFrame:SetScript("OnEvent", function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		helmCheck:SetChecked(ShowingHelm())
		cloakCheck:SetChecked(ShowingCloak())
	end)
end

function Module:FixQuestFrameIcons()
	local titleLines = {}
	local questIconTextures = {}
	local completedActiveQuests = {}
	local escapes = {
		["|c%x%x%x%x%x%x%x%x"] = "", -- color start
		["|r"] = "" -- color end
	}

	do
		for i = 1, MAX_NUM_QUESTS do
			local titleLine = _G["QuestTitleButton"..i]
			table_insert(titleLines, titleLine)
			table_insert(questIconTextures, _G[titleLine:GetName().."QuestIcon"])
		end

		QuestFrameGreetingPanel:HookScript("OnShow", function()
			for i, titleLine in ipairs(titleLines) do
				if (titleLine:IsVisible()) then
					local bulletPointTexture = questIconTextures[i]
					if (titleLine.isActive == 1) then
						bulletPointTexture:SetTexture(ACTIVE_QUEST_ICON_FILEID)
					else
						bulletPointTexture:SetTexture(AVAILABLE_QUEST_ICON_FILEID)
					end
				end
			end
		end)
	end

	do
		local function unescape(str)
			for k, v in pairs(escapes) do
				str = gsub(str, k, v)
			end

			return str
		end

		local function getCompletedQuestsInLog()
			table.wipe(completedActiveQuests)
			local numEntries = GetNumQuestLogEntries()
			local questLogTitleText, isComplete, questId, _
			for i = 1, numEntries, 1 do
				_, _, _, _, _, isComplete, _, questId = GetQuestLogTitle(i)
				if (isComplete == 1 or IsQuestComplete(questId)) then
					questLogTitleText = C_QuestLog.GetQuestInfo(questId)
					completedActiveQuests[questLogTitleText] = true
				end
			end

			return completedActiveQuests
		end

		local function setDesaturation(maxLines, lineMap, iconMap, activePred)
			local completedQuests = getCompletedQuestsInLog()
			for i = 1, maxLines do
				local line = lineMap[i]
				local icon = iconMap[i]
				icon:SetDesaturated(nil)
				if (line:IsVisible() and activePred(line)) then
					local questName = unescape(line:GetText())
					if (not completedQuests[questName]) then
						icon:SetDesaturated(1)
					end
				end
			end
		end

		local function getLineAndIconMaps(maxLines, titleIdent, iconIdent)
			local lines = {}
			local icons = {}
			for i = 1, maxLines do
				local titleLine = _G[titleIdent .. i]
				table_insert(lines, titleLine)
				table_insert(icons, _G[titleLine:GetName() .. iconIdent])
			end

			return lines, icons
		end

		local questFrameTitleLines, questFrameIconTextures = getLineAndIconMaps(MAX_NUM_QUESTS, "QuestTitleButton", "QuestIcon")
		QuestFrameGreetingPanel:HookScript("OnShow",function()
			setDesaturation(MAX_NUM_QUESTS, questFrameTitleLines, questFrameIconTextures, function(line)
				return line.isActive == 1
			end)
		end)

		local gossipFrameTitleLines, gossipFrameIconTextures =
		getLineAndIconMaps(NUMGOSSIPBUTTONS, "GossipTitleButton", "GossipIcon")
		hooksecurefunc("GossipFrameUpdate", function()
			setDesaturation(NUMGOSSIPBUTTONS, gossipFrameTitleLines, gossipFrameIconTextures, function(line)
				return line.type == "Active"
			end)
		end)
	end
end

-- TradeFrame hook
function Module:TradeTargetInfo()
	local infoText = K.CreateFontString(TradeFrame, 14, nil, "")
	infoText:ClearAllPoints()
	infoText:SetPoint("TOP", TradeFrameRecipientNameText, "BOTTOM", 0, -5)

	local function updateColor()
		local r, g, b = K.UnitColor("NPC")
		TradeFrameRecipientNameText:SetTextColor(r, g, b)

		local guid = UnitGUID("NPC")
		if not guid then return end
		local text = "|cffff0000"..L["Stranger"]
		if BNGetGameAccountInfoByGUID(guid) or C_FriendList.IsFriend(guid) then
			text = "|cffffff00"..FRIEND
		elseif IsGuildMember(guid) then
			text = "|cff00ff00"..GUILD
		end
		infoText:SetText(text)
	end
	hooksecurefunc("TradeFrame_Update", updateColor)
end

-- ALT+RightClick to buy a stack
do
	local old_MerchantItemButton_OnModifiedClick = _G.MerchantItemButton_OnModifiedClick
	local cache = {}
	function MerchantItemButton_OnModifiedClick(self, ...)
		if IsAltKeyDown() then
			local id = self:GetID()
			local itemLink = GetMerchantItemLink(id)
			if not itemLink then return end
			local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
			if maxStack and maxStack > 1 then
				if not cache[itemLink] then
					StaticPopupDialogs["BUY_STACK"] = {
						text = "Stack Buying Check",
						button1 = YES,
						button2 = NO,
						OnAccept = function()
							_G.BuyMerchantItem(id, GetMerchantItemMaxStack(id))
							cache[itemLink] = true
						end,
						hideOnEscape = 1,
						hasItemFrame = 1,
					}

					local r, g, b = GetItemQualityColor(quality or 1)
					StaticPopup_Show("BUY_STACK", " ", " ", {["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["index"] = id, ["count"] = maxStack})
				else
					_G.BuyMerchantItem(id, GetMerchantItemMaxStack(id))
				end
			end
		end

		old_MerchantItemButton_OnModifiedClick(self, ...)
	end
end

-- Select target when click on raid units
do
	local function fixRaidGroupButton()
		for i = 1, 40 do
			local bu = _G["RaidGroupButton"..i]
			if bu and bu.unit and not bu.clickFixed then
				bu:SetAttribute("type", "target")
				bu:SetAttribute("unit", bu.unit)

				bu.clickFixed = true
			end
		end
	end

	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_RaidUI" then
			if not InCombatLockdown() then
				fixRaidGroupButton()
			else
				K:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
			end
			K:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			if _G.RaidGroupButton1 and _G.RaidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButton()
				K:UnregisterEvent(event, setupMisc)
			end
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Show BID and highlight price
do
	local function setupMisc(event, addon)
		if addon == "Blizzard_AuctionUI" then
			hooksecurefunc("AuctionFrameBrowse_Update", function()
				local numBatchAuctions = GetNumAuctionItems("list")
				local offset = FauxScrollFrame_GetOffset(BrowseScrollFrame)
				local name, buyoutPrice, bidAmount, hasAllInfo
				for i = 1, NUM_BROWSE_TO_DISPLAY do
					local index = offset + i + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page)
					local shouldHide = index > (numBatchAuctions + (NUM_AUCTION_ITEMS_PER_PAGE * AuctionFrameBrowse.page))
					if not shouldHide then
						name, _, _, _, _, _, _, _, _, buyoutPrice, bidAmount, _, _, _, _, _, _, hasAllInfo = GetAuctionItemInfo("list", offset + i)
						if not hasAllInfo then shouldHide = true end
					end
					if not shouldHide then
						local alpha = .5
						local color = "yellow"
						local buttonName = "BrowseButton"..i
						local itemName = _G[buttonName.."Name"]
						local moneyFrame = _G[buttonName.."MoneyFrame"]
						local buyoutMoney = _G[buttonName.."BuyoutFrameMoney"]
						if buyoutPrice >= 5*1e7 then color = "red" end
						if bidAmount > 0 then
							name = name.." |cffffff00"..BID.."|r"
							alpha = 1.0
						end
						itemName:SetText(name)
						moneyFrame:SetAlpha(alpha)
						SetMoneyFrameColor(buyoutMoney:GetName(), color)
					end
				end
			end)

			K:UnregisterEvent(event, setupMisc)
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Add friend and guild invite on target menu
function Module:MenuButton_OnClick(info)
	local name, server = UnitName(info.unit)
	if server and server ~= "" then
		name = name.."-"..server
	end

	if info.value == "name" then
		if MailFrame:IsShown() then
			MailFrameTab_OnClick(nil, 2)
			SendMailNameEditBox:SetText(name)
			SendMailNameEditBox:HighlightText()
		else
			local editBox = ChatEdit_ChooseBoxForSend()
			local hasText = (editBox:GetText() ~= "")
			ChatEdit_ActivateChat(editBox)
			editBox:Insert(name)
			if not hasText then
				editBox:HighlightText()
			end
		end
	elseif info.value == "guild" then
		GuildInvite(name)
	end
end

function Module:MenuButton_Show(_, unit)
	if UIDROPDOWNMENU_MENU_LEVEL > 1 then
		return
	end

	if unit and (unit == "target" or string.find(unit, "party") or string.find(unit, "raid")) then
		local info = UIDropDownMenu_CreateInfo()
		info.text = Module.MenuButtonList["name"]
		info.arg1 = {value = "name", unit = unit}
		info.func = Module.MenuButton_OnClick
		info.notCheckable = true
		UIDropDownMenu_AddButton(info)

		if IsInGuild() and UnitIsPlayer(unit) and not UnitCanAttack("player", unit) and not UnitIsUnit("player", unit) then
			info = UIDropDownMenu_CreateInfo()
			info.text = Module.MenuButtonList["guild"]
			info.arg1 = {value = "guild", unit = unit}
			info.func = Module.MenuButton_OnClick
			info.notCheckable = true
			UIDropDownMenu_AddButton(info)
		end
	end
end

function Module:CreateEnhancedMenu()
	if not C["Misc"].EnhancedMenu then
		return
	end

	Module.MenuButtonList = {
		["name"] = COPY_NAME,
		["guild"] = gsub(CHAT_GUILD_INVITE_SEND, HEADER_COLON, ""),
	}
	hooksecurefunc("UnitPopup_ShowMenu", Module.MenuButton_Show)
end

-- Auto dismount and auto stand
function Module:CreateDismountStand()
	if not C["Misc"].AutoDismountStand then
		return
	end

	local standString = {
		[ERR_LOOT_NOTSTANDING] = true,
		[SPELL_FAILED_NOT_STANDING] = true,
	}

	local dismountString = {
		[ERR_ATTACK_MOUNTED] = true,
		[ERR_NOT_WHILE_MOUNTED] = true,
		[ERR_TAXIPLAYERALREADYMOUNTED] = true,
		[SPELL_FAILED_NOT_MOUNTED] = true,
	}

	local function updateEvent(event, ...)
		local _, msg = ...
		if standString[msg] then
			DoEmote("STAND")
		elseif dismountString[msg] then
			Dismount()
		end
	end

	K:RegisterEvent("UI_ERROR_MESSAGE", updateEvent)
end

function Module:CreateWowHeadLinks()
	if IsAddOnLoaded("Leatrix_Plus") or C["Misc"].ShowWowHeadLinks ~= true then
		return
	end

	-- Get localised Wowhead URL
	local wowheadLoc
	if K.Client == "deDE" then
		wowheadLoc = "de.classic.wowhead.com"
	elseif K.Client == "esMX" then
		wowheadLoc = "es.classic.wowhead.com"
	elseif K.Client == "esES" then
		wowheadLoc = "es.classic.wowhead.com"
	elseif K.Client == "frFR" then
		wowheadLoc = "fr.classic.wowhead.com"
	elseif K.Client == "itIT" then
		wowheadLoc = "it.classic.wowhead.com"
	elseif K.Client == "ptBR" then
		wowheadLoc = "pt.classic.wowhead.com"
	elseif K.Client == "ruRU" then
		wowheadLoc = "ru.classic.wowhead.com"
	elseif K.Client == "koKR" then
		wowheadLoc = "ko.classic.wowhead.com"
	elseif K.Client == "zhCN" then
		wowheadLoc = "cn.classic.wowhead.com"
	elseif K.Client == "zhTW" then
		wowheadLoc = "cn.classic.wowhead.com"
	else
		wowheadLoc = "classic.wowhead.com"
	end

	-- Create editbox
	local mEB = CreateFrame("EditBox", nil, QuestLogFrame)
	mEB:ClearAllPoints()
	mEB:SetPoint("TOPLEFT", 70, 4)
	mEB:SetHeight(16)
	mEB:SetFontObject("GameFontNormal")
	mEB:SetBlinkSpeed(0)
	mEB:SetAutoFocus(false)
	mEB:EnableKeyboard(false)
	mEB:SetHitRectInsets(0, 90, 0, 0)
	mEB:SetScript("OnKeyDown", function() end)
	mEB:SetScript("OnMouseUp", function()
		if mEB:IsMouseOver() then
			mEB:HighlightText()
		else
			mEB:HighlightText(0, 0)
		end
	end)

	-- Set the background color
	mEB.t = mEB:CreateTexture(nil, "BACKGROUND")
	mEB.t:SetPoint(mEB:GetPoint())
	mEB.t:SetSize(mEB:GetSize())
	mEB.t:SetColorTexture(0.05, 0.05, 0.05, 1.0)

	-- Create hidden font string (used for setting width of editbox)
	mEB.z = mEB:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	mEB.z:Hide()

	-- Function to set editbox value
	local function SetQuestInBox(questListID)
		local questTitle, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(questListID)
		if questID and not isHeader then

			-- Hide editbox if quest ID is invalid
			if questID == 0 then
			mEB:Hide() else mEB:Show()
			end

			-- Set editbox text
			mEB:SetText("https://"..wowheadLoc.."/quest="..questID)

			-- Set hidden fontstring then resize editbox to match
			mEB.z:SetText(mEB:GetText())
			mEB:SetWidth(mEB.z:GetStringWidth() + 90)
			mEB.t:SetWidth(mEB.z:GetStringWidth())

			-- Get quest title for tooltip
			if questTitle then
				mEB.tiptext = questTitle..L["Press To Copy"]
			else
				mEB.tiptext = ""
				if mEB:IsMouseOver() and GameTooltip:IsShown() then
					GameTooltip:Hide()
				end
			end

		end
	end

	-- Set URL when quest is selected
	hooksecurefunc("QuestLog_SetSelection", function(questListID)
		SetQuestInBox(questListID)
	end)

	-- Create tooltip
	mEB:HookScript("OnEnter", function()
		mEB:HighlightText()
		mEB:SetFocus()
		GameTooltip:SetOwner(mEB, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:SetText(mEB.tiptext, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)

	mEB:HookScript("OnLeave", function()
		mEB:HighlightText(0, 0)
		mEB:ClearFocus()
		GameTooltip:Hide()
	end)
end

function Module:OnEnable()
	self:CreateKillingBlow() -- Not Ready
	-- self:CreateChatBubble() -- Place Holder

	self:CreateAFKCam()
	self:CreateDismountStand()
	self:CreateDurabilityFrame()
	self:CreateEnhancedMenu()
	self:CreateImprovedMail()
	self:CreateImprovedProfessionWindow()
	self:CreateImprovedQuestLog()
	self:CreateImprovedTrainerWindow()
	self:CreateMerchantItemLevel()
	self:CreatePvPEmote()
	self:CreateQuestNotifier()
	self:CreateRaidMarker()
	self:CreateSlotDurability()
	self:CreateSlotItemLevel()
	self:CreateToggleHelmCloak()
	self:CreateTradeTabs()
	self:CreateWowHeadLinks()
	self:FixQuestFrameIcons()
	self:TradeTargetInfo()

	-- Instant delete
	hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(self)
		self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
	end)

	-- Auto chatBubbles
	if C["Automation"].AutoBubbles then
		local function updateBubble()
			local name, instType = GetInstanceInfo()
			if name and instType == "raid" or instType == "party" then
				SetCVar("chatBubbles", 0)
			else
				SetCVar("chatBubbles", 1)
			end
		end

		K:RegisterEvent("PLAYER_ENTERING_WORLD", updateBubble)
	end

	do
		StaticPopupDialogs.RESURRECT.hideOnEscape = nil
		StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
		StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
		StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
		StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
		StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
	end

	-- RealMobHealth override
	if RealMobHealth and RealMobHealth.OverrideOption then
		RealMobHealth.OverrideOption("ShowTooltipHealthText", false)
	end
end