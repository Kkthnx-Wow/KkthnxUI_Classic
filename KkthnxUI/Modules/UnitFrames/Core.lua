local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Unitframes")
-- local AuraModule = K:GetModule("Auras")
local oUF = K.oUF

-- Lua functions
local pairs = pairs
local string_format = string.format
local unpack = unpack

-- WoW API
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT
local UIParent = UIParent
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitIsPVP = UnitIsPVP
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsPlayer = UnitIsPlayer
local UnitThreatSituation = UnitThreatSituation

-- Custom variables
local lastPvPSound = false
local phaseIconTexCoords = {
	[1] = { 1 / 128, 33 / 128, 1 / 64, 33 / 64 },
	[2] = { 34 / 128, 66 / 128, 1 / 64, 33 / 64 },
}
local filteredStyle = {
	["nameplate"] = true,
	["target"] = true,
}

function Module:UpdateClassPortraits(unit)
	if C["Unitframe"].PortraitStyle.Value == "NoPortraits" or not unit then
		return
	end

	local _, unitClass = UnitClass(unit)

	if unitClass then
		local PortraitValue = C["Unitframe"].PortraitStyle.Value
		local ClassTCoords = CLASS_ICON_TCOORDS[unitClass]

		local texturePath
		if PortraitValue == "ClassPortraits" and UnitIsPlayer(unit) then
			texturePath = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\OLD-ICONS-CLASSES"
		elseif PortraitValue == "NewClassPortraits" and UnitIsPlayer(unit) then
			texturePath = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\NEW-ICONS-CLASSES"
		end

		self:SetTexture(texturePath or "Interface\\TargetingFrame\\UI-Classes-Circles")
		if ClassTCoords then
			self:SetTexCoord(ClassTCoords[1], ClassTCoords[2], ClassTCoords[3], ClassTCoords[4])
		else
			self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		end
	end
end

function Module:PostUpdatePvPIndicator(unit, status)
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) and status == "ffa" then
		self:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self:SetTexCoord(0, 0.65625, 0, 0.65625)
	elseif factionGroup and UnitIsPVP(unit) and status ~= nil then
		self:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\pvpindicator")

		if factionGroup == "Alliance" then
			self:SetTexCoord(0.00390625, 0.136719, 0.511719, 0.671875)
		else
			self:SetTexCoord(0.00390625, 0.136719, 0.679688, 0.839844)
		end
	end
end

function Module:UpdateThreat(_, unit)
	if unit ~= self.unit then
		return
	end

	-- Get the current threat status of the unit
	local status = UnitThreatSituation(unit)

	-- Get the portrait style, health frame, and portrait frame
	local portraitStyle = C["Unitframe"].PortraitStyle.Value
	local health = self.Health
	local portrait = self.Portrait

	-- Determine the border object based on the portrait style
	local borderObject
	if portraitStyle == "ThreeDPortraits" then
		borderObject = portrait.KKUI_Border
	elseif portraitStyle ~= "NoPortraits" and portraitStyle ~= "OverlayPortrait" then
		borderObject = portrait.Border and portrait.Border.KKUI_Border
	else
		borderObject = health.KKUI_Border
	end

	-- Update the border color based on threat status
	if status and status > 1 then
		local r, g, b = GetThreatStatusColor(status)
		if borderObject then
			borderObject:SetVertexColor(r, g, b)
		end
	else
		K.SetBorderColor(borderObject)
	end
end

function Module:UpdatePhaseIcon(isPhased)
	self:SetTexCoord(unpack(phaseIconTexCoords[isPhased == 2 and 2 or 1]))
end

function Module:CreateHeader()
	-- Register for mouse clicks and hook mouse enter/leave events
	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", function()
		UnitFrame_OnEnter(self)
		if self.Highlight then
			self.Highlight:Show()
		end
	end)

	self:HookScript("OnLeave", function()
		UnitFrame_OnLeave(self)
		if self.Highlight then
			self.Highlight:Hide()
		end
	end)
end

function Module:ToggleCastBarLatency(frame)
	frame = frame or _G.oUF_Player
	if not frame then
		return
	end

	if C["Unitframe"].CastbarLatency then
		frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent, true)
	else
		frame:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent)
		if frame.Castbar then
			frame.Castbar.__sendTime = nil
		end
	end
