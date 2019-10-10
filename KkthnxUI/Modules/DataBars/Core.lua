local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DataBars")

local _G = _G
local string_format = _G.string.format
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS or _G.FACTION_BAR_COLORS[1]
local GameTooltip = _G.GameTooltip
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetXPExhaustion = _G.GetXPExhaustion
local MAX_PLAYER_LEVEL = _G.MAX_PLAYER_LEVEL
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

function Module:SetupExperience()
	local expbar = CreateFrame("StatusBar", "KKUI_ExperienceBar", self.container)
	expbar.text = expbar:CreateFontString(nil, "OVERLAY")
	expbar.spark = expbar:CreateTexture(nil, "OVERLAY")

	self.bars.experience = expbar
	self.bars.experience.text = expbar.text
	self.bars.experience.spark = expbar.spark

	local restbar = CreateFrame("StatusBar", "KKUI_RestBar", self.container)
	restbar:SetAllPoints(expbar)

	expbar.rested = restbar
end

function Module:SetupReputation()
	local reputation = CreateFrame("StatusBar", "KKUI_ReputationBar", self.container)
	reputation.text = reputation:CreateFontString(nil, "OVERLAY")
	reputation.spark = reputation:CreateTexture(nil, "OVERLAY")

	self.bars.reputation = reputation
	self.bars.reputation.spark = reputation.spark
end

function Module:Update()
	Module:UpdateExperience()
	Module:UpdateReputation()

	local num_bars = 0
	local prev
	for _, bar in pairs(Module.bars) do
		if bar:IsShown() then
			num_bars = num_bars + 1

			bar:ClearAllPoints()
			if prev then
				bar:SetPoint("TOP", prev, "BOTTOM", 0, -6)
			else
				bar:SetPoint("TOP", Module.container)
			end
			prev = bar
		end
	end

	Module.container:SetHeight(num_bars * (C["DataBars"].Height + 6) - 6)
end

function Module:UpdateConfig()
	self.bars.experience:SetStatusBarTexture(K.GetTexture(C["UITextures"].DataBarsTexture))
	self.bars.experience:SetStatusBarColor(unpack(C["DataBars"].ExperienceColor))
	self.bars.experience:SetFrameLevel(5)
	self.bars.experience:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	self.bars.experience:CreateBorder()

	self.bars.experience.text:SetFontObject(K.GetFont(C["UIFonts"].DataBarsFonts))
	self.bars.experience.text:SetFont(select(1, self.bars.experience.text:GetFont()), 11, select(3, self.bars.experience.text:GetFont()))
	self.bars.experience.text:SetPoint("CENTER")

	self.bars.experience.spark:SetTexture(C["Media"].Spark_16)
	self.bars.experience.spark:SetHeight(C["DataBars"].Height)
	self.bars.experience.spark:SetBlendMode("ADD")
	self.bars.experience.spark:SetPoint("CENTER", self.bars.experience:GetStatusBarTexture(), "RIGHT", 0, 0)

	self.bars.experience.rested:SetStatusBarTexture(C["Media"].Blank)
	self.bars.experience.rested:SetStatusBarColor(unpack(C["DataBars"].RestedColor))
	self.bars.experience.rested:SetFrameLevel(3)
	self.bars.experience.rested:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	self.bars.experience.rested:SetAlpha(1)

	self.bars.reputation:SetStatusBarTexture(K.GetTexture(C["UITextures"].DataBarsTexture))
	self.bars.reputation:SetStatusBarColor(1, 1, 1)
	self.bars.reputation:SetFrameLevel(5)
	self.bars.reputation:SetSize(C["DataBars"].Width, C["DataBars"].Height)
	self.bars.reputation:CreateBorder()

	self.bars.reputation.text:SetFontObject(K.GetFont(C["UIFonts"].DataBarsFonts))
	self.bars.reputation.text:SetFont(select(1, self.bars.reputation.text:GetFont()), 11, select(3, self.bars.reputation.text:GetFont()))
	self.bars.reputation.text:SetPoint("CENTER")

	self.bars.reputation.spark:SetTexture(C["Media"].Spark_16)
	self.bars.reputation.spark:SetHeight(C["DataBars"].Height)
	self.bars.reputation.spark:SetBlendMode("ADD")
	self.bars.reputation.spark:SetPoint("CENTER", self.bars.reputation:GetStatusBarTexture(), "RIGHT", 0, 0)
end

