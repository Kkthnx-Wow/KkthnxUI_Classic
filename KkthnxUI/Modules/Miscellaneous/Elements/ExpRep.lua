local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- Caching global functions and variables
local math_min, math_floor = math.min, math.floor
local string_format = string.format
local select, pairs = select, pairs

-- Caching frequently used functions and variables
local GetXPExhaustion = GetXPExhaustion
local IsInGroup = IsInGroup
local UnitXP, UnitXPMax = UnitXP, UnitXPMax
local GameTooltip = GameTooltip

-- Experience
local CurrentXP, XPToLevel, PercentRested, PercentXP, RemainXP, RemainTotal, RemainBars
local RestedXP = 0

local function XPIsUserDisabled()
	return IsXPUserDisabled()
end

local function XPIsTrialMax()
	return (IsRestrictedAccount() or IsTrialAccount() or IsVeteranTrialAccount()) and (K.Level == 20)
end

local function XPIsLevelMax()
	return IsLevelAtEffectiveMaxLevel(K.Level) or XPIsUserDisabled() or XPIsTrialMax()
end

local sendExperienceText = "Send experience to chat|r"

-- Bar string
local barDisplayString = ""
local altKeyText = K.InfoColor .. ALT_KEY_TEXT .. " "

local function OnExpBarEvent(self)
	if not XPIsLevelMax() then
		CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), (GetXPExhaustion() or 0)

		-- Ensure XPToLevel is not 0 to avoid division by zero
		if XPToLevel <= 0 then
			XPToLevel = 1
		end

		-- Calculate remaining XP and percentage
		local remainXP = XPToLevel - CurrentXP
		local remainPercent = remainXP / XPToLevel
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, K.ShortValue(remainXP)

		-- Set status bar colors
		self:SetStatusBarColor(0, 0.4, 1, 0.8)
		self.restBar:SetStatusBarColor(1, 0, 1, 0.4)

		-- Set up main XP bar
		self:SetMinMaxValues(0, XPToLevel)
		self:SetValue(CurrentXP)
		barDisplayString = string_format("%s - %.2f%%", K.ShortValue(CurrentXP), PercentXP)

		-- Check if rested XP exists
		local isRested = RestedXP > 0
		if isRested then
			-- Set up rested XP bar
			self.restBar:SetMinMaxValues(0, XPToLevel)
			self.restBar:SetValue(math_min(CurrentXP + RestedXP, XPToLevel))

			-- Calculate percentage of rested XP
			PercentRested = (RestedXP / XPToLevel) * 100

			-- Update XP display string with rested XP information
			barDisplayString = string_format("%s R:%s [%.2f%%]", barDisplayString, K.ShortValue(RestedXP), PercentRested)
		end

		-- Show experience
		self:Show()

		-- Show or hide rested XP bar based on rested state
		self.restBar:SetShown(isRested)

		-- Update text display with XP information
		self.text:SetText(barDisplayString)
	elseif GetWatchedFactionInfo() then
		-- local data = C_Reputation_GetWatchedFactionData()
		-- local name, reaction, currentReactionThreshold, nextReactionThreshold, currentStanding, factionID = data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID

		-- local standing, rewardPending, _

		-- if reaction == 0 then
		-- 	reaction = 1
		-- end

		-- local info = factionID and C_GossipInfo_GetFriendshipReputation(factionID)
		-- if info and info.friendshipFactionID and info.friendshipFactionID > 0 then
		-- 	standing, currentReactionThreshold, nextReactionThreshold, currentStanding = info.reaction, info.reactionThreshold or 0, info.nextThreshold or math.huge, info.standing or 1
		-- end

		-- if not standing and factionID and C_Reputation_IsFactionParagon(factionID) then
		-- 	local current, threshold
		-- 	current, threshold, _, rewardPending = C_Reputation_GetFactionParagonInfo(factionID)

		-- 	if current and threshold then
		-- 		standing, currentReactionThreshold, nextReactionThreshold, currentStanding, reaction = L["Paragon"], 0, threshold, current % threshold, 9
		-- 	end
		-- end

		-- if not standing and factionID and C_Reputation_IsMajorFaction(factionID) then
		-- 	local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
		-- 	local renownColor = { r = 0, g = 0.74, b = 0.95 }
		-- 	local renownHex = K.RGBToHex(renownColor.r, renownColor.g, renownColor.b)

		-- 	reaction, currentReactionThreshold, nextReactionThreshold = 10, 0, majorFactionData.renownLevelThreshold
		-- 	currentStanding = C_MajorFactions_HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold or majorFactionData.renownReputationEarned or 0
		-- 	standing = string_format("%s%s %s|r", renownHex, RENOWN_LEVEL_LABEL, majorFactionData.renownLevel)
		-- end

		-- if not standing then
		-- 	standing = _G["FACTION_STANDING_LABEL" .. reaction] or UNKNOWN
		-- end

		-- local customColors = true
		-- local customReaction = reaction == 9 or reaction == 10 -- 9 is paragon, 10 is renown
		-- local color = (customColors or customReaction) and K.Colors.faction[reaction] or _G.FACTION_BAR_COLORS[reaction]
		-- local alpha = (customColors and 1)
		-- local total = nextReactionThreshold == math.huge and 1 or nextReactionThreshold -- we need to correct the min/max of friendship factions to display the bar at 100%

		-- self:SetStatusBarColor(color.r or 1, color.g or 1, color.b or 1, alpha or 1)
		-- self:SetMinMaxValues((nextReactionThreshold == math.huge or currentReactionThreshold == nextReactionThreshold) and 0 or currentReactionThreshold, total) -- we force min to 0 because the min will match max when a rep is maxed and cause the bar to be 0%
		-- self:SetValue(currentStanding)

		-- self.reward:ClearAllPoints()
		-- self.reward:SetPoint("CENTER", self, "LEFT")
		-- self.reward:SetShown(rewardPending)

		-- local current, _, percent, capped = RepGetValues(currentStanding, currentReactionThreshold, total) -- Check these please.
		-- if capped then -- show only name and standing on exalted
		-- 	barDisplayString = string_format("%s: [%s]", name, standing)
		-- else
		-- 	barDisplayString = string_format("%s: %s - %d%% [%s]", name, K.ShortValue(current), percent, standing)
		-- end

		-- self:Show()
		-- self.text:SetText(barDisplayString)
	else
		self:Hide()
		self.text:SetText("")
	end
