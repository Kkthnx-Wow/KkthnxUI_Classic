local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Miscellaneous")

local _G = _G
-- local select = _G.select
-- local string_match = _G.string.match
-- local tonumber = _G.tonumber

-- local C_BattleNet_GetGameAccountInfoByGUID = _G.C_BattleNet.GetGameAccountInfoByGUID
-- local C_FriendList_IsFriend = _G.C_FriendList.IsFriend
-- local C_QuestLog_ShouldShowQuestRewards = _G.C_QuestLog.ShouldShowQuestRewards
-- local C_Timer_After = _G.C_Timer.After
-- local CreateFrame = _G.CreateFrame
-- local FRIEND = _G.FRIEND
-- local GUILD = _G.GUILD
-- local GetItemInfo = _G.GetItemInfo
-- local GetItemQualityColor = _G.GetItemQualityColor
-- local GetMerchantItemLink = _G.GetMerchantItemLink
-- local GetMerchantItemMaxStack = _G.GetMerchantItemMaxStack
-- local GetQuestLogRewardXP = _G.GetQuestLogRewardXP
-- local GetRewardXP = _G.GetRewardXP
-- local GetSpellInfo = _G.GetSpellInfo
-- local InCombatLockdown = _G.InCombatLockdown
-- local IsAddOnLoaded = _G.IsAddOnLoaded
-- local IsAltKeyDown = _G.IsAltKeyDown
-- local IsGuildMember = _G.IsGuildMember
-- local NO = _G.NO
-- local PlaySound = _G.PlaySound
-- local StaticPopupDialogs = _G.StaticPopupDialogs
-- local StaticPopup_Show = _G.StaticPopup_Show
-- local UIParent = _G.UIParent
-- local UnitGUID = _G.UnitGUID
-- local UnitXP = _G.UnitXP
-- local UnitXPMax = _G.UnitXPMax
-- local YES = _G.YES
-- local hooksecurefunc = _G.hooksecurefunc

-- Reanchor Vehicle
function Module:CreateVehicleSeatMover()
	local frame = CreateFrame("Frame", "KKUI_VehicleSeatMover", UIParent)
	frame:SetSize(125, 125)
	K.Mover(frame, "VehicleSeat", "VehicleSeat", {"BOTTOM", UIParent, -364, 4})

	hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", frame)
		end
	end)
end

-- Reanchor DurabilityFrame
function Module:CreateDurabilityFrameMove()
	hooksecurefunc(DurabilityFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -40, -50)
		end
	end)
end

-- Reanchor TicketStatusFrame
function Module:CreateTicketStatusFrameMove()
	hooksecurefunc(TicketStatusFrame, "SetPoint", function(self, relF)
		if relF == "TOPRIGHT" then
			self:ClearAllPoints()
			self:SetPoint("TOP", UIParent, "TOP", -400, -20)
		end
	end)
end

-- Hide Bossbanner
function Module:CreateBossBanner()
	if C["Misc"].HideBanner and not C["Announcements"].KillingBlow then
		BossBanner:UnregisterAllEvents()
	else
		BossBanner:RegisterEvent("BOSS_KILL")
		BossBanner:RegisterEvent("ENCOUNTER_LOOT_RECEIVED")
	end
end

-- Hide boss emote
function Module:CreateBossEmote()
	if C["Misc"].HideBossEmote then
		RaidBossEmoteFrame:UnregisterAllEvents()
	else
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_WHISPER")
		RaidBossEmoteFrame:RegisterEvent("CLEAR_BOSS_EMOTES")
	end
end

local function CreateErrorFrameToggle(event)
	if not C["General"].NoErrorFrame then
		return
	end

	if event == "PLAYER_REGEN_DISABLED" then
		_G.UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
		K:RegisterEvent("PLAYER_REGEN_ENABLED", CreateErrorFrameToggle)
	else
		_G.UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
		K:UnregisterEvent(event, CreateErrorFrameToggle)
	end
end

