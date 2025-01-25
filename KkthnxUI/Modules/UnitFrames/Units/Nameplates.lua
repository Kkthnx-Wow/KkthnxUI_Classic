local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- Lua functions
local math_rad = math.rad
local pairs = pairs
local string_format = string.format
local table_wipe = table.wipe
local tonumber = tonumber
local unpack = unpack

-- WoW API
local Ambiguate = Ambiguate
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local C_NamePlate_SetNamePlateEnemySize = C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_SetNamePlateFriendlySize = C_NamePlate.SetNamePlateFriendlySize
local C_NamePlate_SetNamePlateEnemyClickThrough = C_NamePlate.SetNamePlateEnemyClickThrough
local C_NamePlate_SetNamePlateFriendlyClickThrough = C_NamePlate.SetNamePlateFriendlyClickThrough
local CreateFrame = CreateFrame
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local INTERRUPTED = INTERRUPTED
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local SetCVar = SetCVar
local UnitClassification = UnitClassification
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
-- local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local UnitPlayerControlled = UnitPlayerControlled
local UnitReaction = UnitReaction
local UnitThreatSituation = UnitThreatSituation
local hooksecurefunc = hooksecurefunc

-- Custom data
local mdtCacheData = {} -- Cache for data of abilities used by players
local customUnits = {} -- Custom unit data
local groupRoles = {} -- Group roles for players
local showPowerList = {} -- List of players who have their power displayed
local isInGroup = false -- Boolean to track if the player is in a group
local isInInstance = false -- Boolean to track if the player is in an instance

-- Unit classification
local NPClassifies = {
	elite = { 1, 1, 1 },
	rare = { 1, 1, 1, true },
	rareelite = { 1, 0.1, 0.1 },
	worldboss = { 0, 1, 0 },
}

-- Specific NPCs to show
local ShowTargetNPCs = {
	-- [165251] = true,	-- 仙林狐狸
	[40357] = true, -- 格瑞姆巴托火元素
	[164702] = true, -- 食腐蛆虫
	[174773] = true, -- 怨毒怪
}

-- Init
function Module:UpdatePlateCVars()
	if InCombatLockdown() then
		return
	end

	if C["Nameplate"].InsideView then
		SetCVar("nameplateOtherTopInset", 0.05)
		SetCVar("nameplateOtherBottomInset", 0.08)
	elseif GetCVar("nameplateOtherTopInset") == "0.05" and GetCVar("nameplateOtherBottomInset") == "0.08" then
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end

	local settings = {
		nameplateMaxDistance = 20,
		namePlateMinScale = C["Nameplate"].MinScale,
		namePlateMaxScale = C["Nameplate"].MinScale,
		nameplateMinAlpha = C["Nameplate"].MinAlpha,
		nameplateMaxAlpha = C["Nameplate"].MinAlpha,
		nameplateOverlapV = C["Nameplate"].VerticalSpacing,
		nameplateShowOnlyNames = C["Nameplate"].CVarOnlyNames and 1 or 0,
		nameplateShowFriendlyNPCs = C["Nameplate"].CVarShowNPCs and 1 or 0,
	}

	for cvar, value in pairs(settings) do
		SetCVar(cvar, value)
	end
end

function Module:UpdateClickableSize()
	if InCombatLockdown() then
		return
	end

	local uiScale = C["General"].UIScale
	local harmWidth, harmHeight = C["Nameplate"].HarmWidth, C["Nameplate"].HarmHeight
	local helpWidth, helpHeight = C["Nameplate"].HelpWidth, C["Nameplate"].HelpHeight

	C_NamePlate_SetNamePlateEnemySize(harmWidth * uiScale, harmHeight * uiScale)
	C_NamePlate_SetNamePlateFriendlySize(helpWidth * uiScale, helpHeight * uiScale)
end

function Module:UpdatePlateClickThru()
	if InCombatLockdown() then
		return
	end

	C_NamePlate_SetNamePlateEnemyClickThrough(C["Nameplate"].EnemyThru)
	C_NamePlate_SetNamePlateFriendlyClickThrough(C["Nameplate"].FriendlyThru)
end

function Module:SetupCVars()
	Module:UpdatePlateCVars()
	local settings = {
		nameplateOverlapH = 0.8, -- Controls the horizontal overlap of nameplates. A lower value means nameplates will be more spaced out horizontally.
		nameplateSelectedAlpha = 1, -- Sets the transparency level for the selected nameplate (the one currently targeted). A value of 1 means fully opaque.
		showQuestTrackingTooltips = 1, -- Enables (1) or disables (0) the display of quest-related information in tooltips.
		nameplateSelectedScale = C["Nameplate"].SelectedScale, -- Determines the scale of the selected nameplate. A value greater than 1 enlarges the nameplate.
		nameplateLargerScale = 1.1, -- Adjusts the scale of larger nameplates, such as for bosses or important enemies. Default is 1 (normal size).
		nameplateGlobalScale = 1, -- Sets the overall scale for all nameplates. Default is 1 (normal size).
		NamePlateHorizontalScale = 1,
		NamePlateVerticalScale = 1,
		NamePlateClassificationScale = 1,
		nameplateShowSelf = 0, -- Toggles the visibility of the player's own nameplate. 0 means the player's nameplate will not be shown.
		nameplateResourceOnTarget = 0, -- Controls whether class resources (e.g., combo points, runes) are displayed on the target's nameplate. 0 means resources are shown below the character, not on the target.
		nameplatePlayerMaxDistance = 60, -- Sets the maximum distance at which player nameplates are visible. The default value is 60 yards.
	}

	for cvar, value in pairs(settings) do
		SetCVar(cvar, value)
	end

	Module:UpdateClickableSize()
	hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", Module.UpdateClickableSize)
	Module:UpdatePlateClickThru()
