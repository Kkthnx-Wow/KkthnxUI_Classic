local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if (not oUF) then
	K.Print("Could not find a vaild instance of oUF. Stopping Player.lua code!")
	return
end

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame

local function PostUpdateAddPower(element, _, cur, max)
	if element.Text and max > 0 then
		local perc = cur / max * 100
		if perc == 100 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = string.format("%d%%", perc)
			element:SetAlpha(1)
		end

		element.Text:SetText(perc)
	end
end

function Module:CreatePlayer(unit)
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(28)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.PostUpdate = C["General"].PortraitStyle.Value ~= "ThreeDPortraits" and Module.UpdateHealth
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		self.Health.Smooth = true
	end

	if C["Unitframe"].HealthbarColor.Value == "Value" then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor.Value == "Dark" then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(14)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		self.Power.Smooth = true
	end

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[power]")

	if C["General"].PortraitStyle.Value == "ThreeDPortraits" then
		self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
		self.Portrait:SetFrameStrata(self:GetFrameStrata())
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)
		self.Portrait:CreateBorder()
		self.Portrait:CreateInnerShadow()
	elseif C["General"].PortraitStyle.Value ~= "ThreeDPortraits" then
		self.Portrait = self.Health:CreateTexture("PlayerPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)

		self.Portrait.Border = CreateFrame("Frame", nil, self)
		self.Portrait.Border:SetAllPoints(self.Portrait)
		self.Portrait.Border:CreateBorder()
		self.Portrait.Border:CreateInnerShadow()

		if (C["General"].PortraitStyle.Value == "ClassPortraits" or C["General"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT", self.Portrait:GetWidth() + 6, 0)
	self.Health:SetPoint("TOPRIGHT")

	if C["Unitframe"].PlayerBuffs then
		self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)

		if K.Class == "ROGUE" or K.Class == "DRUID" then
			self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -26)
		else
			self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		end
		self.Buffs:SetWidth(156)
		self.Buffs.num = 6 * 4
		self.Buffs.spacing = 6
		self.Buffs.size = ((((self.Buffs:GetWidth() - (self.Buffs.spacing * (self.Buffs.num / 4 - 1))) / self.Buffs.num)) * 4)
		self.Buffs:SetHeight(self.Buffs.size * 4)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs.PostCreateIcon = Module.PostCreateAura
		self.Buffs.PostUpdateIcon = Module.PostUpdateAura
		self.Buffs.CustomFilter = Module.CustomAuraFilter.Blacklist
	end

	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "PlayerCastbar", self)
		self.Castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", 15, 266)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].PlayerCastbarWidth, C["Unitframe"].PlayerCastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		if C["Unitframe"].CastbarLatency then
			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "ARTWORK")
			self.Castbar.SafeZone:SetTexture(UnitframeTexture)
			self.Castbar.SafeZone:SetPoint("RIGHT")
			self.Castbar.SafeZone:SetPoint("TOP")
			self.Castbar.SafeZone:SetPoint("BOTTOM")
			self.Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)

			self.Castbar.Lag = self.Castbar:CreateFontString(nil, "OVERLAY")
			self.Castbar.Lag:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", -3.5, -3)
			self.Castbar.Lag:SetFontObject(UnitframeFont)
			self.Castbar.Lag:SetFont(select(1, self.Castbar.Lag:GetFont()), 11, select(3, self.Castbar.Lag:GetFont()))
			self.Castbar.Lag:SetTextColor(0.84, 0.75, 0.65)
			self.Castbar.Lag:SetJustifyH("RIGHT")
			self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent, true)
		end

		self.Castbar.decimal = "%.2f"

		self.Castbar.OnUpdate = Module.OnCastbarUpdate
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostChannelStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostChannelStop = Module.PostChannelStop
		self.Castbar.PostCastFail = Module.PostCastFailed
		self.Castbar.PostCastInterrupted = Module.PostCastFailed
		self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
		self.Castbar.PostCastNotInterruptible = Module.PostUpdateInterruptible

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
		self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Text:SetJustifyH("LEFT")
		self.Castbar.Text:SetWordWrap(false)

		self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
		self.Castbar.Button:SetSize(20, 20)
		self.Castbar.Button:CreateBorder()
		self.Castbar.Button:CreateInnerShadow()

		self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
		self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
		self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -6, 0)

		self.Castbar.Button:SetAllPoints(self.Castbar.Icon)

		K.Mover(self.Castbar, "PlayerCastBar", "PlayerCastBar", {"BOTTOM", UIParent, "BOTTOM", 15, 266})
	end

	if C["Unitframe"].ShowHealPrediction then
		local myBar = CreateFrame("StatusBar", nil, self)
		myBar:SetWidth(156)
		myBar:SetPoint("TOP", self.Health, "TOP")
		myBar:SetPoint("BOTTOM", self.Health, "BOTTOM")
		myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarTexture(HealPredictionTexture)
		myBar:SetStatusBarColor(0, 1, 0.5, 0.25)

		local otherBar = CreateFrame("StatusBar", nil, self)
		otherBar:SetWidth(156)
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

	if C["Unitframe"].ShowPlayerName then
		self.Name = self:CreateFontString(nil, "OVERLAY")
		self.Name:SetPoint("TOP", self.Health, 0, 16)
		self.Name:SetWidth(156)
		self.Name:SetFontObject(UnitframeFont)
		self:Tag(self.Name, "[color][name]")
	end

	-- Level
	if C["Unitframe"].ShowPlayerLevel and K.Level ~= _G.MAX_PLAYER_LEVEL then
		self.Level = self:CreateFontString(nil, "OVERLAY")
		self.Level:SetPoint("TOP", self.Portrait, 0, 15)
		self.Level:SetFontObject(UnitframeFont)
		self:Tag(self.Level, "[fulllevel]")
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(14, 14)
	self.LeaderIndicator:SetPoint("TOPLEFT", self.Overlay, "TOPLEFT", 0, 8)

	if (C["Unitframe"].Totems) and (K.Class == "SHAMAN") then
		self.Totems = CreateFrame("Frame", self:GetName() .. "Totems", self)
		self.Totems:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Totems:SetSize(156, 14)

		local Width = (144 / 4) - 1
		local Color

		for i = 1, 4 do
			Color = K.Colors.totems[i]

			self.Totems[i] = CreateFrame("StatusBar", self:GetName().."Totems"..i, self.Totems)
			self.Totems[i]:SetSize(Width, 14)
			self.Totems[i]:CreateBorder()
			self.Totems[i]:SetStatusBarTexture(UnitframeTexture)
			self.Totems[i]:SetStatusBarColor(Color[1], Color[2], Color[3])
			self.Totems[i]:SetMinMaxValues(0, 1)
			self.Totems[i]:SetValue(0)

			if (i == 1) then
				self.Totems[i]:SetPoint("LEFT", self.Totems, 1, 0)
			else
				self.Totems[i]:SetPoint("TOPLEFT", self.Totems[i - 1], "TOPRIGHT", 6, 0)
				self.Totems[i]:SetWidth(Width - 1)
			end
		end
	elseif (C["Unitframe"].ComboPoints) and (K.Class == "ROGUE" or K.Class == "DRUID") then
		self.ComboPoints = CreateFrame("Frame", self:GetName() .. "ComboPoints", self)
		self.ComboPoints:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.ComboPoints:SetSize(156, 14)

		local Width = (138 / 5)
		local Color

		for i = 1, 5 do
			Color = K.Colors.power.COMBO_POINTS[i]

			self.ComboPoints[i] = CreateFrame("StatusBar", self:GetName() .. "ComboPoints" .. i, self.ComboPoints)
			self.ComboPoints[i]:SetSize(Width, 14)
			self.ComboPoints[i]:CreateBorder()
			self.ComboPoints[i]:SetStatusBarTexture(UnitframeTexture)
			self.ComboPoints[i]:SetStatusBarColor(Color[1], Color[2], Color[3])
			self.ComboPoints[i]:SetAlpha(0.25)

			if (i == 1) then
				self.ComboPoints[i]:SetPoint("LEFT", self.ComboPoints, 1, 0)
			else
				self.ComboPoints[i]:SetPoint("TOPLEFT", self.ComboPoints[i - 1], "TOPRIGHT", 6, 0)
				self.ComboPoints[i]:SetWidth(Width - 2)
			end
		end
	end

	if C["Unitframe"].AdditionalPower and K.Class == "DRUID" then
		self.DruidMana = CreateFrame("StatusBar", nil, self)
		self.DruidMana:SetHeight(14)
		self.DruidMana:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 6)
		self.DruidMana:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 6)
		self.DruidMana:SetStatusBarTexture(UnitframeTexture)
		self.DruidMana:SetStatusBarColor(unpack(K.Colors.power["MANA"]))
		self.DruidMana:CreateBorder()

		if C["Unitframe"].Smooth then
			self.DruidMana.Smooth = true
		end

		self.DruidMana.Text = self.DruidMana:CreateFontString(nil, "OVERLAY")
		self.DruidMana.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
		self.DruidMana.Text:SetPoint("CENTER", self.DruidMana, "CENTER", 0, 0)

		self.DruidMana.PostUpdate = PostUpdateAddPower
	end

	if C["Unitframe"].EnergyTick then
		self.EnergyManaRegen = CreateFrame("StatusBar", nil, self.Power)
		self.EnergyManaRegen:SetFrameLevel(self.Power:GetFrameLevel() + 3)
		self.EnergyManaRegen:SetAllPoints()
		self.EnergyManaRegen.Spark = self.EnergyManaRegen:CreateTexture(nil, 'OVERLAY')
	end

	if C["Unitframe"].CombatText then
		local parentFrame = CreateFrame("Frame", nil, UIParent)
		self.FloatingCombatFeedback = CreateFrame("Frame", "oUF_Player_CombatTextFrame", parentFrame)
		self.FloatingCombatFeedback:SetSize(32, 32)
		K.Mover(self.FloatingCombatFeedback, "CombatText", "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})

		for i = 1, 36 do
			self.FloatingCombatFeedback[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
		end

		self.FloatingCombatFeedback.font = C["Media"].Font
		self.FloatingCombatFeedback.fontFlags = "OUTLINE"
		self.FloatingCombatFeedback.showPets = true
		self.FloatingCombatFeedback.showHots = true
		self.FloatingCombatFeedback.showAutoAttack = true
		self.FloatingCombatFeedback.showOverHealing = false
		self.FloatingCombatFeedback.abbreviateNumbers = true
		self.FloatingCombatFeedback.colors = {
			ABSORB = {0.84, 0.75, 0.65},
			BLOCK = {0.84, 0.75, 0.65},
			CRITENERGIZE = {0.31, 0.45, 0.63},
			CRITHEAL = {0.33, 0.59, 0.33},
			CRITICAL = {0.69, 0.31, 0.31},
			CRUSHING = {0.69, 0.31, 0.31},
			DAMAGE = {0.69, 0.31, 0.31},
			ENERGIZE = {0.31, 0.45, 0.63},
			GLANCING = {0.69, 0.31, 0.31},
			HEAL = {0.33, 0.59, 0.33},
			IMMUNE = {0.84, 0.75, 0.65},
			MISS = {0.84, 0.75, 0.65},
			RESIST = {0.84, 0.75, 0.65},
			STANDARD = {0.84, 0.75, 0.65},
		}
	end

	if C["Unitframe"].Swingbar then
		self.Swing = CreateFrame("StatusBar", "PlayerSwingbar", self)
		self.Swing:SetSize(250, 12)
		self.Swing:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -5)

		self.Swing.Twohand = CreateFrame("StatusBar", nil, self.Swing)
		self.Swing.Twohand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Twohand:SetStatusBarColor(86/255, 150/255, 188/255)
		self.Swing.Twohand:CreateBorder()
		self.Swing.Twohand:Hide()
		self.Swing.Twohand:SetAllPoints()

		self.Swing.Twohand.Spark = self.Swing.Twohand:CreateTexture(nil, "OVERLAY")
		self.Swing.Twohand.Spark:SetTexture(C["Media"].Spark_16)
		self.Swing.Twohand.Spark:SetHeight(C["DataBars"].Height)
		self.Swing.Twohand.Spark:SetBlendMode("ADD")
		self.Swing.Twohand.Spark:SetPoint("CENTER", self.Swing.Twohand:GetStatusBarTexture(), "RIGHT", 0, 0)

		self.Swing.Mainhand = CreateFrame("StatusBar", nil, self.Swing)
		self.Swing.Mainhand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Mainhand:SetStatusBarColor(86/255, 150/255, 188/255)
		self.Swing.Mainhand:CreateBorder()
		self.Swing.Mainhand:Hide()
		self.Swing.Mainhand:SetAllPoints()

		self.Swing.Mainhand.Spark = self.Swing.Mainhand:CreateTexture(nil, "OVERLAY")
		self.Swing.Mainhand.Spark:SetTexture(C["Media"].Spark_16)
		self.Swing.Mainhand.Spark:SetHeight(C["DataBars"].Height)
		self.Swing.Mainhand.Spark:SetBlendMode("ADD")
		self.Swing.Mainhand.Spark:SetPoint("CENTER", self.Swing.Mainhand:GetStatusBarTexture(), "RIGHT", 0, 0)

		self.Swing.Offhand = CreateFrame("StatusBar", nil, self.Swing)
		self.Swing.Offhand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Offhand:SetStatusBarColor(224/255, 72/255, 54/255)
		self.Swing.Offhand:CreateBorder()
		self.Swing.Offhand:Hide()
		self.Swing.Offhand:SetPoint("TOPLEFT", self.Swing, "BOTTOMLEFT", 0, -6)
		self.Swing.Offhand:SetPoint("BOTTOMRIGHT", self.Swing, "BOTTOMRIGHT", 0, -18)

		self.Swing.Offhand.Spark = self.Swing.Offhand:CreateTexture(nil, "OVERLAY")
		self.Swing.Offhand.Spark:SetTexture(C["Media"].Spark_16)
		self.Swing.Offhand.Spark:SetHeight(C["DataBars"].Height)
		self.Swing.Offhand.Spark:SetBlendMode("ADD")
		self.Swing.Offhand.Spark:SetPoint("CENTER", self.Swing.Offhand:GetStatusBarTexture(), "RIGHT", 0, 0)

		K.Mover(self.Swing, "PlayerSwingBar", "PlayerSwingBar", {"TOP", self.Castbar, "BOTTOM", 0, -5})

		if C["Unitframe"].SwingbarTimer then
			self.Swing.Text = self.Swing:CreateFontString(nil, "OVERLAY")
			self.Swing.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.Text:SetPoint("CENTER", 1, 0)
			self.Swing.Text:SetWordWrap(false)

			self.Swing.TextMH = self.Swing.Mainhand:CreateFontString(nil, "OVERLAY")
			self.Swing.TextMH:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.TextMH:SetPoint("CENTER", 1, 0)
			self.Swing.TextMH:SetWordWrap(false)

			self.Swing.TextOH = self.Swing.Offhand:CreateFontString(nil, "OVERLAY")
			self.Swing.TextOH:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.TextOH:SetPoint("CENTER", 1, 0)
			self.Swing.TextOH:SetWordWrap(false)
		end

		self.Swing.hideOoc = true
	end

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		self.PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT", -2, 0)
		self.PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator
	end

	self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.CombatIndicator:SetSize(20, 20)
	self.CombatIndicator:SetPoint("LEFT", 0, 0)
	self.CombatIndicator:SetVertexColor(1, 0.2, 0.2, 1)

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	self.ReadyCheckIndicator:SetSize(self.Portrait:GetWidth() - 4, self.Portrait:GetHeight() - 4)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)

	self.RestingIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RestingIndicator:SetPoint("RIGHT", 0, 2)
	self.RestingIndicator:SetSize(22, 22)
	self.RestingIndicator:SetAlpha(0.7)

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

	if C["Unitframe"].PortraitTimers then
		self.PortraitTimer = CreateFrame("Frame", "$parentPortraitTimer", self.Health)
		self.PortraitTimer:CreateInnerShadow()
		self.PortraitTimer:SetFrameLevel(5) -- Watch me
		self.PortraitTimer:SetInside(self.Portrait, 1, 1)
		self.PortraitTimer:Hide()
	end

	if C["Unitframe"].GlobalCooldown then
		self.GlobalCooldown = CreateFrame("Frame", nil, self.Health)
		self.GlobalCooldown:SetWidth(156)
		self.GlobalCooldown:SetHeight(28)
		self.GlobalCooldown:SetFrameStrata("HIGH")
		self.GlobalCooldown:SetPoint("LEFT", self.Health, "LEFT", 0, 0)
	end

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.CombatFade = C["Unitframe"].CombatFade
end