end

local function OnExpBarEnter(self)
	if GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR")

	-- Experience Tooltip
	if not XPIsLevelMax() then
		GameTooltip:AddDoubleLine("|cff0070ff" .. COMBAT_XP_GAIN .. "|r", format("%s %d", LEVEL, K.Level))

		if CurrentXP then
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(L["XP"], string_format(" %s / %s (%.2f%%)", K.ShortValue(CurrentXP), K.ShortValue(XPToLevel), PercentXP), 1, 1, 1)
		end

		if RemainXP then
			GameTooltip:AddDoubleLine(L["Remaining"], string_format(" %s (%.2f%% - %.2f " .. L["Bars"] .. ")", RemainXP, RemainTotal, RemainBars), 1, 1, 1)
		end

		if RestedXP > 0 then
			GameTooltip:AddDoubleLine(L["Rested"], string_format("+%s (%.2f%%)", K.ShortValue(RestedXP), PercentRested), 1, 1, 1)
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(altKeyText .. KEY_PLUS .. K.RightButton, sendExperienceText)
	end

	-- if C_Reputation_GetWatchedFactionData() then
	-- 	if not XPIsLevelMax() then
	-- 		GameTooltip:AddLine(" ")
	-- 	end

	-- 	local data = C_Reputation_GetWatchedFactionData()
	-- 	local name, reaction, currentReactionThreshold, nextReactionThreshold, currentStanding, factionID = data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID
	-- 	local isParagon = factionID and C_Reputation_IsFactionParagon(factionID)
	-- 	local standing

	-- 	if isParagon then
	-- 		local current, threshold = C_Reputation_GetFactionParagonInfo(factionID)
	-- 		if current and threshold then
	-- 			standing, currentReactionThreshold, nextReactionThreshold, currentStanding = L["Paragon"], 0, threshold, current % threshold
	-- 		end
	-- 	end

	-- 	if name then
	-- 		GameTooltip:AddLine(name, K.RGBToHex(0, 0.74, 0.95))
	-- 		GameTooltip:AddLine(" ")

	-- 		local info = factionID and C_GossipInfo.GetFriendshipReputation(factionID)
	-- 		if info and info.friendshipFactionID and info.friendshipFactionID > 0 then
	-- 			standing, currentReactionThreshold, nextReactionThreshold, currentStanding = info.reaction, info.reactionThreshold or 0, info.nextThreshold or math.huge, info.standing or 1
	-- 		end

	-- 		if not standing then
	-- 			standing = _G["FACTION_STANDING_LABEL" .. reaction] or UNKNOWN
	-- 		end

	-- 		local isMajorFaction = factionID and C_Reputation_IsMajorFaction(factionID)
	-- 		if not isMajorFaction then
	-- 			GameTooltip:AddDoubleLine(STANDING .. ":", standing, 1, 1, 1)
	-- 		end

	-- 		if not isParagon and isMajorFaction then
	-- 			local majorFactionData = C_MajorFactions_GetMajorFactionData(factionID)
	-- 			currentStanding = (C_MajorFactions_HasMaximumRenown(factionID) and majorFactionData.renownLevelThreshold) or majorFactionData.renownReputationEarned or 0
	-- 			nextReactionThreshold = majorFactionData.renownLevelThreshold
	-- 			GameTooltip:AddDoubleLine(RENOWN_LEVEL_LABEL .. majorFactionData.renownLevel, string_format("%d / %d (%d%%)", RepGetValues(currentStanding, 0, nextReactionThreshold)), BLUE_FONT_COLOR.r, BLUE_FONT_COLOR.g, BLUE_FONT_COLOR.b, 1, 1, 1)
	-- 		elseif (isParagon or (reaction ~= _G.MAX_REPUTATION_REACTION)) and nextReactionThreshold ~= math.huge then
	-- 			GameTooltip:AddDoubleLine(REPUTATION .. ":", string_format("%d / %d (%d%%)", RepGetValues(currentStanding, currentReactionThreshold, nextReactionThreshold)), 1, 1, 1)
	-- 		end

	-- 		-- Check for specific faction
	-- 		if factionID == 2465 then -- Translate "荒猎团" if necessary
	-- 			local repInfo = C_GossipInfo_GetFriendshipReputation(2463) -- Translate "玛拉斯缪斯" if necessary
	-- 			local rep, name, reaction, threshold, nextThreshold = repInfo.standing, repInfo.name, repInfo.reaction, repInfo.reactionThreshold, repInfo.nextThreshold
	-- 			if nextThreshold and rep > 0 then
	-- 				local current = rep - threshold
	-- 				local currentMax = nextThreshold - threshold
	-- 				GameTooltip:AddLine(" ") -- Translate if necessary
	-- 				GameTooltip:AddLine(name, 0, 0.6, 1) -- Translate "name" if necessary
	-- 				GameTooltip:AddDoubleLine(reaction, current .. " / " .. currentMax .. " (" .. floor(current / currentMax * 100) .. "%)", 0.6, 0.8, 1, 1, 1, 1) -- Translate "reaction" if necessary
	-- 			end
	-- 		end

	-- 		if factionID == 2465 then -- 荒猎团
	-- 			local repInfo = C_GossipInfo_GetFriendshipReputation(2463) -- 玛拉斯缪斯
	-- 			local rep, name, reaction, threshold, nextThreshold = repInfo.standing, repInfo.name, repInfo.reaction, repInfo.reactionThreshold, repInfo.nextThreshold
	-- 			if nextThreshold and rep > 0 then
	-- 				local current = rep - threshold
	-- 				local currentMax = nextThreshold - threshold
	-- 				GameTooltip:AddLine(" ")
	-- 				GameTooltip:AddLine(name, 0, 0.6, 1)
	-- 				GameTooltip:AddDoubleLine(reaction, current .. " / " .. currentMax .. " (" .. floor(current / currentMax * 100) .. "%)", 0.6, 0.8, 1, 1, 1, 1)
	-- 			end
	-- 		elseif factionID == 2574 then -- 梦境守望者
	-- 			local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(2649) -- 梦境注能
	-- 			local q = currencyInfo.quantity
	-- 			local m = currencyInfo.maxQuantity
	-- 			local name = C_CurrencyInfo.GetCurrencyInfo(2777).name
	-- 			GameTooltip:AddDoubleLine(name, q .. " / " .. m .. " (" .. floor(q / m * 100) .. "%)", 0.6, 0.8, 1, 1, 1, 1)
	-- 		end
	-- 	end
	-- end

	GameTooltip:Show()