end

function Module:BlockAddons()
	if not _G.DBM or not _G.DBM.Nameplate then
		return
	end

	if DBM.Options then
		DBM.Options.DontShowNameplateIcons = true
		DBM.Options.DontShowNameplateIconsCD = true
		DBM.Options.DontShowNameplateIconsCast = true
	end

	local function showAurasForDBM(_, _, _, spellID)
		if not tonumber(spellID) then
			return
		end

		if not C.NameplateWhiteList[spellID] then
			C.NameplateWhiteList[spellID] = true
		end
	end
	hooksecurefunc(_G.DBM.Nameplate, "Show", showAurasForDBM)
end

function Module:CreateUnitTable()
	table_wipe(customUnits)
	if not C["Nameplate"].CustomUnitColor then
		return
	end

	K.CopyTable(C.NameplateCustomUnits, customUnits)
	K.SplitList(customUnits, C["Nameplate"].CustomUnitList)
end

function Module:CreatePowerUnitTable()
	table_wipe(showPowerList)
	K.CopyTable(C.NameplateShowPowerList, showPowerList)
	K.SplitList(showPowerList, C["Nameplate"].PowerUnitList)
end

function Module:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	local shouldShowPower = showPowerList[unitName] or showPowerList[npcID]
	if shouldShowPower then
		self.powerText:Show()
	else
		self.powerText:Hide()
	end
end

-- Off-tank threat color
-- Function to refresh the group roles
local function refreshGroupRoles()
	-- Check if player is in raid or group
	local isInRaid = IsInRaid()
	isInGroup = isInRaid or IsInGroup()

	-- Wipe the groupRoles table
	table_wipe(groupRoles)

	-- If player is in group
	if isInGroup then
		-- Get the number of players in group
		local numPlayers = (isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers()

		-- Define the unit prefix (raid or party)
		local unit = (isInRaid and "raid") or "party"

		-- Loop through each player in the group
		for i = 1, numPlayers do
			-- Define the unit index (e.g. raid1, party2)
			local index = unit .. i

			-- If the unit exists, add their name and role to the groupRoles table
			if UnitExists(index) then
				groupRoles[UnitName(index)] = UnitGroupRolesAssigned(index)
			end
		end
	end
end

local function resetGroupRoles()
	isInGroup = IsInRaid() or IsInGroup()
	table_wipe(groupRoles)
end

function Module:UpdateGroupRoles()
	refreshGroupRoles()
	K:RegisterEvent("GROUP_ROSTER_UPDATE", refreshGroupRoles)
	K:RegisterEvent("GROUP_LEFT", resetGroupRoles)
end

-- Update unit color
function Module:UpdateColor(_, unit)
	if not unit or self.unit ~= unit then
		return
	end

	local element = self.Health
	local name = self.unitName
	local npcID = self.npcID
	local isCustomUnit = customUnits[name] or customUnits[npcID]
	local isPlayer = self.isPlayer
	local isFriendly = self.isFriendly
	local status = UnitThreatSituation("player", unit) or false -- just in case

	local customColor = C["Nameplate"].CustomColor
	local targetColor = C["Nameplate"].TargetColor
	local insecureColor = C["Nameplate"].InsecureColor
	-- local revertThreat = C["Nameplate"].DPSRevertThreat
	local secureColor = C["Nameplate"].SecureColor
	local transColor = C["Nameplate"].TransColor
	local dotColor = C["Nameplate"].DotColor

	local executeRatio = C["Nameplate"].ExecuteRatio
	local healthPerc = UnitHealth(unit) / (UnitHealthMax(unit) + 0.0001) * 100

	local r, g, b
	if not UnitIsConnected(unit) then
		r, g, b = 0.7, 0.7, 0.7
	else
		if C["Nameplate"].ColoredTarget and UnitIsUnit(unit, "target") then
			r, g, b = targetColor[1], targetColor[2], targetColor[3]
		elseif isCustomUnit then
			r, g, b = customColor[1], customColor[2], customColor[3]
		elseif self.Auras.hasTheDot then
			r, g, b = dotColor[1], dotColor[2], dotColor[3]
		elseif isPlayer and isFriendly then
			if C["Nameplate"].FriendlyCC then
				r, g, b = K.UnitColor(unit)
			else
				r, g, b = K.Colors.power["MANA"][1], K.Colors.power["MANA"][2], K.Colors.power["MANA"][3]
			end
		elseif isPlayer and not isFriendly and C["Nameplate"].HostileCC then
			r, g, b = K.UnitColor(unit)
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
			r, g, b = 0.6, 0.6, 0.6
		else
			--r, g, b = UnitSelectionColor(unit, true)
			r, g, b = K.UnitColor(unit)

			if status then
				if status == 3 and C["Nameplate"].TankMode then
					r, g, b = secureColor[1], secureColor[2], secureColor[3]
				elseif status == 2 or status == 1 then
					r, g, b = transColor[1], transColor[2], transColor[3]
				elseif status == 0 then
					r, g, b = insecureColor[1], insecureColor[2], insecureColor[3]
				end
			end
		end
	end

	if r or g or b then
		element:SetStatusBarColor(r, g, b)
	end

	self.ThreatIndicator:Hide()
	if isCustomUnit or not C["Nameplate"].TankMode then
		if status == 3 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 0, 0)
			self.ThreatIndicator:Show()
		elseif status == 2 or status == 1 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 1, 0)
			self.ThreatIndicator:Show()
		end
	end

	if executeRatio > 0 and healthPerc <= executeRatio then
		self.nameText:SetTextColor(1, 0, 0)
	else
		self.nameText:SetTextColor(1, 1, 1)
	end
