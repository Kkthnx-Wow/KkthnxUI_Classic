local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Nameplates.lua code!")
	return
end

local _G = _G

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local UnitIsUnit = _G.UnitIsUnit
local UnitPower = _G.UnitPower

function Module:DisplayNameplatePowerAndCastBar(unit, cur)
	if not unit then
		unit = self:GetParent().unit
	end

	if not unit then
		return
	end

	if not cur then
		cur = UnitPower(unit)
	end

	local CurrentPower = cur
	local Nameplate = self:GetParent()
	local PowerBar = Nameplate.Power
	local CastBar = Nameplate.Castbar
	local IsPowerHidden = PowerBar.IsHidden

	if (CastBar:IsShown()) or (CurrentPower and CurrentPower == 0) then
		if (not IsPowerHidden) then
			PowerBar:Hide()
			PowerBar.IsHidden = true
		end
	else
		if IsPowerHidden then
			PowerBar:Show()
			PowerBar.IsHidden = false
		end
	end
end

-- Create The Plates. Where The Magic Happens
function Module:CreateNameplates(unit)
	self.unit = unit

	local NameplateTexture = K.GetTexture(C["UITextures"].NameplateTextures)
	local Font = K.GetFont(C["UIFonts"].NameplateFonts)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	self:SetSize(C["Nameplates"].Width, C["Nameplates"].Height)
	self:SetPoint("CENTER", 0, 0)
	self:SetScale(C["General"].UIScale)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetFrameStrata(self:GetFrameStrata())
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetHeight(C["Nameplates"].Height)
	self.Health:SetWidth(self:GetWidth())
	self.Health:SetStatusBarTexture(NameplateTexture)
	self.Health:CreateShadow(true)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Nameplates"].HealthbarColor.Value == "Value" then
        self.Health.colorSmooth = true
        self.Health.colorClass = false
        self.Health.colorReaction = false
    elseif C["Nameplates"].HealthbarColor.Value == "Dark" then
        self.Health.colorSmooth = false
        self.Health.colorClass = false
        self.Health.colorReaction = false
        self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
    else
        self.Health.colorSmooth = false
        self.Health.colorClass = true
        self.Health.colorReaction = true
    end

	if C["Nameplates"].Smooth then
		self.Health.Smooth = true
	end

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetFrameStrata(self:GetFrameStrata())
	self.Power:SetFrameLevel(4)
	self.Power:SetHeight(6)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)
	self.Power:SetStatusBarTexture(NameplateTexture)
	self.Power:CreateShadow(true)

	self.Power.IsHidden = false
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.PostUpdate = Module.DisplayNameplatePowerAndCastBar

	if C["Nameplates"].Smooth then
		self.Power.Smooth = true
	end

	if C["Nameplates"].HealthValue == true then
		self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self.Health.Value:SetFontObject(Font)
		self:Tag(self.Health.Value, "[nphp]")
	end

	self.Level = self.Health:CreateFontString(nil, "OVERLAY")
	self.Level:SetJustifyH("RIGHT")
	self.Level:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 4, 4)
	self.Level:SetFontObject(Font)
	self:Tag(self.Level, "[nplevel]")

	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetJustifyH("LEFT")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Level, "BOTTOMLEFT")
	self.Name:SetWidth(C["Nameplates"].Width * 0.85)
	self.Name:SetFontObject(Font)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[name]")

	if C["Nameplates"].TrackAuras == true then
		self.Auras = CreateFrame("Frame", self:GetName().."Debuffs", self)
		self.Auras:SetWidth(C["Nameplates"].Width)
		self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -4)
		self.Auras.num = 5 * 2
		self.Auras.spacing = 3
		self.Auras.size = ((((self.Auras:GetWidth() - (self.Auras.spacing * (self.Auras.num / 2 - 1))) / self.Auras.num)) * 2)
		self.Auras:SetHeight(self.Auras.size * 2)
		self.Auras.initialAnchor = "TOPLEFT"
		self.Auras["growth-y"] = "UP"
		self.Auras["growth-x"] = "RIGHT"
		self.Auras.disableMouse = true
		self.Auras.PostCreateIcon = Module.PostCreateAura
		self.Auras.PostUpdateIcon = Module.PostUpdateAura

		self.Auras.CustomFilter = function(_, unit, _, name, _, _, _, _, _, caster, _, nameplateShowSelf, _, _, _, _, nameplateShowAll)
			local allow = false

			if ((caster == "player") or (caster == "pet")) then
				if UnitIsUnit(unit, "player") then
					if ((nameplateShowAll or nameplateShowSelf) and not K.BuffBlackList[name]) then
						allow = true
					elseif K.BuffWhiteList[name] then
						allow = true
					end
				else
					if ((nameplateShowAll or nameplateShowSelf) and not K.DebuffBlackList[name]) then
						allow = true
					elseif K.DebuffWhiteList[name] then
						allow = true
					end
				end
			end

			return allow
		end
	end

	self.Castbar = CreateFrame("StatusBar", "NameplateCastbar", self)
	self.Castbar:SetFrameStrata(self:GetFrameStrata())
	self.Castbar:SetStatusBarTexture(NameplateTexture)
	self.Castbar:SetFrameLevel(6)
	self.Castbar:SetHeight(C["Nameplates"].Height)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -5)
	self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -5)
	self.Castbar:CreateShadow(true)

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetSize(64, C["Nameplates"].Height)
	self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
	self.Castbar.Spark:SetBlendMode("ADD")

	self.Castbar.decimal = "%.1f"

	self.Castbar.OnUpdate = Module.OnCastbarUpdate
	self.Castbar.PostCastStart = Module.PostCastStart
	self.Castbar.PostChannelStart = Module.PostCastStart
	self.Castbar.PostCastStop = Module.PostCastStop
	self.Castbar.PostChannelStop = Module.PostChannelStop
	self.Castbar.PostCastFailed = Module.PostCastFailed
	self.Castbar.PostCastInterrupted = Module.PostCastFailed
	self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
	self.Castbar.PostCastNotInterruptible = Module.PostUpdateInterruptible

	self.Castbar.timeToHold = 0.5

	self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
	self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
	self.Castbar.Time:SetJustifyH("RIGHT")
	self.Castbar.Time:SetFontObject(Font)
	self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:SetSize(self:GetHeight() * 2 + 5, self:GetHeight() * 2 + 5)
	self.Castbar.Button:CreateShadow(true)
	self.Castbar.Button:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -5, 0)

	self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetAllPoints()
	self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "ARTWORK", nil, 3)
	self.Castbar.Shield:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]])
	self.Castbar.Shield:SetTexCoord(0, 0.84375, 0, 1)
	self.Castbar.Shield:SetSize(16 * 0.84375, 16)
	self.Castbar.Shield:SetPoint("LEFT", self.Castbar, -7, 0)
	self.Castbar.Shield:SetVertexColor(0.5, 0.5, 0.7)

	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFontObject(Font)
	self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
	self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
	self.Castbar.Text:SetWordWrap(false)

	self.Castbar:SetScript("OnShow", Module.DisplayNameplatePowerAndCastBar)
	self.Castbar:SetScript("OnHide", Module.DisplayNameplatePowerAndCastBar)

	if C["Nameplates"].ShowHealPrediction then
		local myBar = CreateFrame("StatusBar", nil, self)
		myBar:SetWidth(self:GetWidth())
		myBar:SetPoint("TOP", self.Health, "TOP")
		myBar:SetPoint("BOTTOM", self.Health, "BOTTOM")
		myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarTexture(HealPredictionTexture)
		myBar:SetStatusBarColor(0, 1, 0.5, 0.25)

		local otherBar = CreateFrame("StatusBar", nil, self)
		otherBar:SetWidth(self:GetWidth())
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

	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(18, 18)
	self.RaidTargetIndicator:SetPoint("RIGHT", self, "LEFT", -6, 0)

	if C["Nameplates"].ClassIcons then
		self.Class = CreateFrame("Frame", nil, self)
		self.Class.Icon = self.Class:CreateTexture(nil, "OVERLAY")
		self.Class.Icon:SetSize(self:GetHeight() * 2 - 3, self:GetHeight() * 2 - 3)
		self.Class.Icon:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -5, 0)
		self.Class.Icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
		self.Class.Icon:SetTexCoord(0, 0, 0, 0)

		self.Class:SetAllPoints(self.Class.Icon)
		self.Class:CreateShadow(true)
	end

	if C["Nameplates"].QuestInfo then
		self.questIcon = self:CreateTexture(nil, "OVERLAY", nil, 2)
		self.questIcon:SetPoint("LEFT", self, "RIGHT", 2, 0)
		self.questIcon:SetSize(16, 16)
		self.questIcon:SetAtlas("adventureguide-microbutton-alert")
		self.questIcon:Hide()

		self.questCount  = K.CreateFontString(self, 11, "", nil, "LEFT", 0, 0)
		self.questCount:SetPoint("LEFT", self.questIcon, "RIGHT", 0, 0)

		self:RegisterEvent("QUEST_LOG_UPDATE", Module.UpdateQuestIndicator, true)
	end

	local iconFrame = CreateFrame("Frame", nil, self)
	iconFrame:SetAllPoints()
	iconFrame:SetFrameLevel(self:GetFrameLevel() + 2)
	self.creatureIcon = iconFrame:CreateTexture(nil, "ARTWORK")
	self.creatureIcon:SetAtlas("VignetteKill")
	self.creatureIcon:SetPoint("BOTTOMLEFT", self, "LEFT", 0, -2)
	self.creatureIcon:SetSize(16, 16)
	self.creatureIcon:SetAlpha(0)

	-- Target Arrow.
	if C["Nameplates"].TargetArrowMark.Value ~= "NONE" then
		self.targetArrowMark = self:CreateTexture(nil, "OVERLAY", nil, 1)
		self.targetArrowMark:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Nameplates\\arrow_single_right_64")
		self.targetArrowMark:SetSize(64, 64)
		self.targetArrowMark:SetScale(0.8)

		self.targetArrowMarkLeft = self:CreateTexture(nil, "OVERLAY", nil, 1)
		self.targetArrowMarkLeft:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Nameplates\\arrow_single_right_64")
		self.targetArrowMarkLeft:SetSize(64, 64)
		self.targetArrowMarkLeft:SetScale(0.6)

		self.targetArrowMarkRight = self:CreateTexture(nil, "OVERLAY", nil, 1)
		self.targetArrowMarkRight:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Nameplates\\arrow_single_right_64")
		self.targetArrowMarkRight:SetTexCoord(1, 0, 0, 1)
		self.targetArrowMarkRight:SetSize(64, 64)
		self.targetArrowMarkRight:SetScale(0.6)

		if C["Nameplates"].TargetArrowMark.Value == "LEFT/RIGHT" then
			self.targetArrowMarkLeft:SetPoint("RIGHT", self, "LEFT", -4, 0)
			self.targetArrowMarkRight:SetPoint("LEFT", self, "RIGHT", 4, 0)
		else
			self.targetArrowMark:SetPoint("BOTTOM", self, "TOP", 0, 60)
			self.targetArrowMark:SetRotation(math.rad(-90))
		end

		self.targetArrowMark:Hide()
		self.targetArrowMarkLeft:Hide()
		self.targetArrowMarkRight:Hide()
	end

	-- Target Highlight.
	self.targetHightlightMark = self.Health:CreateTexture(nil, "BACKGROUND", nil, -1)
	self.targetHightlightMark:SetHeight(12)
	self.targetHightlightMark:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -20, -2)
	self.targetHightlightMark:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 20, -2)
	self.targetHightlightMark:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
	self.targetHightlightMark:SetVertexColor(0, .6, 1)
	self.targetHightlightMark:Hide()

	-- Register Events For Functions As Needed.
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateNameplateTarget, true)
	self:RegisterEvent("QUEST_LOG_UPDATE", Module.UpdateQuestUnit, true)
end