end

-- Cache the result of auraIconSize calculation
local auraIconSizeCache = {}

function Module.auraIconSize(w, n, s)
	if not auraIconSizeCache[w] then
		auraIconSizeCache[w] = {}
	end

	if not auraIconSizeCache[w][n] then
		auraIconSizeCache[w][n] = (w - (n - 1) * s) / n
	end

	return auraIconSizeCache[w][n]
end

function Module:UpdateAuraContainer(width, element, maxAuras)
	local iconsPerRow = element.iconsPerRow
	local size = iconsPerRow and Module.auraIconSize(width, iconsPerRow, element.spacing) or element.size
	local maxLines = iconsPerRow and K.Round(maxAuras / iconsPerRow) or 2

	if element.size ~= size or element:GetWidth() ~= width or element:GetHeight() ~= ((size + element.spacing) * maxLines) then
		element.size = size
		element:SetWidth(width)
		element:SetHeight((size + element.spacing) * maxLines)
	end
end

function Module:UpdateIconTexCoord(width, height)
	local ratio = height / width
	local mult = (1 - ratio) / 2
	self.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3] + mult, K.TexCoords[4] - mult)
end

function Module.PostCreateIcon(element, button)
	local fontSize = element.fontSize or element.size * 0.52
	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints(button)
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)

	button.count = button.count or K.CreateFontString(parentFrame, fontSize - 1, "", "OUTLINE", false, "BOTTOMRIGHT", 6, -3)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse(true)
	button.cd:SetHideCountdownNumbers(true)

	button.icon:SetAllPoints()
	button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	button.cd:ClearAllPoints()
	if element.__owner.mystyle == "nameplate" then
		button.cd:SetAllPoints()
		button:CreateShadow(true)
		button.stealable:SetAtlas("communities-create-avatar-border-selected")
	else
		button.cd:SetPoint("TOPLEFT", 1, -1)
		button.cd:SetPoint("BOTTOMRIGHT", -1, 1)
		button:CreateBorder()
		button.stealable:SetAtlas("Forge-ColorSwatchSelection")
	end

	button.overlay:SetTexture(nil)
	button.stealable:SetParent(parentFrame)

	if not button.timer then
		button.timer = K.CreateFontString(parentFrame, fontSize, "", "OUTLINE")
	end

	hooksecurefunc(button, "SetSize", Module.UpdateIconTexCoord)
end

local dispellType = {
	["Magic"] = true,
	[""] = true,
}

-- Function to update the stealable indicator
local function UpdateStealableIndicator(button, unit, debuffType)
	-- Show stealable indicator if applicable
	if dispellType[debuffType] and not UnitIsPlayer(unit) and not button.isDebuff then
		button.stealable:Show()
	else
		button.stealable:Hide()
	end
end

function Module.PostUpdateIcon(element, unit, button, _, _, duration, expiration, debuffType)
	local style = element.__owner.mystyle
	local size = element.size

	-- Set button size based on style
	button:SetSize(size, style == "nameplate" and size or size)

	-- Update appearance based on harmful status and style
	if button.isDebuff and filteredStyle and filteredStyle[style] and not button.isPlayer then
		button.icon:SetDesaturated(true)
	else
		button.icon:SetDesaturated(false)
	end

	-- Update border color based on debuff type
	if button.isDebuff then
		local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
		if style == "nameplate" then
			button.Shadow:SetBackdropBorderColor(color[1], color[2], color[3], 0.8)
		else
			button.KKUI_Border:SetVertexColor(color[1], color[2], color[3])
		end
	else
		if style == "nameplate" then
			button.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
		else
			K.SetBorderColor(button.KKUI_Border)
		end
	end

	-- Update the stealable indicator
	UpdateStealableIndicator(button, unit, debuffType)

	-- Handle cooldown and timer display
	if duration and duration > 0 then
		button.expiration = expiration
		button:SetScript("OnUpdate", K.CooldownOnUpdate)
		button.timer:Show()
	else
		button:SetScript("OnUpdate", nil)
		button.timer:Hide()
	end
end