end

function Module:UpdateThreatColor(_, unit)
	if unit ~= self.unit then
		return
	end

	Module.UpdateColor(self, _, unit)
end

-- Backdrop shadow
function Module:CreateThreatColor(self)
	local threatIndicator = self:CreateShadow()
	threatIndicator:SetPoint("TOPLEFT", self.Health.backdrop, "TOPLEFT", -1, 1)
	threatIndicator:SetPoint("BOTTOMRIGHT", self.Health.backdrop, "BOTTOMRIGHT", 1, -1)
	threatIndicator:Hide()

	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = Module.UpdateThreatColor
end

-- Target indicator
function Module:UpdateTargetChange()
	local element = self.TargetIndicator
	local unit = self.unit

	if C["Nameplate"].TargetIndicator.Value ~= 1 then
		local isTarget = UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player")
		element:SetShown(isTarget)

		local shouldPlayAnim = isTarget and not element.TopArrowAnim:IsPlaying()
		local shouldStopAnim = not isTarget and element.TopArrowAnim:IsPlaying()

		if shouldPlayAnim then
			element.TopArrowAnim:Play()
		elseif shouldStopAnim then
			element.TopArrowAnim:Stop()
		end
	end

	if C["Nameplate"].ColoredTarget then
		Module.UpdateThreatColor(self, _, unit)
	end
end

function Module:UpdateTargetIndicator()
	local style = C["Nameplate"].TargetIndicator.Value
	local element = self.TargetIndicator
	local isNameOnly = self.plateType == "NameOnly"

	if style == 1 then
		element:Hide()
		return
	end

	local showTopArrow = style == 2 or style == 5
	local showRightArrow = style == 3 or style == 6
	local showGlow = (style == 4 or style == 5 or style == 6) and not isNameOnly
	local showNameGlow = (style == 4 or style == 5 or style == 6) and isNameOnly

	element.TopArrow:SetShown(showTopArrow)
	element.RightArrow:SetShown(showRightArrow)
	element.Glow:SetShown(showGlow)
	element.nameGlow:SetShown(showNameGlow)
	element:Show()
end

local points = { -15, -5, 0, 5, 0 }

function Module:AddTargetIndicator(self)
	local TargetIndicator = CreateFrame("Frame", nil, self)
	TargetIndicator:SetAllPoints()
	TargetIndicator:SetFrameLevel(0)
	TargetIndicator:Hide()

	-- Function to create and configure arrows
	local function CreateArrow(parent, point, x, y, rotation)
		local arrow = parent:CreateTexture(nil, "BACKGROUND", nil, -5)
		arrow:SetSize(64, 64) -- 128 / 2 simplified
		arrow:SetTexture(C["Nameplate"].TargetIndicatorTexture.Value)
		arrow:SetPoint(point, parent, point, x, y)
		if rotation then
			arrow:SetRotation(rotation)
		end
		return arrow
	end

	-- Top arrow
	TargetIndicator.TopArrow = CreateArrow(TargetIndicator, "BOTTOM", 0, 40)
	local animGroup = TargetIndicator.TopArrow:CreateAnimationGroup()
	animGroup:SetLooping("REPEAT")
	local anim = animGroup:CreateAnimation("Path")
	anim:SetDuration(1)

	for i, offset in ipairs(points) do
		local point = anim:CreateControlPoint()
		point:SetOrder(i)
		point:SetOffset(0, offset)
	end

	TargetIndicator.TopArrowAnim = animGroup

	-- Right arrow
	TargetIndicator.RightArrow = CreateArrow(TargetIndicator, "LEFT", 3, 0, math_rad(-90))

	-- Glow
	TargetIndicator.Glow = CreateFrame("Frame", nil, TargetIndicator, "BackdropTemplate")
	TargetIndicator.Glow:SetPoint("TOPLEFT", self.Health.backdrop, -2, 2)
	TargetIndicator.Glow:SetPoint("BOTTOMRIGHT", self.Health.backdrop, 2, -2)
	TargetIndicator.Glow:SetBackdrop({ edgeFile = C["Media"].Textures.GlowTexture, edgeSize = 4 })
	TargetIndicator.Glow:SetBackdropBorderColor(unpack(C["Nameplate"].TargetIndicatorColor))
	TargetIndicator.Glow:SetFrameLevel(0)

	-- Name glow
	TargetIndicator.nameGlow = TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.nameGlow:SetSize(150, 80)
	TargetIndicator.nameGlow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
	TargetIndicator.nameGlow:SetVertexColor(102 / 255, 157 / 255, 255 / 255)
	TargetIndicator.nameGlow:SetBlendMode("ADD")
	TargetIndicator.nameGlow:SetPoint("CENTER", self, "BOTTOM")

	self.TargetIndicator = TargetIndicator
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateTargetChange, true)
	Module.UpdateTargetIndicator(self)
end

local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function Module:QuestIconCheck()
	if not C["Nameplate"].QuestIndicator then
		return
	end

	CheckInstanceStatus()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstanceStatus)
end

