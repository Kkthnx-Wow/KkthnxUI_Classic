local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G
local select = _G.select
local string_format = _G.string.format

local CreateFrame = _G.CreateFrame

local playerWidth = C["Unitframe"].PlayerFrameWidth

function Module.PostUpdateAddPower(element, cur, max)
	if element.Text and max > 0 then
		local perc = cur / max * 100
		if perc == 100 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = string_format("%d%%", perc)
			element:SetAlpha(1)
		end

		element.Text:SetText(perc)
	end
end

local function updatePartySync(self)
	local hasJoined = C_QuestSession.HasJoined()
	if(hasJoined) then
		self.QuestSyncIndicator:Show()
	else
		self.QuestSyncIndicator:Hide()
	end
end

function Module:CreatePlayer()
	self.mystyle = "player"

	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	if C["Unitframe"].PlayerPower then
		self.Health:SetHeight(C["Unitframe"].PlayerFrameHeight * 0.7)
	else
		self.Health:SetHeight(C["Unitframe"].PlayerFrameHeight + 6)
	end
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.PostUpdate = C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" and Module.UpdateHealth
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Health)
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
	if C["Unitframe"].PlayerPower then
		self.Power:SetHeight(C["Unitframe"].PlayerFrameHeight * 0.3)
	else
		self.Power:SetHeight(0)
	end
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Power)
	end

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[power]")

	local portraitSize
	if C["Unitframe"].PlayerPower and C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		portraitSize = self.Health:GetHeight() + self.Power:GetHeight() + 6
	else
		portraitSize = self.Health:GetHeight() + self.Power:GetHeight()
	end

	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_PlayerPortrait", self.Health)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetSize(portraitSize, portraitSize)
			self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
			self.Portrait:CreateBorder()
		elseif C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" then
			self.Portrait = self.Health:CreateTexture("KKUI_PlayerPortrait", "BACKGROUND", nil, 1)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			self.Portrait:SetSize(portraitSize, portraitSize)
			self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)

			self.Portrait.Border = CreateFrame("Frame", nil, self)
			self.Portrait.Border:SetAllPoints(self.Portrait)
			self.Portrait.Border:CreateBorder()

			if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
				self.Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	if C["Unitframe"].ClassResources and not C["Nameplate"].ShowPlayerPlate then
		Module:CreateClassPower(self)
	end

	if C["Unitframe"].PlayerDeBuffs then
		local width = playerWidth - portraitSize

		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.spacing = 6
		self.Debuffs.initialAnchor = "BOTTOMLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 26)
		self.Debuffs.num = 14
		self.Debuffs.iconsPerRow = 5

		self.Debuffs.size = Module.auraIconSize(width, self.Debuffs.iconsPerRow, self.Debuffs.spacing)
		self.Debuffs:SetWidth(width)
		self.Debuffs:SetHeight((self.Debuffs.size + self.Debuffs.spacing) * math.floor(self.Debuffs.num / self.Debuffs.iconsPerRow + .5))

		self.Debuffs.CustomFilter = Module.CustomFilter
		self.Debuffs.PostCreateIcon = Module.PostCreateAura
		self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

		-- self.Debuffs:CreateBorder()
	end

	if C["Unitframe"].PlayerBuffs then
		local width = playerWidth - portraitSize

		self.Buffs = CreateFrame("Frame", nil, self)
		if C["Unitframe"].PlayerPower then
			self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		else
			self.Buffs:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
		end
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs.num = 6
		self.Buffs.spacing = 6
		self.Buffs.iconsPerRow = 6
		self.Buffs.onlyShowPlayer = false

		self.Buffs.size = Module.auraIconSize(width, self.Buffs.iconsPerRow, self.Buffs.spacing)
		self.Buffs:SetWidth(width)
		self.Buffs:SetHeight((self.Buffs.size + self.Buffs.spacing) * math.floor(self.Buffs.num/self.Buffs.iconsPerRow + .5))

		self.Buffs.CustomFilter = Module.CustomFilter
		self.Buffs.PostCreateIcon = Module.PostCreateAura
		self.Buffs.PostUpdateIcon = Module.PostUpdateAura
	end

	if C["Unitframe"].PlayerCastbar then
		self.Castbar = CreateFrame("StatusBar", "PlayerCastbar", self)
		self.Castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", 14, 200)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].PlayerCastbarWidth, C["Unitframe"].PlayerCastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
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
			--self:RegisterEvent("GLOBAL_MOUSE_UP", Module.OnCastSent, true) -- Fix quests with WorldFrame interaction
			--self:RegisterEvent("GLOBAL_MOUSE_DOWN", Module.OnCastSent, true)
			self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent, true)
		end

		self.Castbar.decimal = "%.2f"

		self.Castbar.OnUpdate = Module.OnCastbarUpdate
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostCastFail = Module.PostCastFailed
		self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible

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

		self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
		self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
		self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -6, 0)

		self.Castbar.Button:SetAllPoints(self.Castbar.Icon)

		local mover = K.Mover(self.Castbar, "Player Castbar", "PlayerCB", {"BOTTOM", UIParent, "BOTTOM", 14, 200})
		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("RIGHT", mover)
		self.Castbar.mover = mover
	end

	if C["Unitframe"].ShowHealPrediction then
		local myBar = CreateFrame("StatusBar", nil, self)
		myBar:SetWidth(self:GetWidth())
		myBar:SetPoint("TOP", self.Health, "TOP")
		myBar:SetPoint("BOTTOM", self.Health, "BOTTOM")
		myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarTexture(HealPredictionTexture)
		myBar:SetStatusBarColor(0, 1, 0, .5)
		myBar:Hide()

		local otherBar = CreateFrame("StatusBar", nil, self)
		otherBar:SetWidth(self:GetWidth())
		otherBar:SetPoint("TOP", self.Health, "TOP")
		otherBar:SetPoint("BOTTOM", self.Health, "BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetStatusBarTexture(HealPredictionTexture)
		otherBar:SetStatusBarColor(0, 1, 1, .5)
		otherBar:Hide()

		self.HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			maxOverflow = 1,
		}
	end

	if C["Unitframe"].PlayerPowerPrediction then
		-- local mainBar = CreateFrame("StatusBar", self:GetName().."PowerPrediction", self.Power)
		-- mainBar:SetReverseFill(true)
		-- mainBar:SetPoint("TOP", 0, -1)
		-- mainBar:SetPoint("BOTTOM", 0, 1)
		-- mainBar:SetPoint("RIGHT", self.Power:GetStatusBarTexture(), "RIGHT", -1, 0)
		-- mainBar:SetStatusBarTexture(HealPredictionTexture)
		-- mainBar:SetStatusBarColor(0.8, 0.1, 0.1, 0.6)
		-- mainBar:SetWidth(playerWidth)

		-- self.PowerPrediction = {
		-- 	mainBar = mainBar
		-- }
	end

	if C["Unitframe"].ShowPlayerName then
		self.Name = self:CreateFontString(nil, "OVERLAY")
		self.Name:SetPoint("TOP", self.Health, 0, 16)
		self.Name:SetWidth(playerWidth)
		self.Name:SetFontObject(UnitframeFont)
		if C["Unitframe"].PortraitStyle.Value == "NoPortraits" then
			if C["Unitframe"].HealthbarColor.Value == "Class" then
				self:Tag(self.Name, "[name] [fulllevel][afkdnd]")
			else
				self:Tag(self.Name, "[color][name] [fulllevel][afkdnd]")
			end
		else
			if C["Unitframe"].HealthbarColor.Value == "Class" then
				self:Tag(self.Name, "[name][afkdnd]")
			else
				self:Tag(self.Name, "[color][name][afkdnd]")
			end
		end
	end

	-- Level
	if C["Unitframe"].ShowPlayerLevel then
		self.Level = self:CreateFontString(nil, "OVERLAY")
		if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
			self.Level:Show()
			self.Level:SetPoint("TOP", self.Portrait, 0, 15)
		else
			self.Level:Hide()
		end
		self.Level:SetFontObject(UnitframeFont)
		self:Tag(self.Level, "[fulllevel]")
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(14, 14)
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		self.LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 0, 8)
	else
		self.LeaderIndicator:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -8, 8)
	end

	if C["Unitframe"].Stagger then
		if K.Class == "MONK" then
			self.Stagger = CreateFrame("StatusBar", self:GetName().."Stagger", self)
			self.Stagger:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 6)
			self.Stagger:SetSize(playerWidth - portraitSize, 14)
			self.Stagger:SetStatusBarTexture(UnitframeTexture)
			self.Stagger:CreateBorder()

			self.Stagger.Value = self.Stagger:CreateFontString(nil, "OVERLAY")
			self.Stagger.Value:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Stagger.Value:SetPoint("CENTER", self.Stagger, "CENTER", 0, 0)
			self:Tag(self.Stagger.Value, "[monkstagger]")
		end
	end

	if C["Unitframe"].AdditionalPower then
		self.AdditionalPower = CreateFrame("StatusBar", self:GetName().."AdditionalPower", self.Health)
		self.AdditionalPower:SetHeight(5)
		self.AdditionalPower:SetPoint("BOTTOMLEFT", self.Health, 2, 2)
		self.AdditionalPower:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
		self.AdditionalPower:SetStatusBarTexture(K.GetTexture(C["UITextures"].UnitframeTextures))
		self.AdditionalPower:SetStatusBarColor(unpack(K.Colors.power.MANA))
		self.AdditionalPower.frequentUpdates = true

		if C["Unitframe"].Smooth then
			K:SmoothBar(self.AdditionalPower)
		end

		self.AdditionalPower.Spark = self.AdditionalPower:CreateTexture(nil, "OVERLAY")
		self.AdditionalPower.Spark:SetTexture(C["Media"].Textures.Spark16Texture)
		self.AdditionalPower.Spark:SetAlpha(0.4)
		self.AdditionalPower.Spark:SetHeight(5)
		self.AdditionalPower.Spark:SetBlendMode("ADD")
		self.AdditionalPower.Spark:SetPoint("CENTER", self.AdditionalPower:GetStatusBarTexture(), "RIGHT", 0, 0)

		self.AdditionalPower.Background = self.AdditionalPower:CreateTexture(nil, "BORDER")
		self.AdditionalPower.Background:SetAllPoints(self.AdditionalPower)
		self.AdditionalPower.Background:SetColorTexture(0.2, 0.2, 0.2)
		self.AdditionalPower.Background.multiplier = 0.3

		self.AdditionalPower.Text = self.AdditionalPower:CreateFontString(nil, "OVERLAY")
		self.AdditionalPower.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
		self.AdditionalPower.Text:SetFont(select(1, self.AdditionalPower.Text:GetFont()), 9, select(3, self.AdditionalPower.Text:GetFont()))
		self.AdditionalPower.Text:SetPoint("LEFT", self.AdditionalPower, "LEFT", 1, 1)

		self.AdditionalPower.PostUpdate = Module.PostUpdateAddPower
		self.AdditionalPower.displayPairs = {
			["DRUID"] = {
				[1] = true,
				[3] = true,
				[8] = true,
			},

			["SHAMAN"] = {
				[11] = true,
			},

			["PRIEST"] = {
				[13] = true,
			}
		}
	end

	-- GCD spark
	if C["Unitframe"].GlobalCooldown then
		self.GCD = CreateFrame("Frame", self:GetName().."_GlobalCooldown", self)
		self.GCD:SetWidth(playerWidth - portraitSize)
		self.GCD:SetHeight(self.Health:GetHeight())
		self.GCD:SetFrameStrata("HIGH")
		self.GCD:SetPoint("LEFT", self.Health, "LEFT", 0, 0)

		self.GCD.Color = {1, 1, 1}
		self.GCD.Height = 26
		self.GCD.Width = 128
	end

	-- if C["Unitframe"].EnergyTick then
		if K.Class ~= "WARRIOR" then
		self.EnergyManaRegen = CreateFrame("StatusBar", nil, self.Power)
		self.EnergyManaRegen:SetFrameLevel(self.Power:GetFrameLevel() + 3)
		self.EnergyManaRegen:SetAllPoints()
		self.EnergyManaRegen.Spark = self.EnergyManaRegen:CreateTexture(nil, 'OVERLAY')
		end
	-- end

	if C["Unitframe"].CombatText then
		if IsAddOnLoaded("MikScrollingBattleText") or IsAddOnLoaded("Parrot") or IsAddOnLoaded("xCT") or IsAddOnLoaded("sct") then
			C["Unitframe"].CombatText = false
			return
		end

		local parentFrame = CreateFrame("Frame", nil, UIParent)
		self.FloatingCombatFeedback = CreateFrame("Frame", "oUF_Player_CombatTextFrame", parentFrame)
		self.FloatingCombatFeedback:SetSize(32, 32)
		K.Mover(self.FloatingCombatFeedback, "CombatText", "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})

		for i = 1, 36 do
			self.FloatingCombatFeedback[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
		end

		self.FloatingCombatFeedback.font = C["Media"].Fonts.DamageFont

		self.FloatingCombatFeedback.fontFlags = "OUTLINE"
		self.FloatingCombatFeedback.showPets = C["Unitframe"].PetCombatText
		self.FloatingCombatFeedback.showHots = C["Unitframe"].HotsDots
		self.FloatingCombatFeedback.showAutoAttack = C["Unitframe"].AutoAttack
		self.FloatingCombatFeedback.showOverHealing = C["Unitframe"].FCTOverHealing
		self.FloatingCombatFeedback.abbreviateNumbers = true

		-- Default CombatText
		SetCVar("enableFloatingCombatText", 0)
		K.HideInterfaceOption(InterfaceOptionsCombatPanelEnableFloatingCombatText)
	end

	-- Swing timer
	if C["Unitframe"].Swingbar then
		local swingWidth = C["Unitframe"].PlayerCastbarWidth - C["Unitframe"].PlayerCastbarHeight - 5

		self.Swing = CreateFrame("Frame", "KKUI_SwingBar", self)
		self.Swing:SetSize(swingWidth, 14)
		-- self.Swing:SetPoint("BOTTOM", self.Castbar.mover, "BOTTOM", 0, -22)
		self.Swing:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 180)

		self.Swing.Twohand = CreateFrame("Statusbar", nil, self.Swing)
		self.Swing.Twohand:SetPoint("TOPLEFT")
		self.Swing.Twohand:SetPoint("BOTTOMRIGHT")
		self.Swing.Twohand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Twohand:SetStatusBarColor(0.8, 0.3, 0.3)
		self.Swing.Twohand:SetFrameLevel(20)
		self.Swing.Twohand:SetFrameStrata("LOW")
		self.Swing.Twohand:Hide()
		self.Swing.Twohand:CreateBorder()

		if C["Unitframe"].SwingbarTimer then
			self.Swing.Twohand.Text = self.Swing.Twohand:CreateFontString(nil, "OVERLAY")
			self.Swing.Twohand.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.Twohand.Text:SetPoint("LEFT", self.Swing.Twohand, 3, 0)
			self.Swing.Twohand.Text:SetSize(260 * 0.7, 14)
			self.Swing.Twohand.Text:SetJustifyH("LEFT")
		end

		self.Swing.Twohand.Spark = self.Swing.Twohand:CreateTexture(nil, "OVERLAY")
		self.Swing.Twohand.Spark:SetTexture(C["Media"].Textures.Spark16Texture)
		self.Swing.Twohand.Spark:SetHeight(self.Swing:GetHeight())
		self.Swing.Twohand.Spark:SetBlendMode("ADD")
		self.Swing.Twohand.Spark:SetPoint("CENTER", self.Swing.Twohand:GetStatusBarTexture(), "RIGHT", 0, 0)

		self.Swing.Mainhand = CreateFrame("Statusbar", nil, self.Swing)
		-- self.Swing.Mainhand:SetPoint("BOTTOM", self.Castbar.mover, "BOTTOM", 0, -22)
		self.Swing.Mainhand:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 180)
		self.Swing.Mainhand:SetSize(swingWidth, 14)
		self.Swing.Mainhand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Mainhand:SetStatusBarColor(0.8, 0.3, 0.3)
		self.Swing.Mainhand:SetFrameLevel(20)
		self.Swing.Mainhand:SetFrameStrata("LOW")
		self.Swing.Mainhand:Hide()
		self.Swing.Mainhand:CreateBorder()

		if C["Unitframe"].SwingbarTimer then
			self.Swing.Mainhand.Text = self.Swing.Mainhand:CreateFontString(nil, "OVERLAY")
			self.Swing.Mainhand.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.Mainhand.Text:SetPoint("LEFT", self.Swing.Mainhand, 3, 0)
			self.Swing.Mainhand.Text:SetSize(260 * 0.7, 12)
			self.Swing.Mainhand.Text:SetJustifyH("LEFT")
		end

		self.Swing.Mainhand.Spark = self.Swing.Mainhand:CreateTexture(nil, "OVERLAY")
		self.Swing.Mainhand.Spark:SetTexture(C["Media"].Textures.Spark16Texture)
		self.Swing.Mainhand.Spark:SetHeight(self.Swing:GetHeight())
		self.Swing.Mainhand.Spark:SetBlendMode("ADD")
		self.Swing.Mainhand.Spark:SetPoint("CENTER", self.Swing.Mainhand:GetStatusBarTexture(), "RIGHT", 0, 0)

		self.Swing.Offhand = CreateFrame("Statusbar", nil, self.Swing)
		self.Swing.Offhand:SetPoint("BOTTOM", self.Swing.Mainhand, "TOP", 0, 6)
		self.Swing.Offhand:SetSize(swingWidth, 14)
		self.Swing.Offhand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Offhand:SetStatusBarColor(0.8, 0.3, 0.3)
		self.Swing.Offhand:SetFrameLevel(20)
		self.Swing.Offhand:SetFrameStrata("LOW")
		self.Swing.Offhand:Hide()
		self.Swing.Offhand:CreateBorder()

		if C["Unitframe"].SwingbarTimer then
			self.Swing.Offhand.Text = self.Swing.Offhand:CreateFontString(nil, "OVERLAY")
			self.Swing.Offhand.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.Offhand.Text:SetPoint("LEFT", self.Swing.Offhand, 3, 0)
			self.Swing.Offhand.Text:SetSize(260 * 0.7, 12)
			self.Swing.Offhand.Text:SetJustifyH("LEFT")
		end

		self.Swing.Offhand.Spark = self.Swing.Offhand:CreateTexture(nil, "OVERLAY")
		self.Swing.Offhand.Spark:SetTexture(C["Media"].Textures.Spark16Texture)
		self.Swing.Offhand.Spark:SetHeight(self.Swing:GetHeight())
		self.Swing.Offhand.Spark:SetBlendMode("ADD")
		self.Swing.Offhand.Spark:SetPoint("CENTER", self.Swing.Offhand:GetStatusBarTexture(), "RIGHT", 0, 0)

		self.Swing.hideOoc = true

		K.Mover(self.Swing, "PlayerSwingBar", "PlayerSwingBar", {"BOTTOM", UIParent, "BOTTOM", 0, 180})
	end

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
			self.PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT", -2, 0)
		else
			self.PvPIndicator:SetPoint("RIGHT", self.Health, "LEFT", -2, 0)
		end
		self.PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator
	end

	self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.CombatIndicator:SetSize(20, 20)
	self.CombatIndicator:SetPoint("LEFT", 2, 0)

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Health)
	end
	self.ReadyCheckIndicator:SetSize(C["Unitframe"].PlayerFrameHeight - 4, C["Unitframe"].PlayerFrameHeight - 4)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ResurrectIndicator:SetPoint("CENTER", self.Health)
	end

	self.RestingIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RestingIndicator:SetPoint("RIGHT", -2, 2)
	self.RestingIndicator:SetSize(22, 22)

	self.QuestSyncIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		self.QuestSyncIndicator:SetPoint("BOTTOM", self.Portrait, "BOTTOM", 0, -13)
	else
		self.QuestSyncIndicator:SetPoint("BOTTOM", self.Health, "BOTTOM", 0, -13)
	end
	self.QuestSyncIndicator:SetSize(26, 26)
	self.QuestSyncIndicator:SetAtlas("QuestSharing-DialogIcon")
	self.QuestSyncIndicator:Hide()

	self:RegisterEvent("QUEST_SESSION_LEFT", updatePartySync, true)
	self:RegisterEvent("QUEST_SESSION_JOINED", updatePartySync, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", updatePartySync, true)

	if C["Unitframe"].DebuffHighlight then
		self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
		self.DebuffHighlight:SetAllPoints(self.Health)
		self.DebuffHighlight:SetTexture(C["Media"].Textures.BlankTexture)
		self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		self.DebuffHighlight:SetBlendMode("ADD")

		self.DebuffHighlightAlpha = 0.45
		self.DebuffHighlightFilter = true
	end

	if C["Unitframe"].GlobalCooldown then
		self.GlobalCooldown = CreateFrame("Frame", nil, self.Health)
		self.GlobalCooldown:SetWidth(playerWidth)
		self.GlobalCooldown:SetHeight(28)
		self.GlobalCooldown:SetFrameStrata("HIGH")
		self.GlobalCooldown:SetPoint("LEFT", self.Health, "LEFT", 0, 0)
	end

	self.CombatFade = C["Unitframe"].CombatFade

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}
end