end

local function OnExpBarLeave()
	K.HideTooltip()
end

local lastMessageTime = 0
local COOLDOWN_DURATION = 10 -- Cooldown duration in seconds

local function OnExpRepMouseUp(_, button)
	if IsAltKeyDown() and button == "RightButton" then
		local currentTime = GetTime()
		if currentTime - lastMessageTime >= COOLDOWN_DURATION then
			-- Ensure the player is in a group
			if not IsInGroup() then
				K.Print(ERR_QUEST_PUSH_NOT_IN_PARTY_S)
				return
			end

			-- Check if the player is not at max level
			if not XPIsLevelMax() then
				local currentXP, xpToNextLevel = UnitXP("player"), UnitXPMax("player")

				-- Ensure xpToNextLevel is not 0 to avoid division by zero
				if xpToNextLevel <= 0 then
					xpToNextLevel = 1
				end

				-- Calculate remaining XP and percentage
				local remainingXPPercent = ((xpToNextLevel - currentXP) / xpToNextLevel) * 100
				local nextLevel = UnitLevel("player") + 1
				local xpMessage = string.format("%.2f%% experience left until I reach level %d", remainingXPPercent, nextLevel)
				SendChatMessage(xpMessage, "PARTY")
			end
			lastMessageTime = currentTime
		else
			K.Print(SPELL_FAILED_CUSTOM_ERROR_808)
		end
	end