function Module:UpdateForQuestie(npcID)
	local data = _QuestieTooltips.lookupByKey and _QuestieTooltips.lookupByKey["m_" .. npcID]
	if data then
		local foundObjective, progressText
		for _, tooltip in pairs(data) do
			if not tooltip.npc then
				local questID = tooltip.questId
				if questID then
					if _QuestiePlayer.currentQuestlog[questID] then
						foundObjective = true

						if tooltip.objective and tooltip.objective.Needed then
							progressText = tooltip.objective.Needed - tooltip.objective.Collected
							if progressText == 0 then
								foundObjective = nil
							end
							break
						end
					end
				end
			end
		end

		if foundObjective then
			self.questIcon:Show()
			self.questCount:SetText(progressText)
		end
	end
end

function Module:UpdateCodexQuestUnit(name)
	if name and CodexMap.tooltips[name] then
		for _, meta in pairs(CodexMap.tooltips[name]) do
			local questData = meta["quest"]
			local quests = CodexDB.quests.loc

			if questData then
				for questIndex = 1, GetNumQuestLogEntries() do
					local _, _, _, header, _, _, _, questId = GetQuestLogTitle(questIndex)
					if not header and quests[questId] and questData == quests[questId].T then
						local objectives = GetNumQuestLeaderBoards(questIndex)
						local foundObjective, progressText = nil
						if objectives then
							for i = 1, objectives do
								local text, type = GetQuestLogLeaderBoard(i, questIndex)
								if type == "monster" then
									local _, _, monsterName, objNum, objNeeded = strfind(text, Codex:SanitizePattern(QUEST_MONSTERS_KILLED))
									if meta["spawn"] == monsterName then
										progressText = objNeeded - objNum
										foundObjective = true
										break
									end
								elseif table.getn(meta["item"]) > 0 and type == "item" and meta["dropRate"] then
									local _, _, itemName, objNum, objNeeded = strfind(text, Codex:SanitizePattern(QUEST_OBJECTS_FOUND))
									for _, item in pairs(meta["item"]) do
										if item == itemName then
											progressText = objNeeded - objNum
											foundObjective = true
											break
										end
									end
								end
							end
						end

						if foundObjective and progressText > 0 then
							self.questIcon:Show()
							self.questCount:SetText(progressText)
						elseif not foundObjective then
							self.questIcon:Show()
						end
					end
				end
			end
		end
	end
end

function Module:UpdateQuestIndicator()
	if not C["Nameplate"].QuestIndicator then
		return
	end

	self.questIcon:Hide()
	self.questCount:SetText("")

	if CodexMap then
		Module.UpdateCodexQuestUnit(self, self.unitName)
	elseif _QuestieTooltips and _QuestiePlayer then
		Module.UpdateForQuestie(self, self.npcID)
	end
end

function Module:AddQuestIcon(self)
	if not C["Nameplate"].QuestIndicator then
		return
	end

	self.questIcon = self:CreateTexture(nil, "OVERLAY", nil, 2)
	self.questIcon:SetPoint("LEFT", self, "RIGHT", -6, 0)
	self.questIcon:SetSize(26, 32)
	self.questIcon:SetAtlas("adventureguide-microbutton-alert")
	self.questIcon:Hide()

	self.questCount = K.CreateFontString(self, 14, "", nil, "LEFT", 0, 0)
	self.questCount:SetPoint("LEFT", self.questIcon, "RIGHT", -3, 0)

	self:RegisterEvent("QUEST_LOG_UPDATE", Module.UpdateQuestIndicator, true)
end

function Module:AddClassIcon(self)
	if not C["Nameplate"].ClassIcon then
		return
	end

	self.Class = CreateFrame("Frame", nil, self)
	self.Class:SetSize(self.Health:GetHeight(), self.Health:GetHeight())
	self.Class:SetPoint("LEFT", self.Health, "RIGHT", 6, 0)
	self.Class:CreateShadow()

	self.Class.Icon = self.Class:CreateTexture(nil, "OVERLAY")
	self.Class.Icon:SetAllPoints()
end

function Module:UpdateClassIcon(self, unit)
	if not C["Nameplate"].ClassIcon then
		return
	end

	local reaction = UnitReaction(unit, "player")
	if UnitIsPlayer(unit) and (reaction and reaction <= 4) then
		local _, class = UnitClass(unit)

		if class then
			local atlas = "classicon-" .. class:lower()
			self.Class.Icon:SetAtlas(atlas, true)
			self.Class:Show()

			-- Set the backdrop border color to the class color
			local classColor = K.Colors.class[class]
			if classColor then
				self.Class.Shadow:SetBackdropBorderColor(classColor[1], classColor[2], classColor[3], 0.8)
			else
				self.Class.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
			end
		else
			self.Class.Icon:SetAtlas(nil)
			self.Class:Hide()
			self.Class.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
		end
	else
		self.Class.Icon:SetAtlas(nil)
		self.Class:Hide()
		self.Class.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
	end
end

function Module:AddCreatureIcon(self)
	local ClassifyIndicator = self.Health:CreateTexture(nil, "ARTWORK")
	ClassifyIndicator:SetTexture(K.MediaFolder .. "Nameplates\\star")
	ClassifyIndicator:SetPoint("RIGHT", self.nameText, "LEFT", 10, 0)
	ClassifyIndicator:SetSize(16, 16)
	ClassifyIndicator:Hide()

	self.ClassifyIndicator = ClassifyIndicator
end

