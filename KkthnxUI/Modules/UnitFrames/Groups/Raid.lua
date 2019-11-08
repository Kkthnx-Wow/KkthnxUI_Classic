local K, C = unpack(select(2, ...))
if C["Raid"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF
if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Raid.lua code!")
	return
end

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame
local UnitIsUnit = _G.UnitIsUnit
local UnitPowerType = _G.UnitPowerType

local function UpdateRaidPower(self, _, unit)
    if self.unit ~= unit then
        return
    end

    local _, powerToken = UnitPowerType(unit)

    if powerToken == "MANA" and C["Raid"].ManabarShow then
        if not self.Power:IsVisible() then
            self.Health:ClearAllPoints()
            self.Health:SetPoint("BOTTOMLEFT", self, 0, 5)
            self.Health:SetPoint("TOPRIGHT", self)

            self.Power:Show()
        end
    else
        if self.Power:IsVisible() then
            self.Health:ClearAllPoints()
            self.Health:SetAllPoints(self)
            self.Power:Hide()
        end
    end
end

function Module:CreateRaid()
	local RaidframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local RaidframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	-- local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	Module.CreateHeader(self)

	self:CreateBorder()

	self.Health = CreateFrame("StatusBar", nil, self)
	--self.Health:SetFrameStrata("LOW")
	self.Health:SetFrameLevel(self:GetFrameLevel())
	self.Health:SetAllPoints(self)
	self.Health:SetStatusBarTexture(RaidframeTexture)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, 0, -9)
	self.Health.Value:SetFontObject(RaidframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 11, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[raidhp]")

	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Raid"].HealthbarColor.Value == "Value" then
        self.Health.colorSmooth = true
        self.Health.colorClass = false
        self.Health.colorReaction = false
    elseif C["Raid"].HealthbarColor.Value == "Dark" then
        self.Health.colorSmooth = false
        self.Health.colorClass = false
        self.Health.colorReaction = false
        self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
    else
        self.Health.colorSmooth = false
        self.Health.colorClass = true
        self.Health.colorReaction = true
    end

	if C["Raid"].Smooth then
		self.Health.Smooth = true
	end

	if C["Raid"].ManabarShow then
		self.Power = CreateFrame("StatusBar", nil, self)
		self.Power:SetFrameStrata("LOW")
		self.Power:SetFrameLevel(self:GetFrameLevel())
		self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -1)
        self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -1)
        self.Power:SetHeight(4.5)
		self.Power:SetStatusBarTexture(RaidframeTexture)

		self.Power.colorPower = true
        self.Power.Smooth = true
		self.Power.frequentUpdates = false

		if C["Raid"].Smooth then
			self.Power.Smooth = true
		end

		self.Power.Background = self.Power:CreateTexture(nil, "BORDER")
		self.Power.Background:SetAllPoints(self.Power)
		self.Power.Background:SetColorTexture(.2, .2, .2)
		self.Power.Background.multiplier = 0.3

		table.insert(self.__elements, UpdateRaidPower)
        self:RegisterEvent("UNIT_DISPLAYPOWER", UpdateRaidPower)
        UpdateRaidPower(self, _, unit)
	end

	-- -- HealPredictionAndAbsorb
	-- local mhpb = self.Health:CreateTexture(nil, "BORDER", nil, 5)
	-- mhpb:SetWidth(1)
	-- mhpb:SetTexture(HealPredictionTexture)
	-- mhpb:SetVertexColor(0, 1, 0.5, 0.25)

	-- local ohpb = self.Health:CreateTexture(nil, "BORDER", nil, 5)
	-- ohpb:SetWidth(1)
	-- ohpb:SetTexture(HealPredictionTexture)
	-- ohpb:SetVertexColor(0, 1, 0, 0.25)

	-- local abb = self.Health:CreateTexture(nil, "BORDER", nil, 5)
	-- abb:SetWidth(1)
	-- abb:SetTexture(HealPredictionTexture)
	-- abb:SetVertexColor(1, 1, 0, 0.25)

	-- local abbo = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
	-- abbo:SetAllPoints(abb)
	-- abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
	-- abbo.tileSize = 32

	-- local oag = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
	-- oag:SetWidth(15)
	-- oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
	-- oag:SetBlendMode("ADD")
	-- oag:SetAlpha(.7)
	-- oag:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 2)
	-- oag:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -2)

	-- local hab = CreateFrame("StatusBar", nil, self.Health)
	-- hab:SetPoint("TOP")
	-- hab:SetPoint("BOTTOM")
	-- hab:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
	-- hab:SetWidth(C["Raid"].Width)
	-- hab:SetReverseFill(true)
	-- hab:SetStatusBarTexture(HealPredictionTexture)
	-- hab:SetStatusBarColor(1, 0, 0, 0.25)

	-- local ohg = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
	-- ohg:SetWidth(15)
	-- ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
	-- ohg:SetBlendMode("ADD")
	-- ohg:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
	-- ohg:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)

	-- self.HealPredictionAndAbsorb = {
	-- 	myBar = mhpb,
	-- 	otherBar = ohpb,
	-- 	absorbBar = abb,
	-- 	absorbBarOverlay = abbo,
	-- 	overAbsorbGlow = oag,
	-- 	healAbsorbBar = hab,
	-- 	overHealAbsorbGlow = ohg,
	-- 	maxOverflow = 1,
	-- }

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 3, -15)
	self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", -3, -15)
	self.Name:SetFontObject(RaidframeFont)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[name]")

	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(self:GetFrameLevel() + 4)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY", 2)
	self.ReadyCheckIndicator:SetSize(22, 22)
	self.ReadyCheckIndicator:SetPoint("CENTER")

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(16, 16)
	self.RaidTargetIndicator:SetPoint("TOP", self, 0, 8)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(30, 30)
	self.ResurrectIndicator:SetPoint("CENTER", 0, -3)

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(12, 12)
	self.LeaderIndicator:SetPoint("TOPLEFT", -2, 7)

	if C["Raid"].ShowNotHereTimer then
		self.StatusIndicator = self:CreateFontString(nil, "OVERLAY")
		self.StatusIndicator:SetPoint("CENTER", self.Overlay, "BOTTOM", 0, 6)
		self.StatusIndicator:SetFontObject(RaidframeFont)
		self.StatusIndicator:SetFont(select(1, self.StatusIndicator:GetFont()), 10, select(3, self.StatusIndicator:GetFont()))
		self.StatusIndicator:SetTextColor(1, 0, 0)
		self:Tag(self.StatusIndicator, "[afkdnd]")
	end

	if C["Raid"].AuraWatch then
		self.AuraWatch = Module.CreateAuraWatch(self)
	end

	if C["Raid"].TargetHighlight then
		self.OverlayFrame = CreateFrame("Frame", nil, self)
		self.OverlayFrame:SetFrameLevel(self:GetFrameLevel() + 2)
		self.OverlayFrame:SetAllPoints()

		self.TargetHighlight = self.OverlayFrame:CreateTexture(nil, "OVERLAY")
		self.TargetHighlight:SetTexture([[Interface\RAIDFRAME\Raid-FrameHighlights]])
		self.TargetHighlight:SetTexCoord(0.00781250, 0.55468750, 0.28906250, 0.55468750)
		self.TargetHighlight:SetVertexColor(0.84, 0.75, 0.65)
		self.TargetHighlight:SetAllPoints()
		self.TargetHighlight:Hide()

		local function UpdateRaidTargetGlow()
			if UnitIsUnit("target", self.unit) then
				self.TargetHighlight:Show()
			else
				self.TargetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateRaidTargetGlow, true)
	end

	self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.DebuffHighlight:SetAllPoints(self.Health)
	self.DebuffHighlight:SetTexture(C["Media"].Blank)
	self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
	self.DebuffHighlight:SetBlendMode("ADD")
	self.DebuffHighlightAlpha = 0.45
	self.DebuffHighlightFilter = true
	self.DebuffHighlightFilterTable = K.DebuffHighlightColors

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.Range = {
		insideAlpha = 1,
		outsideAlpha = 0.5,
	}
end