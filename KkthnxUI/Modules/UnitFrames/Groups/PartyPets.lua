local K, C = unpack(select(2, ...))
if C["Party"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF
if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Party.lua code!")
	return
end

local _G = _G
local select = _G.select

local CreateFrame = _G.CreateFrame
local UnitIsUnit = _G.UnitIsUnit

function Module:CreatePartyPet()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(6)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(14)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Party"].HealthbarColor.Value == "Value" then
        self.Health.colorSmooth = true
        self.Health.colorClass = false
        self.Health.colorReaction = false
    elseif C["Party"].HealthbarColor.Value == "Dark" then
        self.Health.colorSmooth = false
        self.Health.colorClass = false
        self.Health.colorReaction = false
        self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
    else
        self.Health.colorSmooth = false
        self.Health.colorClass = true
        self.Health.colorReaction = true
    end

	if C["Party"].Smooth then
		self.Health.Smooth = true
	end

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 10, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(8)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.SetFrequentUpdates = true

	if C["Party"].Smooth then
		self.Power.Smooth = true
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetWidth(124)
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[color][name]")

	-- if C["Party"].ShowBuffs then
	-- 	self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
	-- 	self.Buffs:SetHeight(18)
	-- 	self.Buffs:SetWidth(108)
	-- 	self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
	-- 	self.Buffs.size = 18
	-- 	self.Buffs.num = 4
	-- 	self.Buffs.spacing = 6
	-- 	self.Buffs.initialAnchor = "TOPLEFT"
	-- 	self.Buffs["growth-y"] = "DOWN"
	-- 	self.Buffs["growth-x"] = "RIGHT"
	-- 	self.Buffs.PostCreateIcon = Module.PostCreateAura
	-- 	self.Buffs.PostUpdateIcon = Module.PostUpdateAura
	-- 	self.Buffs.CustomFilter = Module.CustomAuraFilter.Blacklist
	-- end

	-- self.Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
	-- self.Debuffs:SetHeight(18)
	-- self.Debuffs:SetWidth(92)
	-- self.Debuffs:SetPoint("LEFT", self.Health, "RIGHT", 6, 0)
	-- self.Debuffs.size = 18
	-- self.Debuffs.num = 5
	-- self.Debuffs.spacing = 6
	-- self.Debuffs.initialAnchor = "TOPLEFT"
	-- self.Debuffs["growth-y"] = "DOWN"
	-- self.Debuffs["growth-x"] = "RIGHT"
	-- self.Debuffs.PostCreateIcon = Module.PostCreateAura
	-- self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

	if (C["Party"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "PartyCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("TOPLEFT", 24, 22)
		self.Castbar:SetPoint("TOPRIGHT", 0, 22)
		self.Castbar:SetHeight(12)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.Castbar.OnUpdate = Module.OnCastbarUpdate
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostChannelStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostChannelStop = Module.PostChannelStop
		self.Castbar.PostCastFailed = Module.PostCastFailed
		self.Castbar.PostCastInterrupted = Module.PostCastFailed
		self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
		self.Castbar.PostCastNotInterruptible = Module.PostUpdateInterruptible
	end

	if C["Party"].ShowHealPrediction then
		local myBar = CreateFrame("StatusBar", nil, self)
		myBar:SetWidth(124)
		myBar:SetPoint("TOP", self.Health, "TOP")
		myBar:SetPoint("BOTTOM", self.Health, "BOTTOM")
		myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarTexture(HealPredictionTexture)
		myBar:SetStatusBarColor(0, 1, 0.5, 0.25)

		local otherBar = CreateFrame("StatusBar", nil, self)
		otherBar:SetWidth(124)
		otherBar:SetPoint("TOP", self.Health, "TOP")
		otherBar:SetPoint("BOTTOM", self.Health, "BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetStatusBarTexture(HealPredictionTexture)
		otherBar:SetStatusBarColor(0, 1, 0, 0.25)

		self.HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			maxOverflow = 1,
		}
	end

	self.StatusIndicator = self.Power:CreateFontString(nil, "OVERLAY")
	self.StatusIndicator:SetPoint("CENTER", 0, 0.5)
	self.StatusIndicator:SetFontObject(UnitframeFont)
	self.StatusIndicator:SetFont(select(1, self.StatusIndicator:GetFont()), 10, select(3, self.StatusIndicator:GetFont()))
	self:Tag(self.StatusIndicator, "[afkdnd]")

	if (C["Party"].TargetHighlight) then
		self.HighlightOverlayFrame = CreateFrame("Frame", nil, self)
		self.HighlightOverlayFrame:SetPoint("TOPLEFT", self.Health, -2, 2)
		self.HighlightOverlayFrame:SetPoint("BOTTOMRIGHT", self.Health, 2, -2)
		self.HighlightOverlayFrame:SetFrameLevel(7) -- Will always be above since 3D = 5 and Class and Default = 4

		self.TargetHighlight = self.HighlightOverlayFrame:CreateTexture(nil, "OVERLAY")
		self.TargetHighlight:SetTexture("Interface\\Buttons\\CheckButtonHilight")
		self.TargetHighlight:SetBlendMode("ADD")
		self.TargetHighlight:SetVertexColor(0.84, 0.75, 0.65)
		self.TargetHighlight:SetPoint("TOPLEFT", self.Health, -2, 2)
		self.TargetHighlight:SetPoint("BOTTOMRIGHT", self.Health, 2, -2)
		self.TargetHighlight:Hide()

		local function UpdatePartyTargetGlow()
			if UnitIsUnit("target", self.unit) then
				self.TargetHighlight:Show()
			else
				self.TargetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdatePartyTargetGlow, true)
	end

	self.ReadyCheckIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.ReadyCheckIndicator:SetSize(20, 20)
	self.ReadyCheckIndicator:SetPoint("LEFT", 0, 0)

	self.PhaseIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PhaseIndicator:SetSize(22, 22)
	self.PhaseIndicator:SetPoint("LEFT", self.Health, "RIGHT", 1, 0)

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	self.RaidTargetIndicator:SetSize(14, 14)

	if C["Unitframe"].DebuffHighlight then
		self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
		self.DebuffHighlight:SetAllPoints(self.Health)
		self.DebuffHighlight:SetTexture(C["Media"].Blank)
		self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		self.DebuffHighlight:SetBlendMode("ADD")

		self.DebuffHighlightAlpha = 0.45
		self.DebuffHighlightFilter = true
		self.DebuffHighlightFilterTable = K.DebuffHighlightColors
	end

	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
end