function Module:UpdateUnitClassify(unit)
	if not self.ClassifyIndicator then
		return
	end

	if not unit then
		unit = self.unit
	end

	self.ClassifyIndicator:Hide()

	local class = UnitClassification(unit)
	local classify = class and NPClassifies[class]
	if classify then
		local r, g, b, desature = unpack(classify)
		self.ClassifyIndicator:SetVertexColor(r, g, b)
		self.ClassifyIndicator:SetDesaturated(desature)
		self.ClassifyIndicator:Show()
	end
end

-- Mouseover indicator
function Module:IsMouseoverUnit()
	if not self or not self.unit then
		return
	end

	if self:IsVisible() and UnitExists("mouseover") then
		return UnitIsUnit("mouseover", self.unit)
	end

	return false
end

function Module:UpdateMouseoverShown()
	if not self or not self.unit then
		return
	end

	if self:IsShown() and UnitIsUnit("mouseover", self.unit) then
		self.HighlightIndicator:Show()
		self.HighlightUpdater:Show()
	else
		self.HighlightUpdater:Hide()
	end
end

function Module:HighlightOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		if not Module.IsMouseoverUnit(self.__owner) then
			self:Hide()
		end
		self.elapsed = 0
	end
end

function Module:HighlightOnHide()
	self.__owner.HighlightIndicator:Hide()
end

function Module:MouseoverIndicator(self)
	local highlight = CreateFrame("Frame", nil, self.Health)
	highlight:SetAllPoints(self)
	highlight:Hide()

	local texture = highlight:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetColorTexture(1, 1, 1, 0.25)

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Module.UpdateMouseoverShown, true)

	local updater = CreateFrame("Frame", nil, self)
	updater.__owner = self
	updater:SetScript("OnUpdate", Module.HighlightOnUpdate)
	updater:HookScript("OnHide", Module.HighlightOnHide)

	self.HighlightIndicator = highlight
	self.HighlightUpdater = updater
end

-- Interrupt info on castbars
function Module:UpdateSpellInterruptor(...)
	local _, _, sourceGUID, sourceName, _, _, destGUID = ...
	if destGUID == self.unitGUID and sourceGUID and sourceName and sourceName ~= "" then
		local _, class = GetPlayerInfoByGUID(sourceGUID)
		local r, g, b = K.ColorClass(class)
		local color = K.RGBToHex(r, g, b)
		local sourceName = Ambiguate(sourceName, "short")
		self.Castbar.Text:SetText(INTERRUPTED .. " > " .. color .. sourceName)
		self.Castbar.Time:SetText("")
	end
end

function Module:SpellInterruptor(self)
	if not self.Castbar then
		return
	end

	self:RegisterCombatEvent("SPELL_INTERRUPT", Module.UpdateSpellInterruptor)
end

local function updateSpellTarget(self, _, unit)
	Module.PostCastUpdate(self.Castbar, unit)
end

