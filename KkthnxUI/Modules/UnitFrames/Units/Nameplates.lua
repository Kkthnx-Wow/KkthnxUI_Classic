local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF
local ThreatLib = LibStub:GetLibrary("ThreatClassic-1.0")

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Nameplates.lua code!")
	return
end

local _G = _G
-- local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local GetNumGroupMembers = _G.GetNumGroupMembers
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local UIParent = _G.UIParent
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitDetailedThreatSituation = _G.UnitDetailedThreatSituation
local UnitExists = _G.UnitExists
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsUnit = _G.UnitIsUnit
local UnitPower = _G.UnitPower
local UnitReaction = _G.UnitReaction
local UnitSelectionColor = _G.UnitSelectionColor

-- Threat Update Color For Health
local function threatColor(self, forced)
	if UnitIsPlayer(self.unit) then
		return
	end

	local combat = UnitAffectingCombat("player")
	local _, threatStatus = UnitDetailedThreatSituation("player", self.unit)

	if UnitAffectingCombat(self.unit) then
		local maxThreat = ThreatLib:GetMaxThreatOnTarget(UnitGUID(self.unit))
		if not maxThreat or maxThreat <= 0 then
			threatStatus = 3
		else
			self.Health:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
	end

	if C["Nameplates"].TankMode ~= true then
		self.Health.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
	end
	if UnitIsTapDenied(self.unit) then
		self.Health:SetStatusBarColor(0.6, 0.6, 0.6)
	elseif combat then
		if threatStatus == 3 then	-- securely tanking, highest threat
			if K.Role == "Tank" then
				if C["Nameplates"].TankMode == true then
					self.Health:SetStatusBarColor(unpack(C["Nameplates"].GoodColor))
				else
					self.Health.Shadow:SetBackdropBorderColor(unpack(C["Nameplates"].BadColor))
				end
			else
				if C["Nameplates"].TankMode == true then
					self.Health:SetStatusBarColor(unpack(C["Nameplates"].BadColor))
				else
					self.Health.Shadow:SetBackdropBorderColor(unpack(C["Nameplates"].BadColor))
				end
			end
		elseif threatStatus == 2 then	-- insecurely tanking, another unit have higher threat but not tanking
			if C["Nameplates"].TankMode == true then
				self.Health:SetStatusBarColor(unpack(C["Nameplates"].NearColor))
			else
				self.Health.Shadow:SetBackdropBorderColor(unpack(C["Nameplates"].NearColor))
			end
		elseif threatStatus == 1 then	-- not tanking, higher threat than tank
			if C["Nameplates"].TankMode == true then
				self.Health:SetStatusBarColor(unpack(C["Nameplates"].NearColor))
			else
				self.Health.Shadow:SetBackdropBorderColor(unpack(C["Nameplates"].NearColor))
			end
		elseif threatStatus == 0 then	-- not tanking, lower threat than tank
			if C["Nameplates"].TankMode == true then
				if K.Role == "Tank" then
					self.Health:SetStatusBarColor(unpack(C["Nameplates"].BadColor))
					if IsInGroup() or IsInRaid() then
						for i = 1, GetNumGroupMembers() do
							if UnitExists("raid"..i) and not UnitIsUnit("raid"..i, "player") then
								local isTanking = UnitDetailedThreatSituation("raid"..i, self.unit)
								if isTanking and UnitGroupRolesAssigned("raid"..i) == "TANK" then
									self.Health:SetStatusBarColor(unpack(C["Nameplates"].OffTankColor))
								end
							end
						end
					end
				else
					self.Health:SetStatusBarColor(unpack(C["Nameplates"].GoodColor))
				end
			end
		end
	elseif not forced then
		self.Health:ForceUpdate()
	end
end

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
	local main = self
	self.unit = unit

	local NameplateTexture = K.GetTexture(C["UITextures"].NameplateTextures)
	local Font = K.GetFont(C["UIFonts"].NameplateFonts)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	self:SetScale(UIParent:GetEffectiveScale())
	self:SetSize(C["Nameplates"].Width, C["Nameplates"].Height)
	self:SetPoint("CENTER")

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
		K.SmoothBar(self.Health)
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
		K.SmoothBar(self.Power)
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

			if caster == "player" then
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

	-- Classbars
	if C["Nameplates"].ClassResource then
		-- Module.CreateNamePlateClassPower(self)
	end

	local function ThreatLibCallback()
		return threatColor(main)
	end

	if ThreatLib then
		if not UnitIsPlayer(unit) and not UnitIsFriend("player", unit) then
			self.Health:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
		end
		ThreatLib.RegisterCallback(self.Health, "ThreatUpdated", ThreatLibCallback)
	end

	self.Health:SetScript("OnEvent", function(self, event)
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			local unitGUID = UnitGUID(unit)
			local _, _, _, srcGUID, _, _, _, dstGUID = CombatLogGetCurrentEventInfo()
			if unitGUID ~= srcGUID and unitGUID ~= dstGUID then
				return
			end
		end
		threatColor(main)
	end)

	self.Health.PostUpdate = function(self, unit, min, max)
		local perc = 0
		if max and max > 0 then
			perc = min / max
		end

		local r, g, b
		local unitReaction = UnitReaction(unit, "player")
		if not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and (unitReaction and unitReaction >= 5) then
			r, g, b = unpack(K.Colors.power["MANA"])
			self:SetStatusBarColor(r, g, b)
		elseif not UnitIsTapDenied(unit) and not UnitIsPlayer(unit) then
			local reaction = K.Colors.reaction[unitReaction]
			if reaction then
				r, g, b = reaction[1], reaction[2], reaction[3]
			else
				r, g, b = UnitSelectionColor(unit, true)
			end

			self:SetStatusBarColor(r, g, b)
		end

		if UnitIsPlayer(unit) then
			if perc <= 0.5 and perc >= 0.2 then
				self.Shadow:SetBackdropBorderColor(1, 1, 0)
			elseif perc < 0.2 then
				self.Shadow:SetBackdropBorderColor(1, 0, 0)
			else
				self.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
			end
		elseif not UnitIsPlayer(unit) and C["Nameplates"].TankMode == true then
			self.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
		end

		threatColor(main, true)
	end

	-- Register Events For Functions As Needed.
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateNameplateTarget, true)
	self:RegisterEvent("QUEST_LOG_UPDATE", Module.UpdateQuestUnit, true)
end