end

local ExpRep_EventList = {
	-- ALL
	"PLAYER_ENTERING_WORLD",
	-- Experience Events
	"PLAYER_LEVEL_UP",
	"UPDATE_EXHAUSTION",
	"PLAYER_XP_UPDATE",
	"ENABLE_XP_GAIN",
	"DISABLE_XP_GAIN",
	"UNIT_INVENTORY_CHANGED",
	-- Reputation
	"UPDATE_FACTION",
	"COMBAT_TEXT_UPDATE",
	"QUEST_FINISHED",
}

local function SetupExpRepScript(bar)
	for _, event in pairs(ExpRep_EventList) do
		bar:RegisterEvent(event)
	end

	OnExpBarEvent(bar)

	bar:SetScript("OnEvent", OnExpBarEvent)
	bar:SetScript("OnEnter", OnExpBarEnter)
	bar:SetScript("OnLeave", OnExpBarLeave)
	bar:SetScript("OnMouseUp", OnExpRepMouseUp)
end

function Module:CreateExpbar()
	if not C["Misc"].ExpRep then
		return
	end

	local bar = CreateFrame("StatusBar", "KKUI_ExpRepBar", MinimapCluster)
	bar:SetPoint("TOP", Minimap, "BOTTOM", 0, -6)
	bar:SetSize(Minimap:GetWidth() or 190, 16)
	bar:SetHitRectInsets(0, 0, 0, -10)
	bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

	local spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Textures.Spark16Texture)
	spark:SetHeight(bar:GetHeight() - 2)
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
	spark:SetAlpha(0.6)

	local border = CreateFrame("Frame", nil, bar)
	border:SetAllPoints(bar)
	border:SetFrameLevel(bar:GetFrameLevel())
	border:CreateBorder()

	local rest = CreateFrame("StatusBar", nil, bar)
	rest:SetAllPoints()
	rest:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	rest:SetStatusBarColor(1, 0, 1, 0.4)
	rest:SetFrameLevel(bar:GetFrameLevel() - 1)
	bar.restBar = rest

	local reward = bar:CreateTexture(nil, "OVERLAY")
	reward:SetAtlas("ParagonReputation_Bag")
	reward:SetSize(12, 14)
	bar.reward = reward

	local text = bar:CreateFontString(nil, "OVERLAY")
	text:SetFontObject(K.UIFont)
	text:SetFont(select(1, text:GetFont()), 11, select(3, text:GetFont()))
	text:SetWidth(bar:GetWidth() - 6)
	text:SetWordWrap(false)
	text:SetPoint("LEFT", bar, "RIGHT", -3, 0)
	text:SetPoint("RIGHT", bar, "LEFT", 3, 0)
	text:SetAlpha(0.8) -- Fade this a bit?
	bar.text = text

	SetupExpRepScript(bar)

	if not bar.mover then
		bar.mover = K.Mover(bar, "bar", "bar", { "TOP", Minimap, "BOTTOM", 0, -6 })
	else
		bar.mover:SetSize(Minimap:GetWidth() or 190, 14)
	end
end
Module:RegisterMisc("ExpRep", Module.CreateExpbar)