-- Create Nameplates
local platesList = {}
function Module:CreatePlates()
	self.mystyle = "nameplate"

	self:SetSize(C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight)
	self:SetPoint("CENTER")
	self:SetScale(C["General"].UIScale)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(4)

	self.Health.backdrop = self.Health:CreateShadow(true) -- don't mess up with libs
	self.Health.backdrop:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -3, 3)
	self.Health.backdrop:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 3, -3)
	self.Health.backdrop:SetFrameLevel(self.Health:GetFrameLevel())

	self.Health.frequentUpdates = true
	self.Health.UpdateColor = Module.UpdateColor

	if C["Nameplate"].Smooth then
		K:SmoothBar(self.Health)
	end

	self.levelText = K.CreateFontString(self, C["Nameplate"].NameTextSize, "", "", false)
	self.levelText:SetJustifyH("RIGHT")
	self.levelText:ClearAllPoints()
	self.levelText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 6, 4)
	self.levelText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 6, 4)
	self:Tag(self.levelText, "[nplevel]")

	self.nameText = K.CreateFontString(self, C["Nameplate"].NameTextSize, "", "", false)
	self.nameText:SetJustifyH("LEFT")
	self.nameText:ClearAllPoints()
	self.nameText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
	self.nameText:SetPoint("BOTTOMRIGHT", self.levelText, "TOPRIGHT", -21, 4)

	self.npcTitle = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.npcTitle:ClearAllPoints()
	self.npcTitle:SetPoint("TOP", self.nameText, "BOTTOM", 0, -4)
	self.npcTitle:Hide()
	self:Tag(self.npcTitle, "[npctitle]")

	self.guildName = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.guildName:SetTextColor(211 / 255, 211 / 255, 211 / 255)
	self.guildName:ClearAllPoints()
	self.guildName:SetPoint("TOP", self.nameText, "BOTTOM", 0, -4)
	self.guildName:Hide()
	self:Tag(self.guildName, "[guildname]")

	self.tarName = K.CreateFontString(self, C["Nameplate"].NameTextSize + 2)
	self.tarName:ClearAllPoints()
	self.tarName:SetPoint("TOP", self, "BOTTOM", 0, -10)
	self.tarName:Hide()
	self:Tag(self.tarName, "[tarname]")

	self.healthValue = K.CreateFontString(self.Overlay, C["Nameplate"].HealthTextSize, "", "", false, "CENTER", 0, 0)
	self.healthValue:SetPoint("CENTER", self.Overlay, 0, 0)
	self:Tag(self.healthValue, "[nphp]")

	self.Castbar = CreateFrame("StatusBar", "oUF_CastbarNameplate", self)
	self.Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Castbar:SetHeight(self:GetHeight() + 6)
	self.Castbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.Castbar:SetFrameLevel(10)
	self.Castbar:CreateShadow(true)
	self.Castbar.castTicks = {}

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY", nil, 2)
	self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight() - 2)
	self.Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
	self.Castbar.Spark:SetBlendMode("ADD")
	self.Castbar.Spark:SetAlpha(0.8)

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY", nil, 4)
	self.Castbar.Shield:SetAtlas("Soulbinds_Portrait_Lock")
	self.Castbar.Shield:SetSize(self:GetHeight() + 14, self:GetHeight() + 14)
	self.Castbar.Shield:SetPoint("TOP", self.Castbar, "CENTER", 0, 6)

	self.Castbar.Time = K.CreateFontString(self.Castbar, 12, "", "", false, "RIGHT", 0, -1)
	self.Castbar.Text = K.CreateFontString(self.Castbar, 12, "", "", false, "LEFT", 0, -1)
	self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -5, 0)
	self.Castbar.Text:SetJustifyH("LEFT")

	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetSize(self:GetHeight() * 2 + 10, self:GetHeight() * 2 + 10)
	self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -3, 0)
	self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:CreateShadow(true)
	self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
	self.Castbar.Button:SetFrameLevel(self.Castbar:GetFrameLevel())

	self.Castbar.glowFrame = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.glowFrame:SetPoint("CENTER", self.Castbar.Icon)
	self.Castbar.glowFrame:SetSize(self:GetHeight() * 2 + 5, self:GetHeight() * 2 + 10)

	self.Castbar.spellTarget = K.CreateFontString(self.Castbar, C["Nameplate"].NameTextSize + 2)
	self.Castbar.spellTarget:ClearAllPoints()
	self.Castbar.spellTarget:SetJustifyH("LEFT")
	self.Castbar.spellTarget:SetPoint("TOPLEFT", self.Castbar.Text, "BOTTOMLEFT", 0, -6)
	self:RegisterEvent("UNIT_TARGET", updateSpellTarget)

	self.Castbar.timeToHold = 0.5
	self.Castbar.decimal = "%.1f"
	self.Castbar.OnUpdate = Module.OnCastbarUpdate
	self.Castbar.PostCastStart = Module.PostCastStart
	self.Castbar.PostCastUpdate = Module.PostCastUpdate
	self.Castbar.PostCastStop = Module.PostCastStop
	self.Castbar.PostCastFail = Module.PostCastFailed
	self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible

	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)
	self.RaidTargetIndicator:SetSize(18, 18)

	do
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints(self.Health)

		local normalTexture = K.GetTexture(C["General"].Texture)

		local myBar = frame:CreateTexture(nil, "BORDER", nil, 5)
		myBar:SetWidth(1)
		myBar:SetTexture(normalTexture)
		myBar:SetVertexColor(0, 1, 0, 0.5)

		local otherBar = frame:CreateTexture(nil, "BORDER", nil, 5)
		otherBar:SetWidth(1)
		otherBar:SetTexture(normalTexture)
		otherBar:SetVertexColor(0, 1, 1, 0.5)

		self.HealPredictionAndAbsorb = {
			myBar = myBar,
			otherBar = otherBar,
			maxOverflow = 1,
		}
		self.predicFrame = frame
	end

	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetFrameLevel(self:GetFrameLevel() + 2)
	self.Auras.spacing = 4
	self.Auras.initdialAnchor = "BOTTOMLEFT"
	self.Auras["growth-y"] = "UP"
	if C["Nameplate"].NameplateClassPower then
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 8 + C["Nameplate"].PlateHeight)
		self.Auras:SetPoint("BOTTOMRIGHT", self.nameText, "TOPRIGHT", 0, 8 + C["Nameplate"].PlateHeight)
	else
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 6)
		self.Auras:SetPoint("BOTTOMRIGHT", self.nameText, "TOPRIGHT", 0, 6)
	end
	self.Auras.numTotal = C["Nameplate"].MaxAuras
	self.Auras.size = C["Nameplate"].AuraSize
	self.Auras.gap = false
	self.Auras.disableMouse = true
	self.Auras.CustomFilter = Module.CustomFilter

	Module:UpdateAuraContainer(self:GetWidth(), self.Auras, self.Auras.numTotal)

	self.Auras.showStealableBuffs = true
	self.Auras.PostCreateIcon = Module.PostCreateIcon
	self.Auras.PostUpdateIcon = Module.PostUpdateIcon
	self.Auras.PostUpdateInfo = Module.AurasPostUpdateInfo

	Module:CreateThreatColor(self)

	self.PvPClassificationIndicator = self:CreateTexture(nil, "ARTWORK")
	self.PvPClassificationIndicator:SetSize(18, 18)
	self.PvPClassificationIndicator:ClearAllPoints()
	if C["Nameplate"].ClassIcon then
		self.PvPClassificationIndicator:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 20)
	else
		self.PvPClassificationIndicator:SetPoint("LEFT", self, "RIGHT", 6, 0)
	end

	self.powerText = K.CreateFontString(self, 15)
	self.powerText:ClearAllPoints()
	self.powerText:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -4)
	self:Tag(self.powerText, "[nppp]")

	Module:MouseoverIndicator(self)
	Module:AddTargetIndicator(self)
	Module:AddCreatureIcon(self)
	Module:AddQuestIcon(self)
	Module:SpellInterruptor(self)
	Module:AddClassIcon(self)

	platesList[self] = self:GetName()
end

function Module:ToggleNameplateAuras()
	if C["Nameplate"].PlateAuras then
		if not self:IsElementEnabled("Auras") then
			self:EnableElement("Auras")
		end
	else
		if self:IsElementEnabled("Auras") then
			self:DisableElement("Auras")
		end
	end