function Module.AurasPostUpdateInfo(element, _, _, debuffsChanged)
	-- Update Dot status if debuffs changed
	if debuffsChanged then
		element.hasTheDot = nil
		-- Check if any player debuff matches Dot spell list
		if C["Nameplate"].ColorByDot then
			for _, data in next, element.allDebuffs do
				if data.isPlayerAura and C["Nameplate"].DotSpellList.Spells[data.spellId] then
					element.hasTheDot = true
					break
				end
			end
		end
	end
end

function Module.CustomFilter(element, unit, button, name, _, _, debuffType, _, _, caster, isStealable, _, spellID, _, _, _, nameplateShowAll)
	local style = element.__owner.mystyle
	local showDebuffType = C["Unitframe"].OnlyShowPlayerDebuff

	if style == "nameplate" then
		-- Nameplate specific filtering
		if element.__owner.plateType == "NameOnly" then
			return C.NameplateWhiteList[spellID]
		elseif C.NameplateBlackList[spellID] then
			return false
		elseif (isStealable or (element.alwaysShowStealable and dispellType[debuffType])) and not UnitIsPlayer(unit) and not button.isDebuff then
			return true
		elseif C.NameplateWhiteList[spellID] then
			return true
		else
			local auraFilter = C["Nameplate"].AuraFilter.Value
			return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and button.isPlayer)
		end
	else
		-- General unit frame filtering
		return (showDebuffType and button.isPlayer) or (not showDebuffType and name)
	end
end

function Module.PostUpdateClassPower(element, cur, max, diff, powerType)
	if diff then
		for i = 1, max do
			element[i]:SetWidth((element.__owner.ClassPowerBar:GetWidth() - (max - 1) * 6) / max)
		end
	end

	element.thisColor = cur == max and 1 or 2
	if not element.prevColor or element.prevColor ~= element.thisColor then
		local r, g, b = 1, 0, 0
		if element.thisColor == 2 then
			local color = element.__owner.colors.power[powerType]
			r, g, b = color[1], color[2], color[3]
		end
		for i = 1, #element do
			element[i]:SetStatusBarColor(r, g, b)
		end
		element.prevColor = element.thisColor
	end
end

function Module:CreateClassPower(self)
	local barWidth, barHeight, barPoint
	if self.mystyle == "PlayerPlate" then
		barWidth, barHeight = C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight
		barPoint = { "BOTTOMLEFT", self, "TOPLEFT", 0, 6 }
	elseif self.mystyle == "targetplate" then
		barWidth, barHeight = C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight - 2
		barPoint = { "CENTER", self }
	else
		barWidth, barHeight = C["Unitframe"].PlayerHealthWidth, 14
		barPoint = { "BOTTOMLEFT", self, "TOPLEFT", 0, 6 }
	end

	local maxBar = 6
	local bars, bar = {}, CreateFrame("Frame", "$parentClassPowerBar", self)

	bar:SetSize(barWidth, barHeight)
	bar:SetPoint(unpack(barPoint))

	for i = 1, maxBar do
		local statusbar = CreateFrame("StatusBar", nil, bar)
		statusbar:SetHeight(barHeight)
		statusbar:SetWidth((barWidth - (maxBar - 1) * 6) / maxBar)
		statusbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		statusbar:SetFrameLevel(self:GetFrameLevel() + 5)
		if self.mystyle == "PlayerPlate" or self.mystyle == "targetplate" then
			statusbar:CreateShadow(true)
		else
			statusbar:CreateBorder()
		end

		if i == 1 then
			statusbar:SetPoint("BOTTOMLEFT")
		else
			statusbar:SetPoint("LEFT", bars[i - 1], "RIGHT", 6, 0)
		end

		bars[i] = statusbar
	end

	bars.PostUpdate = Module.PostUpdateClassPower
	self.ClassPower = bars
	self.ClassPowerBar = bar
end

function Module:CreateEneryTicker(self)
	if K.Class == "WARRIOR" then
		return
	end

	local ticker = CreateFrame("StatusBar", nil, self.Power)
	ticker:SetFrameLevel(self.Power:GetFrameLevel() + 3)
	ticker:SetAllPoints()
	ticker.Spark = ticker:CreateTexture(nil, "OVERLAY")

	self.EnergyManaRegen = ticker