function Module:CreateQuestSizeUpdate()
	QuestTitleFont:SetFont(QuestFont:GetFont(), C["UIFonts"].QuestFontSize + 3, nil)
	QuestFont:SetFont(QuestFont:GetFont(), C["UIFonts"].QuestFontSize + 1, nil)
	QuestFontNormalSmall:SetFont(QuestFontNormalSmall:GetFont(), C["UIFonts"].QuestFontSize, nil)
end

function Module:CreateErrorsFrame()
	local Font = K.GetFont(C["UIFonts"].GeneralFonts)
	local Path, _, Flag = _G[Font]:GetFont()

	UIErrorsFrame:SetFont(Path, 15, Flag)
	UIErrorsFrame:ClearAllPoints()
	UIErrorsFrame:SetPoint("TOP", 0, -300)

	K.Mover(UIErrorsFrame, "UIErrorsFrame", "UIErrorsFrame", {"TOP", 0, -300})
end

-- TradeFrame hook
function Module:CreateTradeTargetInfo()
	local infoText = K.CreateFontString(TradeFrame, 16, "", "")
	infoText:ClearAllPoints()
	infoText:SetPoint("TOP", TradeFrameRecipientNameText, "BOTTOM", 0, -8)

	local function updateColor()
		local r, g, b = K.UnitColor("NPC")
		TradeFrameRecipientNameText:SetTextColor(r, g, b)

		local guid = UnitGUID("NPC")
		if not guid then return end
		local text = "|cffff0000"..L["Stranger"]
		if C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) then
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
	local cache = {}
	local itemLink, id

	StaticPopupDialogs["BUY_STACK"] = {
		text = L["Stack Buying Check"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if not itemLink then
				return
			end
			BuyMerchantItem(id, GetMerchantItemMaxStack(id))
			cache[itemLink] = true
			itemLink = nil
		end,
		hideOnEscape = 1,
		hasItemFrame = 1,
	}

	local _MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
	function MerchantItemButton_OnModifiedClick(self, ...)
		if IsAltKeyDown() then
			id = self:GetID()
			itemLink = GetMerchantItemLink(id)
			if not itemLink then
				return
			end

			local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
			if maxStack and maxStack > 1 then
				if not cache[itemLink] then
					local r, g, b = GetItemQualityColor(quality or 1)
					StaticPopup_Show("BUY_STACK", " ", " ", {["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["index"] = id, ["count"] = maxStack})
				else
					BuyMerchantItem(id, GetMerchantItemMaxStack(id))
				end
			end
		end

		_MerchantItemButton_OnModifiedClick(self, ...)
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
			if RaidGroupButton1 and RaidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButton()
				K:UnregisterEvent(event, setupMisc)
			end
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- Fix blizz guild news hyperlink error
do
	local function fixGuildNews(event, addon)
		if addon ~= "Blizzard_GuildUI" then
			return
		end

		local _GuildNewsButton_OnEnter = GuildNewsButton_OnEnter
		function GuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then
				return
			end
			_GuildNewsButton_OnEnter(self)
		end

		K:UnregisterEvent(event, fixGuildNews)
	end

	local function fixCommunitiesNews(event, addon)
		if addon ~= "Blizzard_Communities" then
			return
		end

		local _CommunitiesGuildNewsButton_OnEnter = CommunitiesGuildNewsButton_OnEnter
		function CommunitiesGuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then return end
			_CommunitiesGuildNewsButton_OnEnter(self)
		end

		K:UnregisterEvent(event, fixCommunitiesNews)
	end

	K:RegisterEvent("ADDON_LOADED", fixGuildNews)
	K:RegisterEvent("ADDON_LOADED", fixCommunitiesNews)
end

-- Override default settings for AngryWorldQuests
function Module:OverrideAWQ()
	if not IsAddOnLoaded("AngryWorldQuests") then return end

	AngryWorldQuests_Config = AngryWorldQuests_Config or {}
	AngryWorldQuests_CharacterConfig = AngryWorldQuests_CharacterConfig or {}

	local settings = {
		hideFilteredPOI = true,
		showContinentPOI = true,
		sortMethod = 2,
	}
	local function overrideOptions(_, key)
		local value = settings[key]
		if value then
			AngryWorldQuests_Config[key] = value
			AngryWorldQuests_CharacterConfig[key] = value
		end
	end
	hooksecurefunc(AngryWorldQuests.Modules.Config, "Set", overrideOptions)
end

hooksecurefunc("ChatEdit_InsertLink", function(text) -- shift-clicked
	-- change from SearchBox:HasFocus to :IsShown again
	if text and TradeSkillFrame and TradeSkillFrame:IsShown() then
		local spellId = string_match(text, "enchant:(%d+)")
		local spell = GetSpellInfo(spellId)
		local item = GetItemInfo(string_match(text, "item:(%d+)") or 0)
		local search = spell or item
		if not search then
			return
		end

		-- search needs to be lowercase for .SetRecipeItemNameFilter
		TradeSkillFrame.SearchBox:SetText(search)

		-- jump to the recipe
		if spell then -- can only select recipes on the learned tab
			if PanelTemplates_GetSelectedTab(TradeSkillFrame.RecipeList) == 1 then
				TradeSkillFrame:SelectRecipe(tonumber(spellId))
			end
		elseif item then
			C_Timer_After(.1, function() -- wait a bit or we cant select the recipe yet
				for _, v in pairs(TradeSkillFrame.RecipeList.dataList) do
					if v.name == item then
						--TradeSkillFrame.RecipeList:RefreshDisplay() -- didnt seem to help
						TradeSkillFrame:SelectRecipe(v.recipeID)
						return
					end
				end
			end)
		end
	end
end)

-- make it only split stacks with shift-rightclick if the TradeSkillFrame is open
-- shift-leftclick should be reserved for the search box
local function hideSplitFrame(_, button)
	if TradeSkillFrame and TradeSkillFrame:IsShown() then
		if button == "LeftButton" then
			StackSplitFrame:Hide()
		end
	end
end
hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", hideSplitFrame)
hooksecurefunc("MerchantItemButton_OnModifiedClick", hideSplitFrame)

do
	local function soundOnResurrect()
		if C["Unitframe"].ResurrectSound then
			PlaySound("72978", "Master")
		end
	end
	K:RegisterEvent("RESURRECT_REQUEST", soundOnResurrect)
end

function Module:CreateBlockStrangerInvites()
	K:RegisterEvent("PARTY_INVITE_REQUEST", function(a, b, c, d, e, f, g, guid)
		if C["Automation"].AutoBlockStrangerInvites and not (C_BattleNet_GetGameAccountInfoByGUID(guid) or C_FriendList_IsFriend(guid) or IsGuildMember(guid)) then
			_G.DeclineGroup()
			_G.StaticPopup_Hide("PARTY_INVITE")
			K.Print("Blocked invite request from a stranger!", a, b, c, d, e, f, g, guid)
		end
	end)
end

function Module:CreateEnhanceDressup()
	local parent = _G.DressUpFrameResetButton
	local button = Module:MailBox_CreatButton(parent, 80, 22, "Undress", {"RIGHT", parent, "LEFT", -1, 0})
	button:RegisterForClicks("AnyUp")
	button:SetScript("OnClick", function(_, btn)
		local actor = DressUpFrame.ModelScene:GetPlayerActor()
		if not actor then return end

		if btn == "LeftButton" then
			actor:Undress()
		else
			actor:UndressSlot(19)
		end
	end)

	K.AddTooltip(button, "ANCHOR_TOP", string.format("%sUndress all|n%sUndress tabard", K.LeftButton, K.RightButton))
end

function Module:OnEnable()
	self:CharacterStatePanel()
	-- self:CreateAFKCam()
	-- self:CreateBlockStrangerInvites()
	-- self:CreateBossBanner()
	-- self:CreateBossEmote()
	-- self:CreateDurabilityFrameMove()
	-- self:CreateEnhanceDressup()
	-- self:CreateErrorsFrame()
	-- self:CreateGuildBest()
	-- self:CreateImprovedMail()
	-- self:CreateImprovedStats()
	-- self:CreateMouseTrail()
	-- self:CreateMuteSounds()
	-- self:CreateParagonReputation()
	-- self:CreatePulseCooldown()
	-- self:CreateQuestSizeUpdate()
	-- self:CreateQuickJoin()
	-- self:CreateRaidMarker()
	-- self:CreateSlotDurability()
	self:CreateSlotItemLevel()
	-- self:CreateTicketStatusFrameMove()
	-- self:CreateTradeTabs()
	-- self:CreateTradeTargetInfo()
	-- self:CreateVehicleSeatMover()
	-- self:OverrideAWQ()
	-- self:ReplaceContaminantName()

	-- K:RegisterEvent("PLAYER_REGEN_DISABLED", CreateErrorFrameToggle)

	-- -- Unregister talent event
	-- if PlayerTalentFrame then
	-- 	PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	-- else
	-- 	hooksecurefunc("TalentFrame_LoadUI", function()
	-- 		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	-- 	end)
	-- end

	-- -- Quick Join Bug
	-- CreateFrame("Frame"):SetScript("OnUpdate", function()
	-- 	if _G.LFRBrowseFrame.timeToClear then
	-- 		_G.LFRBrowseFrame.timeToClear = nil
	-- 	end
	-- end)

	-- -- Auto chatBubbles
	-- if C["Misc"].AutoBubbles then
	-- 	local function updateBubble()
	-- 		local name, instType = GetInstanceInfo()
	-- 		if name and instType == "raid" then
	-- 			SetCVar("chatBubbles", 1)
	-- 		else
	-- 			SetCVar("chatBubbles", 0)
	-- 		end
	-- 	end
	-- 	K:RegisterEvent("PLAYER_ENTERING_WORLD", updateBubble)
	-- end

	-- -- Instant delete
	-- local deleteDialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
	-- if deleteDialog.OnShow then
	-- 	hooksecurefunc(deleteDialog, "OnShow", function(self)
	-- 		self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
	-- 	end)
	-- end

	-- -- Fix blizz bug in addon list
	-- local _AddonTooltip_Update = AddonTooltip_Update
	-- function AddonTooltip_Update(owner)
	-- 	if not owner then
	-- 		return
	-- 	end

	-- 	if owner:GetID() < 1 then
	-- 		return
	-- 	end
	-- 	_AddonTooltip_Update(owner)
	-- end

	-- -- Add (+X%) to quest rewards experience text
	-- hooksecurefunc("QuestInfo_Display", function()
	-- 	local unitXP, unitXPMax = UnitXP("player"), UnitXPMax("player")
	-- 	local Font = K.GetFont(C["UIFonts"].GeneralFonts)
	-- 	local Path, _, Flag = _G[Font]:GetFont()

	-- 	if _G.QuestInfoFrame.questLog then
	-- 		local selectedQuest = GetQuestLogSelection()
	-- 		if C_QuestLog_ShouldShowQuestRewards(selectedQuest) then
	-- 			local xp = GetQuestLogRewardXP()
	-- 			if xp and xp > 0 then
	-- 				local text = _G.MapQuestInfoRewardsFrame.XPFrame.Name:GetText()
	-- 				if text then
	-- 					_G.MapQuestInfoRewardsFrame.XPFrame.Name:SetFormattedText("%s (|cff4beb2c+%.2f%%|r)", text, (((unitXP + xp) / unitXPMax) - (unitXP / unitXPMax)) * 100)
	-- 					_G.MapQuestInfoRewardsFrame.XPFrame.Name:SetFont(Path, select(3, MapQuestInfoRewardsFrame.XPFrame.Name:GetFont()), Flag)
	-- 				end
	-- 			end
	-- 		end
	-- 	else
	-- 		local xp = GetRewardXP()
	-- 		if xp and xp > 0 then
	-- 			local text = _G.QuestInfoXPFrame.ValueText:GetText()
	-- 			if text then
	-- 				_G.QuestInfoXPFrame.ValueText:SetFormattedText("%s (|cff4beb2c+%.2f%%|r)", text, (((unitXP + xp) / unitXPMax) - (unitXP / unitXPMax)) * 100)
	-- 				_G.QuestInfoXPFrame.ValueText:SetFont(Path, select(3, QuestInfoXPFrame.ValueText:GetFont()), Flag)
	-- 			end
	-- 		end
	-- 	end
	-- end)
end