end

function Module:UpdateNameplateAuras()
	Module.ToggleNameplateAuras(self)

	if not C["Nameplate"].PlateAuras then
		return
	end

	local element = self.Auras
	if C["Nameplate"].NameplateClassPower then
		element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 6 + C["Nameplate"].PlateHeight)
	else
		element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
	end

	element.numTotal = C["Nameplate"].MaxAuras
	element.size = C["Nameplate"].AuraSize
	element.showDebuffType = true
	element:SetWidth(self:GetWidth())
	element:SetHeight((element.size + element.spacing) * 2)

	element:ForceUpdate()
end

function Module:UpdateNameplateSize()
	if self.plateType == "NameOnly" then
		self:Tag(self.nameText, "[nprare][color][name] [nplevel]")
		self.npcTitle:UpdateTag()
	else
		self:Tag(self.nameText, "[nprare][name]")
	end

	self.nameText:UpdateTag()
end

function Module:RefreshNameplats()
	for nameplate in pairs(platesList) do
		Module.UpdateNameplateSize(nameplate)
		Module.UpdateUnitClassify(nameplate)
		Module.UpdateNameplateAuras(nameplate)
		Module.UpdateTargetIndicator(nameplate)
		Module.UpdateTargetChange(nameplate)
	end
	Module:UpdateClickableSize()
end

function Module:RefreshAllPlates()
	Module:RefreshNameplats()
	Module:ResizeTargetPower()
end

local DisabledElements = {
	"Health",
	"Castbar",
	"HealPredictionAndAbsorb",
	"ThreatIndicator",
}
function Module:UpdatePlateByType()
	local name = self.nameText
	local level = self.levelText
	local hpval = self.healthValue
	local title = self.npcTitle
	local guild = self.guildName
	local raidtarget = self.RaidTargetIndicator
	local questIcon = self.questIcon

	if name then
		name:ClearAllPoints()
	end

	if raidtarget then
		raidtarget:ClearAllPoints()
	end

	if self.plateType == "NameOnly" then
		for _, element in pairs(DisabledElements) do
			if self:IsElementEnabled(element) then
				self:DisableElement(element)
			end
		end

		if name then
			name:SetJustifyH("CENTER")
			name:SetPoint("CENTER", self, "BOTTOM")
		end

		if level then
			level:Hide()
		end

		if hpval then
			hpval:Hide()
		end

		if title then
			title:Show()
		end

		if guild then
			guild:Show()
		end

		if raidtarget then
			raidtarget:SetPoint("BOTTOM", name, "TOP", 0, 6)
		end

		if questIcon then
			questIcon:SetPoint("LEFT", name, "RIGHT", -6, 0)
		end
	else
		for _, element in pairs(DisabledElements) do
			if not self:IsElementEnabled(element) then
				self:EnableElement(element)
			end
		end

		if name then
			name:SetJustifyH("LEFT")
			name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
			name:SetPoint("BOTTOMRIGHT", level, "TOPRIGHT", -21, 4)
		end

		if level then
			level:Show()
		end

		if hpval then
			hpval:Show()
		end

		if title then
			title:Hide()
		end

		if guild then
			guild:Hide()
		end

		if raidtarget then
			raidtarget:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)
		end

		if questIcon then
			questIcon:SetPoint("LEFT", self, "RIGHT", 1, 0)
		end
	end

	Module.UpdateNameplateSize(self)
	Module.UpdateTargetIndicator(self)
	Module.ToggleNameplateAuras(self)
end

function Module:RefreshPlateType(unit)
	self.reaction = UnitReaction(unit, "player")
	self.isFriendly = self.reaction and self.reaction >= 4 and not UnitCanAttack("player", unit)
	if C["Nameplate"].NameOnly and self.isFriendly or self.widgetsOnly then
		self.plateType = "NameOnly"
	elseif C["Nameplate"].FriendPlate and self.isFriendly then
		self.plateType = "FriendPlate"
	else
		self.plateType = "None"
	end

	if self.previousType == nil or self.previousType ~= self.plateType then
		Module.UpdatePlateByType(self)
		self.previousType = self.plateType
	end
end

function Module:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate_GetNamePlateForUnit(unit)
	local unitFrame = nameplate and nameplate.unitFrame
	if unitFrame and unitFrame.unitName then
		Module.RefreshPlateType(unitFrame, unit)
	end
end

function Module:RefreshPlateOnFactionChanged()
	K:RegisterEvent("UNIT_FACTION", Module.OnUnitFactionChanged)
end