end

function Module:ToggleEnergyTicker(enable)
	if not self.EnergyManaRegen then
		return
	end
	if enable then
		if not self:IsElementEnabled("EnergyManaRegen") then
			self:EnableElement("EnergyManaRegen")
		end
	else
		if self:IsElementEnabled("EnergyManaRegen") then
			self:DisableElement("EnergyManaRegen")
		end
	end
end

local textScaleFrames = {
	["player"] = true,
	["target"] = true,
	["pet"] = true,
	["targetoftarget"] = true,
}

function Module:UpdateTextScale()
	local scale = C["Unitframe"].AllTextScale
	for _, frame in pairs(oUF.objects) do
		local style = frame.mystyle
		if style and textScaleFrames[style] then
			if frame.Name then
				frame.Name:SetScale(scale)
			end

			if frame.Level then
				frame.Level:SetScale(scale)
			end

			frame.Health.Value:SetScale(scale)

			if frame.Power.Value then
				frame.Power.Value:SetScale(scale)
			end

			local castbar = frame.Castbar
			if castbar then
				castbar.Text:SetScale(scale)
				castbar.Time:SetScale(scale)
				if castbar.Lag then
					castbar.Lag:SetScale(scale)
				end
			end
		end
	end
end

function Module:CreateUnits()
	local showPartyFrame = C["Party"].Enable

	if C["Nameplate"].Enable then
		Module:SetupCVars()
		Module:BlockAddons()
		Module:CreateUnitTable()
		Module:CreatePowerUnitTable()
		Module:QuestIconCheck()
		Module:RefreshPlateOnFactionChanged()

		oUF:RegisterStyle("Nameplates", Module.CreatePlates)
		oUF:SetActiveStyle("Nameplates")
		oUF:SpawnNamePlates("oUF_NPs", Module.PostUpdatePlates)
	end

	-- Playerplate-like PlayerFrame
	do
		oUF:RegisterStyle("PlayerPlate", Module.CreatePlayerPlate)
		oUF:SetActiveStyle("PlayerPlate")
		local plate = oUF:Spawn("player", "oUF_PlayerPlate", true)
		plate.mover = K.Mover(plate, "PlayerPlate", "PlayerPlate", { "BOTTOM", UIParent, "BOTTOM", 0, 300 })
		Module:TogglePlayerPlate()
	end

	-- Fake nameplate for target class power
	do
		oUF:RegisterStyle("TargetPlate", Module.CreateTargetPlate)
		oUF:SetActiveStyle("TargetPlate")
		oUF:Spawn("player", "oUF_TargetPlate", true)
		Module:ToggleTargetClassPower()
	end

	if C["Unitframe"].Enable then
		oUF:RegisterStyle("Player", Module.CreatePlayer)
		oUF:RegisterStyle("Target", Module.CreateTarget)
		oUF:RegisterStyle("ToT", Module.CreateTargetOfTarget)
		oUF:RegisterStyle("Pet", Module.CreatePet)

		-- Spawn Player Frame
		oUF:SetActiveStyle("Player")
		local Player = oUF:Spawn("player", "oUF_Player")
		Player:SetSize(C["Unitframe"].PlayerHealthWidth, C["Unitframe"].PlayerHealthHeight + C["Unitframe"].PlayerPowerHeight + 6)
		K.Mover(Player, "PlayerUF", "PlayerUF", { "BOTTOM", UIParent, "BOTTOM", -260, 320 }, Player:GetWidth(), Player:GetHeight())

		-- Spawn Target Frame
		oUF:SetActiveStyle("Target")
		local Target = oUF:Spawn("target", "oUF_Target")
		Target:SetSize(C["Unitframe"].TargetHealthWidth, C["Unitframe"].TargetHealthHeight + C["Unitframe"].TargetPowerHeight + 6)
		K.Mover(Target, "TargetUF", "TargetUF", { "BOTTOM", UIParent, "BOTTOM", 260, 320 }, Target:GetWidth(), Target:GetHeight())

		-- Spawn Target of Target Frame
		if not C["Unitframe"].HideTargetofTarget then
			oUF:SetActiveStyle("ToT")
			local TargetOfTarget = oUF:Spawn("targettarget", "oUF_ToT")
			TargetOfTarget:SetSize(C["Unitframe"].TargetTargetHealthWidth, C["Unitframe"].TargetTargetHealthHeight + C["Unitframe"].TargetTargetPowerHeight + 6)
			K.Mover(TargetOfTarget, "TotUF", "TotUF", { "TOPLEFT", Target, "BOTTOMRIGHT", 6, -6 }, TargetOfTarget:GetWidth(), TargetOfTarget:GetHeight())
		end

		-- Spawn Pet Frame
		oUF:SetActiveStyle("Pet")
		local Pet = oUF:Spawn("pet", "oUF_Pet")
		Pet:SetSize(C["Unitframe"].PetHealthWidth, C["Unitframe"].PetHealthHeight + C["Unitframe"].PetPowerHeight + 6)
		K.Mover(Pet, "Pet", "Pet", { "TOPRIGHT", Player, "BOTTOMLEFT", -6, -6 }, Pet:GetWidth(), Pet:GetHeight())

		K:RegisterEvent("PLAYER_TARGET_CHANGED", Module.PLAYER_TARGET_CHANGED)
		K:RegisterEvent("UNIT_FACTION", Module.UNIT_FACTION)

		Module:UpdateTextScale()
	end

	-- Function to create party frames
	local function CreatePartyFrames()
		oUF:RegisterStyle("Party", Module.CreateParty)
		oUF:SetActiveStyle("Party")

		local partyXOffset, partyYOffset = 6, C["Party"].ShowBuffs and 56 or 36
		local partyMoverWidth = C["Party"].HealthWidth
		local partyMoverHeight = C["Party"].HealthHeight + C["Party"].PowerHeight + 1 + partyYOffset * 8
		local partyGroupingOrder = "NONE,DAMAGER,HEALER,TANK"
		-- stylua: ignore start
        local party = oUF:SpawnHeader("oUF_Party", nil, "solo,party",
            "showPlayer", C["Party"].ShowPlayer,
            "showSolo", C["Party"].ShowPartySolo,
            "showParty", true,
            "showRaid", false,
            "xoffset", partyXOffset,
            "yOffset", partyYOffset,
            "groupFilter", "1",
            "groupingOrder", partyGroupingOrder,
            "groupBy", "ASSIGNEDROLE",
            "sortMethod", "NAME",
            "point", "BOTTOM",
            "columnAnchorPoint", "LEFT",
            "oUF-initialConfigFunction", ([[
                self:SetWidth(%d)
                self:SetHeight(%d)
            ]]):format(C["Party"].HealthWidth, C["Party"].HealthHeight + C["Party"].PowerHeight + 6)
        )
		-- stylua: ignore end
		local partyMover = K.Mover(party, "PartyFrame", "PartyFrame", { "TOPLEFT", UIParent, "TOPLEFT", 50, -300 }, partyMoverWidth, partyMoverHeight)
		party:ClearAllPoints()
		party:SetPoint("TOPLEFT", partyMover)

		if C["Party"].ShowPet then
			oUF:RegisterStyle("PartyPet", Module.CreatePartyPet)
			oUF:SetActiveStyle("PartyPet")

			local partypetXOffset, partypetYOffset = 6, 25
			local partpetMoverWidth = 60
			local partpetMoverHeight = 34 * 5 + partypetYOffset * 4
			-- stylua: ignore start
            local partyPet = oUF:SpawnHeader("oUF_PartyPet", nil, "solo,party",
                "showPlayer", true,
                "showSolo", false,
                "showParty", true,
                "showRaid", false,
                "xoffset", partypetXOffset,
                "yOffset", partypetYOffset,
                "point", "BOTTOM",
                "columnAnchorPoint", "LEFT",
                "oUF-initialConfigFunction", ([[
                    self:SetWidth(%d)
                    self:SetHeight(%d)
                    self:SetAttribute("unitsuffix", "pet")
                ]]):format(60, 34)
            )
			-- stylua: ignore end
			local moverAnchor = { "TOPLEFT", partyMover, "TOPRIGHT", 6, -40 }
			local petMover = K.Mover(partyPet, "PartyPetFrame", "PartyPetFrame", moverAnchor, partpetMoverWidth, partpetMoverHeight)
			partyPet:ClearAllPoints()
			partyPet:SetPoint("TOPLEFT", petMover)
		end
	end

	if showPartyFrame then
		CreatePartyFrames()
	end

	-- Function to create raid frames
	local function CreateRaidFrames()
		SetCVar("predictedHealth", 1)
		oUF:RegisterStyle("Raid", Module.CreateRaid)
		oUF:SetActiveStyle("Raid")

		-- Hide Default RaidFrame
		if CompactPartyFrame then
			CompactPartyFrame:UnregisterAllEvents()
		end

		if _G.CompactRaidFrameManager_SetSetting then
			_G.CompactRaidFrameManager_SetSetting("IsShown", "0")
			UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
			_G.CompactRaidFrameManager:UnregisterAllEvents()
			_G.CompactRaidFrameManager:SetParent(K.UIFrameHider)
		end

		local raidWidth = C["Raid"].Width
		local raidHeight = C["Raid"].Height
		local horizonRaid = C["Raid"].HorizonRaid
		local reverse = C["Raid"].Reverse
		local showTeamIndex = C["Raid"].ShowTeamIndex
		local numGroups = C["Raid"].NumGroups

        -- stylua: ignore start
        local function CreateGroup(name, i)
            local group = oUF:SpawnHeader(name, nil, "solo,party,raid",
                "showPlayer", true,
                "showSolo", not showPartyFrame and C["Raid"].ShowRaidSolo,
                "showParty", not showPartyFrame,
                "showRaid", true,
                "xOffset", 6,
                "yOffset", -6,
                "groupFilter", tostring(i),
                "groupingOrder", "1,2,3,4,5,6,7,8",
                "groupBy", "GROUP",
                "sortMethod", "INDEX",
                "maxColumns", 1,
                "unitsPerColumn", 5,
                "columnSpacing", 5,
                "point", horizonRaid and "LEFT" or "TOP",
                "columnAnchorPoint", "LEFT",
                "oUF-initialConfigFunction", ([[
                    self:SetWidth(%d)
                    self:SetHeight(%d)
                ]]):format(raidWidth, raidHeight)
            )
			-- stylua: ignore end
            return group
        end

        -- Function to create team index
        local function CreateTeamIndex(header)
            local parent = _G[header:GetName() .. "UnitButton1"]
            if parent and not parent.teamIndex then
                local teamIndex = K.CreateFontString(parent, 11, string_format(_G.GROUP_NUMBER, header.index), "")
                teamIndex:ClearAllPoints()
                teamIndex:SetPoint("BOTTOM", parent, "TOP", 0, 3)
                teamIndex:SetTextColor(255 / 255, 204 / 255, 102 / 255)

                parent.teamIndex = teamIndex
            end
        end

        local groups = {}
        for i = 1, numGroups do
            groups[i] = CreateGroup("oUF_Raid" .. i, i)
            groups[i].index = i

            local raidMover
			if i == 1 then
			    if horizonRaid then
			        raidMover = K.Mover(groups[i], "RaidFrame", "RaidFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -180 }, (raidWidth + 5) * 5, (raidHeight + (showTeamIndex and 15 or 5)) * numGroups)
			        if reverse then
			            groups[i]:ClearAllPoints()
			            groups[i]:SetPoint("BOTTOMLEFT", raidMover)
			        end
			    else
			        raidMover = K.Mover(groups[i], "RaidFrame", "RaidFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -180 }, (raidWidth + 5) * numGroups, (raidHeight + 5) * 5)
			        if reverse then
			            groups[i]:ClearAllPoints()
			            groups[i]:SetPoint("TOPRIGHT", raidMover)
			        end
			    end
			else
                if horizonRaid then
                    if reverse then
                        groups[i]:SetPoint("BOTTOMLEFT", groups[i - 1], "TOPLEFT", 0, showTeamIndex and 18 or 6)
                    else
                        groups[i]:SetPoint("TOPLEFT", groups[i - 1], "BOTTOMLEFT", 0, showTeamIndex and -18 or -6)
                    end
                else
                    if reverse then
                        groups[i]:SetPoint("TOPRIGHT", groups[i - 1], "TOPLEFT", -6, 0)
                    else
                        groups[i]:SetPoint("TOPLEFT", groups[i - 1], "TOPRIGHT", 6, 0)
                    end
                end
            end

            if showTeamIndex then
                CreateTeamIndex(groups[i])
                groups[i]:HookScript("OnShow", CreateTeamIndex)
            end
        end

        if C["Raid"].MainTankFrames then
            oUF:RegisterStyle("MainTank", Module.CreateRaid)
            oUF:SetActiveStyle("MainTank")

            local horizonTankRaid = C["Raid"].HorizonRaid
            local raidTankWidth, raidTankHeight = C["Raid"].Width, C["Raid"].Height

			-- stylua: ignore start
            local raidtank = oUF:SpawnHeader(
                "oUF_MainTank", nil, "raid",
                "showRaid", true,
                "xoffset", 6,
                "yOffset", -6,
                "groupFilter", "MAINTANK",
                "point", horizonTankRaid and "LEFT" or "TOP",
                "columnAnchorPoint", "LEFT",
                "template", C["Raid"].MainTankFrames and "oUF_MainTankTT" or "oUF_MainTank",
                "oUF-initialConfigFunction", ([[
                    self:SetWidth(%d)
                    self:SetHeight(%d)
                ]]):format(raidTankWidth, raidTankHeight)
            )
			-- stylua: ignore end

            local raidtankMover = K.Mover(raidtank, "MainTankFrame", "MainTankFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -50 }, raidTankWidth, raidTankHeight)
            raidtank:ClearAllPoints()
            raidtank:SetPoint("TOPLEFT", raidtankMover)
        end
	end

	if C["Raid"].Enable then
		CreateRaidFrames()
	end
end

function Module:UpdateRaidDebuffIndicator()
	local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs

	if ORD then
		local _, InstanceType = IsInInstance()

		ORD:ResetDebuffData()

		if InstanceType == "party" or InstanceType == "raid" then
			if C["Raid"].DebuffWatchDefault then
				ORD:RegisterDebuffs(C["DebuffsTracking_PvE"].spells)
			end

			ORD:RegisterDebuffs(KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvE)
		else
			if C["Raid"].DebuffWatchDefault then
				ORD:RegisterDebuffs(C["DebuffsTracking_PvP"].spells)
			end

			ORD:RegisterDebuffs(KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvP)
		end
	end
end

-- Function that plays a sound when the target or focus changes
local function CreateTargetSound(_, unit)
	-- Check if the unit exists
	if UnitExists(unit) then
		local soundKit
		-- Determine the sound kit based on the unit's relation to the player
		if UnitIsEnemy("player", unit) then
			soundKit = SOUNDKIT.IG_CREATURE_AGGRO_SELECT
		elseif UnitIsFriend("player", unit) then
			soundKit = SOUNDKIT.IG_CHARACTER_NPC_SELECT
		else
			soundKit = SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT
		end
		PlaySound(soundKit)
	else
		PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

-- Function that plays a sound when the player changes their target
function Module:PLAYER_TARGET_CHANGED()
	CreateTargetSound(nil, "target")
end

-- Function that plays a sound when the player's faction changes
function Module:UNIT_FACTION(unit)
	if unit ~= "player" then
		return
	end

	-- Check if player is in a PvP zone
	local isPvP = UnitIsPVPFreeForAll("player") or UnitIsPVP("player")

	-- Play sound if player enters a PvP zone and it has not been played yet
	if isPvP and not lastPvPSound then
		PlaySound(SOUNDKIT.IG_PVP_UPDATE)
	end

	-- Update lastPvPSound variable
	lastPvPSound = isPvP
end

function Module:OnEnable()
	-- Register our units / layout
	self:CreateUnits()

	if C["Raid"].DebuffWatch then
		local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs
		local RaidDebuffs = CreateFrame("Frame")

		RaidDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
		RaidDebuffs:SetScript("OnEvent", Module.UpdateRaidDebuffIndicator)

		if ORD then
			ORD.ShowDispellableDebuff = true
			ORD.FilterDispellableDebuff = true
			ORD.MatchBySpellName = false
		end

		self:CreateTracking()
	end
end