function Module:UpdateReputation()
	if GetWatchedFactionInfo() then
		local _, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		local current = value - minRep
		local max = maxRep - minRep
		local factionColor = FACTION_BAR_COLORS[rank]

		self.bars.reputation:SetMinMaxValues(0, max)
		self.bars.reputation:SetValue(current)

		self.bars.reputation:SetStatusBarColor(factionColor.r, factionColor.g, factionColor.b)

		self.bars.reputation.text:SetText(string_format("%s/%s (%d%%)", K.ShortValue(current, 1), K.ShortValue(max, 1), K.Round(current / max * 100)))

		self.bars.reputation:Show()
	else
		self.bars.reputation:Hide()
	end
end

function Module:UpdateExperience()
	if MAX_PLAYER_LEVEL ~= UnitLevel("player") then
		local current, max = UnitXP("player"), UnitXPMax("player")
		local rest = GetXPExhaustion()

		self.bars.experience:SetMinMaxValues(0, max)
		self.bars.experience:SetValue(current)
		self.bars.experience:SetStatusBarColor(unpack(rest and C["DataBars"].RestedColor or C["DataBars"].ExperienceColor))
		self.bars.experience.rested:SetMinMaxValues(0, max)
		self.bars.experience.rested:SetValue(rest and current + rest or 0)

		if rest and rest > 0 then
			self.bars.experience.text:SetText(string_format("%s - %s (%s%%) R:%s%%", K.ShortValue(current, 1), K.ShortValue(max, 1), K.Round(current / max * 100), K.Round(rest / max * 100)))
		else
			self.bars.experience.text:SetText(string_format("%s - %s (%s%%)", K.ShortValue(current, 1), K.ShortValue(max, 1), K.Round(current / max * 100)))
		end

		self.bars.experience:Show()
	else
		self.bars.experience:Hide()
	end
end

function Module:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:ClearLines()

	if MAX_PLAYER_LEVEL ~= UnitLevel("player") then
		local current, max = UnitXP("player"), UnitXPMax("player")
		local rest = GetXPExhaustion()

		GameTooltip:AddDoubleLine("Current XP:", string_format("%s/%s (%s%%)", K.ShortValue(current, 1), K.ShortValue(max, 1), K.Round(current / max * 100)), nil, nil, nil, 1, 1, 1)
		GameTooltip:AddDoubleLine("To go:", K.CommaValue(max-current), nil, nil, nil, 1, 1, 1)
		if rest then
			GameTooltip:AddDoubleLine("Rested:", string_format("%s (%s%%)", K.CommaValue(rest), K.Round(rest / max*100)), nil, nil, nil, 0, 0.6, 1)
		end
	end

	if GetWatchedFactionInfo() then
		-- Add a space between exp and rep
		if MAX_PLAYER_LEVEL ~= UnitLevel("player") then
			GameTooltip:AddLine(" ")
		end

		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		local current = value - minRep
		local max = maxRep - minRep

		local factionColor = FACTION_BAR_COLORS[rank]

		GameTooltip:AddDoubleLine(name, _G["FACTION_STANDING_LABEL"..rank], nil, nil, nil, factionColor.r, factionColor.g, factionColor.b)

		if max > 0 then
			GameTooltip:AddDoubleLine("Current:", string_format("%s/%s (%d%%)", K.ShortValue(current, 1), K.ShortValue(max, 1), K.Round(current / max * 100)), nil, nil, nil, 1,1,1)
			GameTooltip:AddDoubleLine("To go:", K.CommaValue(max-current), nil, nil, nil, 1,1,1)
		end
	end

	GameTooltip:Show()
end

function Module:OnLeave()
	GameTooltip:Hide()
end

function Module:OnEnable()
	self.container = CreateFrame("frame", "KKUI_Experience", UIParent)
	self.container:SetWidth(C["DataBars"].Width)
	self.container:SetPoint("TOP", "Minimap", "BOTTOM", 0, -6)
	self.container:SetScript("OnEnter", self.OnEnter)
	self.container:SetScript("OnLeave", self.OnLeave)

	self.bars = {}
	self:SetupExperience()
	self:SetupReputation()
	self:UpdateConfig()
	self:Update()

	K:RegisterEvent("PLAYER_ENTERING_WORLD", self.Update)

	K:RegisterEvent("PLAYER_LEVEL_UP", self.Update)
	K:RegisterEvent("PLAYER_XP_UPDATE", self.Update)
	K:RegisterEvent("UPDATE_EXHAUSTION", self.Update)

	K:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", self.Update)
	K:RegisterEvent("UPDATE_FACTION", self.Update)
end