function Module:PostUpdatePlates(event, unit)
	if not self then
		return
	end

	if event == "NAME_PLATE_UNIT_ADDED" then
		self.unitName = UnitName(unit)
		self.unitGUID = UnitGUID(unit)
		self.isPlayer = UnitIsPlayer(unit)
		self.npcID = K.GetNPCID(self.unitGUID)

		Module.RefreshPlateType(self, unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self.npcID = nil
	end

	if event ~= "NAME_PLATE_UNIT_REMOVED" then
		Module.UpdateUnitPower(self)
		Module.UpdateTargetChange(self)
		Module.UpdateUnitClassify(self, unit)
		Module.UpdateQuestIndicator(self)
		Module:UpdateClassIcon(self, unit)
		Module:UpdateTargetClassPower()
	end
end

-- Player Nameplate
function Module:PlateVisibility(event)
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		K.UIFrameFadeIn(self.Health, 0.2, self.Health:GetAlpha(), 1)
		K.UIFrameFadeIn(self.Power, 0.2, self.Power:GetAlpha(), 1)
		K.UIFrameFadeIn(self.Auras, 0.2, self.Power:GetAlpha(), 1)
	else
		K.UIFrameFadeOut(self.Health, 0.2, self.Health:GetAlpha(), 0)
		K.UIFrameFadeOut(self.Power, 0.2, self.Power:GetAlpha(), 0)
		K.UIFrameFadeOut(self.Auras, 0.2, self.Power:GetAlpha(), 0)
	end
end

function Module:CreatePlayerPlate()
	self.mystyle = "PlayerPlate"

	local iconSize, margin = C["Nameplate"].PPIconSize, 2
	self:SetSize(iconSize * 5 + margin * 4, C["Nameplate"].PPHeight)
	self:EnableMouse(false)
	self.iconSize = iconSize

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.Health:SetStatusBarColor(0.1, 0.1, 0.1)
	self.Health:CreateShadow(true)

	self.Health.colorClass = true

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.Power:SetHeight(C["Nameplate"].PPPHeight)
	self.Power:SetWidth(self:GetWidth())
	self.Power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Power:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Power:CreateShadow(true)

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	Module:CreateClassPower(self)

	if C["Nameplate"].ClassAuras then
		-- local Lumos = K:GetModule("Auras")
		-- if Lumos then
		-- 	Lumos:CreateLumos(self)
		-- end
	end

	local textFrame = CreateFrame("Frame", nil, self.Power)
	textFrame:SetAllPoints()
	self.powerText = K.CreateFontString(textFrame, 12, "")
	self:Tag(self.powerText, "[pppower]")
	Module:TogglePlatePower()

	Module:CreateGCDTicker(self)
	Module:UpdateTargetClassPower()
	Module:TogglePlateVisibility()
end

function Module:TogglePlayerPlate()
	local plate = oUF_PlayerPlate
	if not plate then
		return
	end

	if C["Nameplate"].ShowPlayerPlate then
		plate:Enable()
	else
		plate:Disable()
	end
end

function Module:TogglePlatePower()
	local plate = oUF_PlayerPlate
	if not plate then
		return
	end

	plate.powerText:SetShown(C["Nameplate"].PPPowerText)
end

function Module:TogglePlateVisibility()
	local plate = oUF_PlayerPlate
	if not plate then
		return
	end

	if C["Nameplate"].PPHideOOC then
		plate:RegisterEvent("PLAYER_REGEN_ENABLED", Module.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_REGEN_DISABLED", Module.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_ENTERING_WORLD", Module.PlateVisibility, true)
		Module.PlateVisibility(plate)
	else
		plate:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.PlateVisibility)
		plate:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.PlateVisibility)
		plate:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.PlateVisibility)
		Module.PlateVisibility(plate, "PLAYER_REGEN_DISABLED")
	end
end

-- Target nameplate
function Module:CreateTargetPlate()
	self.mystyle = "targetplate"
	self:EnableMouse(false)
	self:SetSize(10, 10)

	Module:CreateClassPower(self)
end

function Module:UpdateTargetClassPower()
	local plate = oUF_TargetPlate
	if not plate then
		return
	end

	local bar = plate.ClassPowerBar
	local nameplate = C_NamePlate_GetNamePlateForUnit("target")
	if nameplate then
		bar:SetParent(nameplate.unitFrame)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame, "TOP", 0, 24)
		bar:Show()
	else
		bar:Hide()
	end
end

function Module:ToggleTargetClassPower()
	local plate = oUF_TargetPlate
	if not plate then
		return
	end

	local playerPlate = oUF_PlayerPlate
	if C["Nameplate"].NameplateClassPower then
		plate:Enable()
		if plate.ClassPower then
			if not plate:IsElementEnabled("ClassPower") then
				plate:EnableElement("ClassPower")
				plate.ClassPower:ForceUpdate()
			end
			if playerPlate then
				if playerPlate:IsElementEnabled("ClassPower") then
					playerPlate:DisableElement("ClassPower")
				end
			end
		end
	else
		plate:Disable()
		if plate.ClassPower then
			if plate:IsElementEnabled("ClassPower") then
				plate:DisableElement("ClassPower")
			end
			if playerPlate then
				if not playerPlate:IsElementEnabled("ClassPower") then
					playerPlate:EnableElement("ClassPower")
					playerPlate.ClassPower:ForceUpdate()
				end
			end
		end
	end
end

function Module:ResizeTargetPower()
	local plate = oUF_TargetPlate
	if not plate then
		return
	end

	local barWidth = C["Nameplate"].PlateWidth
	local barHeight = C["Nameplate"].PlateHeight
	local bars = plate.ClassPower or plate.Runes
	if bars then
		plate.ClassPowerBar:SetSize(barWidth, barHeight)
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max - 1) * 6) / max)
		end
	end
end

function Module:CreateGCDTicker(self)
	if not C["Nameplate"].PPGCDTicker then
		return
	end

	local GCD = CreateFrame("Frame", "oUF_PlateGCD", self.Power)
	GCD:SetWidth(self:GetWidth())
	GCD:SetHeight(C["Nameplate"].PPPHeight)
	GCD:SetPoint("LEFT", self.Power, "LEFT", 0, 0)

	GCD.Color = { 1, 1, 1, 0.6 }
	GCD.Texture = C["Media"].Textures.Spark128Texture
	GCD.Height = C["Nameplate"].PPPHeight
	GCD.Width = 128 / 2

	self.GCD = GCD
end
