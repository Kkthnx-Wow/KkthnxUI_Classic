local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- Caching global functions and variables
local math_min = math.min
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

-- Reputation
local function RepGetValues(curValue, minValue, maxValue)
	local maximum = maxValue - minValue
	local current, diff = curValue - minValue, maximum

	if diff == 0 then
		diff = 1
	end -- prevent a division by zero

	if current == maximum then
		return 1, 1, 100, true
	else
		return current, maximum, current / diff * 100
	end
end

-- Bar string
local barDisplayString = ""
local altKeyText = K.InfoColor .. ALT_KEY_TEXT .. " "

local function OnExpBarEvent(self)
	if not XPIsLevelMax() then
		CurrentXP, XPToLevel, RestedXP = UnitXP("player"), UnitXPMax("player"), (GetXPExhaustion() or 0)
		if XPToLevel <= 0 then
			XPToLevel = 1
		end

		local remainXP = XPToLevel - CurrentXP
		local remainPercent = remainXP / XPToLevel
		RemainTotal, RemainBars = remainPercent * 100, remainPercent * 20
		PercentXP, RemainXP = (CurrentXP / XPToLevel) * 100, K.ShortValue(remainXP)

		self:SetStatusBarColor(0, 0.4, 1, 0.8)
		self.restBar:SetStatusBarColor(1, 0, 1, 0.4)

		self:SetMinMaxValues(0, XPToLevel)
		self:SetValue(CurrentXP)
		barDisplayString = string_format("%s - %.2f%%", K.ShortValue(CurrentXP), PercentXP)

		local isRested = RestedXP > 0
		if isRested then
			self.restBar:SetMinMaxValues(0, XPToLevel)
			self.restBar:SetValue(math_min(CurrentXP + RestedXP, XPToLevel))

			PercentRested = (RestedXP / XPToLevel) * 100
			barDisplayString = string_format("%s R:%s [%.2f%%]", barDisplayString, K.ShortValue(RestedXP), PercentRested)
		end

		self:Show()
		self.restBar:SetShown(isRested)
		self.text:SetText(barDisplayString)
	elseif GetWatchedFactionInfo() then
		local name, reaction, minRep, maxRep, currentRep = GetWatchedFactionInfo()
		reaction = reaction == 0 and 1 or reaction

		local standing = _G["FACTION_STANDING_LABEL" .. reaction] or UNKNOWN
		local color = _G.FACTION_BAR_COLORS[reaction] or { r = 1, g = 1, b = 1 }
		local current, maximum, percent = RepGetValues(currentRep, minRep, maxRep)

		self:SetStatusBarColor(color.r, color.g, color.b)
		self:SetMinMaxValues(0, maximum)
		self:SetValue(current)

		local barDisplayString = string.format("%s: %s - %.2f%% [%s]", name, K.ShortValue(currentRep), percent, standing)
		self.text:SetText(barDisplayString)
		self:Show()
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

	if K.Class == "HUNTER" and UnitExists("pet") then
		local currPetXP, nextPetXP = GetPetExperience()

		if nextPetXP and nextPetXP > 0 then
			-- Calculate XP metrics
			local remainPetXP = nextPetXP - currPetXP
			local percentPetXP = (currPetXP / nextPetXP) * 100
			local remainPetFraction = remainPetXP / nextPetXP
			local remainPetPercent = remainPetFraction * 100
			local remainPetBars = remainPetFraction * 20

			-- Add pet XP tooltip details
			if not XPIsLevelMax() then
				GameTooltip:AddLine(" ")
			end

			GameTooltip:AddDoubleLine("|cff0070ff" .. PET .. " " .. COMBAT_XP_GAIN .. "|r", format("%s %d", LEVEL, UnitLevel("pet")))
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(L["XP"], string.format("%s / %s (%.2f%%)", K.ShortValue(currPetXP), K.ShortValue(nextPetXP), percentPetXP), 1, 1, 1)
			GameTooltip:AddDoubleLine(L["Remaining"], string.format("%s (%.2f%% - %.2f " .. L["Bars"] .. ")", K.ShortValue(remainPetXP), remainPetPercent, remainPetBars), 1, 1, 1)
		end
	end

	if GetWatchedFactionInfo() then
		if not XPIsLevelMax() then
			GameTooltip:AddLine(" ")
		end

		local name, reaction, minRep, maxRep, currentRep = GetWatchedFactionInfo()
		local standing = _G["FACTION_STANDING_LABEL" .. reaction] or UNKNOWN

		if name then
			-- Get the proper color for the current standing
			local color = _G.FACTION_BAR_COLORS[reaction] or { r = 1, g = 1, b = 1 }
			GameTooltip:AddDoubleLine(name, standing, nil, nil, nil, color.r, color.g, color.b)
			GameTooltip:AddLine(" ")

			-- Add reputation details if not at max standing
			if reaction ~= _G.MAX_REPUTATION_REACTION and maxRep then
				local current, maximum, percent = RepGetValues(currentRep, minRep, maxRep)
				GameTooltip:AddDoubleLine(REPUTATION .. ":", string.format("%s / %s (%.2f%%)", K.ShortValue(current), K.ShortValue(maximum), percent), 1, 1, 1)
			end
		end
	end

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
				SendChatMessage(xpMessage, K.CheckChat())
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
