local K, C = unpack(select(2, ...))
local Module = K:NewModule("Unitframes", "AceEvent-3.0")
local LCD = K.LibClassicDurations

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G
local math_ceil = _G.math.ceil
local pairs = _G.pairs
local select = _G.select
local string_find = _G.string.find
local string_match = _G.string.match
local table_getn = _G.table.getn
local table_insert = _G.table.insert
local tonumber = _G.tonumber
local unpack = _G.unpack

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local COOLDOWN_Anchor = _G.COOLDOWN_Anchor
local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GetCVarDefault = _G.GetCVarDefault
local GetNumQuestLeaderBoards = _G.GetNumQuestLeaderBoards
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetQuestLogLeaderBoard = _G.GetQuestLogLeaderBoard
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local PVE_PVP_CC_Anchor = _G.PVE_PVP_CC_Anchor
local PVE_PVP_DEBUFF_Anchor = _G.PVE_PVP_DEBUFF_Anchor
local P_BUFF_ICON_Anchor = _G.P_BUFF_ICON_Anchor
local P_PROC_ICON_Anchor = _G.P_PROC_ICON_Anchor
local PlaySound = _G.PlaySound
local SOUNDKIT = _G.SOUNDKIT
local SPECIAL_P_BUFF_ICON_Anchor = _G.SPECIAL_P_BUFF_ICON_Anchor
local SetCVar = _G.SetCVar
local T_BUFF_Anchor = _G.T_BUFF_Anchor
local T_DEBUFF_ICON_Anchor = _G.T_DEBUFF_ICON_Anchor
local T_DE_BUFF_BAR_Anchor = _G.T_DE_BUFF_BAR_Anchor
local UIParent = _G.UIParent
local UnitAura = _G.UnitAura
local UnitCanAttack = _G.UnitCanAttack
local CastingInfo = _G.CastingInfo
local ChannelInfo = _G.ChannelInfo
local UnitClass = _G.UnitClass
local UnitExists = _G.UnitExists
local UnitFactionGroup = _G.UnitFactionGroup
local UnitFrame_OnEnter = _G.UnitFrame_OnEnter
local UnitFrame_OnLeave = _G.UnitFrame_OnLeave
local UnitIsConnected = _G.UnitIsConnected
local UnitIsDead = _G.UnitIsDead
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsFriend = _G.UnitIsFriend
local UnitIsGhost = _G.UnitIsGhost
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local UnitReaction = _G.UnitReaction
local hooksecurefunc = _G.hooksecurefunc
local oUF_RaidDebuffs = _G.oUF_RaidDebuffs

Module.Units = {}
Module.Headers = {}
Module.ticks = {}
Module.guidToPlate = {}

local classify = {
	rare = {1, 1, 1, true},
	elite = {1, 1, 1},
	rareelite = {1, .1, .1},
	worldboss = {0, 1, 0},
}

if (K.LibClassicCasterino) then
	UnitChannelInfo = function(unit)
		return K.LibClassicCasterino:UnitChannelInfo(unit)
	end
end

Module.CustomAuraFilter = {
	Blacklist = function(_, _, _, _, _, _, _, _, _, _, _, _, spellID)
		-- Don't allow blacklisted auras
		if K.AuraBlackList[spellID] then
			return false
		end

		return true
	end,
}

function Module:UpdateClassPortraits(unit)
	if not unit then
		return
	end

	local _, unitClass = UnitClass(unit)
	if unitClass then
		local PortraitValue = C["General"].PortraitStyle.Value
		local ClassTCoords = CLASS_ICON_TCOORDS[unitClass]

		local defaultCPs = "ClassPortraits"
		local newCPs = "NewClassPortraits"

		for _, value in pairs({
			PortraitValue,
		}) do
			if value and value == defaultCPs and UnitIsPlayer(unit) then
				self:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
				if ClassTCoords then
					self:SetTexCoord(ClassTCoords[1], ClassTCoords[2], ClassTCoords[3], ClassTCoords[4])
				end
			elseif value and value == newCPs and UnitIsPlayer(unit) then
				local betterClassIcons = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\BetterClassIcons\\%s.tga"
				self:SetTexture(betterClassIcons:format(unitClass))
			else
				self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			end
		end
	end
end

function Module:UpdatePortraitColor(unit, min, max)
	if not UnitIsConnected(unit) then
		self.Portrait:SetVertexColor(0.5, 0.5, 0.5, 0.7)
	elseif UnitIsDead(unit) then
		self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 0.7)
	elseif UnitIsGhost(unit) then
		self.Portrait:SetVertexColor(0.3, 0.3, 0.9, 0.7)
	elseif max == 0 or min/max * 100 < 25 then
		if UnitIsPlayer(unit) then
			if unit ~= "player" then
				self.Portrait:SetVertexColor(1, 0, 0, 0.7)
			end
		end
	else
		self.Portrait:SetVertexColor(1, 1, 1, 1)
	end
end

function Module:PostUpdatePvPIndicator(unit, status)
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) and status == "ffa" then
		self:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self:SetTexCoord(0, 0.65625, 0, 0.65625)
	elseif factionGroup and UnitIsPVP(unit) and status ~= nil then
		self:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\ObjectiveWidget")

		if factionGroup == "Alliance" then
			self:SetTexCoord(0.00390625, 0.136719, 0.511719, 0.671875)
		else
			self:SetTexCoord(0.00390625, 0.136719, 0.679688, 0.839844)
		end
	end
end

function Module:UpdateHealth(unit, cur, max)
	if C["General"].PortraitStyle.Value == "ThreeDPortraits" then
		return
	end

	local parent = self.__owner
	Module.UpdatePortraitColor(parent, unit, cur, max)
end

function Module:CreateHeader()
	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", function()
		UnitFrame_OnEnter(self)

		if not self.Highlight then
			return
		end
		self.Highlight:Show()
	end)

	self:HookScript("OnLeave", function()
		UnitFrame_OnLeave(self)

		if not self.Highlight then
			return
		end
		self.Highlight:Hide()
	end)
end

function Module:UpdateUnitClassify(unit)
	local class = _G.UnitClassification(unit)
	if self.creatureIcon then
		if class and classify[class] and (self.frameType == "FRIENDLY_NPC" or self.frameType == "ENEMY_NPC") then
			local r, g, b, desature = unpack(classify[class])
			self.creatureIcon:SetVertexColor(r, g, b)
			self.creatureIcon:SetDesaturated(desature)
			self.creatureIcon:SetAlpha(1)
		else
			self.creatureIcon:SetAlpha(0)
		end
	end
end

-- Quest progress
local isInInstance
local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function Module:QuestIconCheck()
	if not C["Nameplates"].QuestInfo then
		return
	end

	CheckInstanceStatus()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstanceStatus)
end

function Module:UpdateQuestUnit(_, unit)
	if not C["Nameplates"].QuestInfo then
		return
	end

	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit

	local isLootQuest, questProgress
	K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	K.ScanTooltip:SetUnit(unit)

	for i = 2, K.ScanTooltip:NumLines() do
		local textLine = _G[K.ScanTooltip:GetName().."TextLeft"..i]
		local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			local unitName, progressText = string_match(text, "^ ([^ ]-) ?%- (.+)$")
			if r > .99 and g > .82 and b == 0 then
				isLootQuest = true
			elseif unitName and progressText then
				isLootQuest = false
				if unitName == "" or unitName == K.Name then
					local current, goal = string_match(progressText, "(%d+)/(%d+)")
					local progress = string_match(progressText, "([%d%.]+)%%")
					if current and goal then
						if tonumber(current) < tonumber(goal) then
							questProgress = goal - current
							break
						end
					elseif progress then
						progress = tonumber(progress)
						if progress and progress < 100 then
							questProgress = progress.."%"
							break
						end
					else
						isLootQuest = true
						break
					end
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		self.questIcon:SetAtlas("Warfronts-BaseMapIcons-Horde-Barracks-Minimap")
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		if isLootQuest then
			self.questIcon:SetAtlas("adventureguide-microbutton-alert")
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

function Module:UpdateForQuestie(name)
	local data = name and QuestieTooltips.tooltipLookup["u_"..name]
	if data then
		local foundObjective, progressText
		for _, tooltip in pairs(data) do
			local questID = tooltip.Objective.QuestData.Id
			QuestieQuest:UpdateQuest(questID)
			if qCurrentQuestlog[questID] then
				foundObjective = true
				if tooltip.Objective.Needed then
					progressText = tooltip.Objective.Needed - tooltip.Objective.Collected
					if progressText == 0 then
						foundObjective = nil
					end
					break
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
									local _, _, monsterName, objNum, objNeeded = string_find(text, Codex:SanitizePattern(QUEST_MONSTERS_KILLED))
									if meta["spawn"] == monsterName then
										progressText = objNeeded - objNum
										foundObjective = true
										break
									end
								elseif table_getn(meta["item"]) > 0 and type == "item" and meta["dropRate"] then
									local _, _, itemName, objNum, objNeeded = string_find(text, Codex:SanitizePattern(QUEST_OBJECTS_FOUND))
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
	if not C["Nameplates"].QuestInfo then
		return
	end

	self.questIcon:Hide()
	self.questCount:SetText("")

	local name = self.unitName
	if QuestieTooltips then
		Module.UpdateForQuestie(self, name)
	elseif CodexMap then
		Module.UpdateCodexQuestUnit(self, name)
	end
end

-- Castbar Functions
local function updateCastBarTicks(bar, numTicks)
	if numTicks and numTicks > 0 then
		local delta = bar:GetWidth() / numTicks
		for i = 1, numTicks do
			if not Module.ticks[i] then
				Module.ticks[i] = bar:CreateTexture(nil, "OVERLAY")
				Module.ticks[i]:SetTexture(C["Media"].Blank)
				Module.ticks[i]:SetVertexColor(0, 0, 0, 0.8)
				Module.ticks[i]:SetWidth(2)
				Module.ticks[i]:SetHeight(bar:GetHeight())
			end
			Module.ticks[i]:ClearAllPoints()
			Module.ticks[i]:SetPoint("CENTER", bar, "LEFT", delta * i, 0 )
			Module.ticks[i]:Show()
		end
	else
		for _, tick in pairs(Module.ticks) do
			tick:Hide()
		end
	end
end

function Module:FixTargetCastbarUpdate()
	if UnitIsUnit("target", "player") and not CastingInfo() and not ChannelInfo() then
		self.casting = nil
		self.channeling = nil
		self.Text:SetText(INTERRUPTED)
		self.holdTime = 0
	end
end

function Module:OnCastbarUpdate(elapsed)
	if self.casting or self.channeling then
		Module.FixTargetCastbarUpdate(self)

		local decimal = self.decimal

		local duration = self.casting and self.duration + elapsed or self.duration - elapsed
		if (self.casting and duration >= self.max) or (self.channeling and duration <= 0) then
			self.casting = nil
			self.channeling = nil
			return
		end

		if self.__owner.unit == "player" then
			if self.delay ~= 0 then
				self.Time:SetFormattedText(decimal.." - |cffff0000"..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			else
				self.Time:SetFormattedText(decimal.." - "..decimal, duration, self.max)
				if self.Lag and self.SafeZone and self.SafeZone.timeDiff and self.SafeZone.timeDiff ~= 0 then
					self.Lag:SetFormattedText("%d ms", self.SafeZone.timeDiff * 1000)
				end
			end
		else
			if duration > 1e4 then
				self.Time:SetText("∞ - ∞")
			else
				self.Time:SetFormattedText(decimal.." - "..decimal, duration, self.casting and self.max + self.delay or self.max - self.delay)
			end
		end
		self.duration = duration
		self:SetValue(duration)
		self.Spark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
	elseif self.holdTime > 0 then
		self.holdTime = self.holdTime - elapsed
	else
		self.Spark:Hide()
		local alpha = self:GetAlpha() - .02
		if alpha > 0 then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			self:Hide()
		end
	end
end

function Module:OnCastSent()
	local element = self.Castbar
	if not element.SafeZone then
		return
	end

	element.SafeZone.sendTime = GetTime()
	element.SafeZone.castSent = true
end

function Module:PostCastStart(unit)
	self:SetAlpha(1)
	self.Spark:Show()

	local colors = K.Colors.castbar
	local r, g, b = unpack(self.casting and colors.CastingColor or colors.ChannelingColor)

	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and K.Colors.class[Class]
		if t then r, g, b = t[1], t[2], t[3] end
	elseif C["Unitframe"].CastReactionColor then
		local Reaction = UnitReaction(unit, 'player')
		local t = Reaction and K.Colors.reaction[Reaction]
		if t then r, g, b = t[1], t[2], t[3] end
	end

	self:SetStatusBarColor(r, g, b)

	if unit == "vehicle" then
		if self.SafeZone then self.SafeZone:Hide() end
		if self.Lag then self.Lag:Hide() end
	elseif unit == "player" then
		local safeZone = self.SafeZone
		if not safeZone then return end

		safeZone.timeDiff = 0
		if safeZone.castSent then
			safeZone.timeDiff = GetTime() - safeZone.sendTime
			safeZone.timeDiff = safeZone.timeDiff > self.max and self.max or safeZone.timeDiff
			safeZone:SetWidth(self:GetWidth() * (safeZone.timeDiff + .001) / self.max)
			safeZone:Show()
			safeZone.castSent = false
		end

		local numTicks = 0
		if self.channeling then
			local spellID = UnitChannelInfo(unit)
			numTicks = K.ChannelingTicks[spellID] or 0
		end
		updateCastBarTicks(self, numTicks)
	elseif not UnitIsUnit(unit, "player") and self.notInterruptible then
		self:SetStatusBarColor(unpack(K.Colors.castbar.notInterruptibleColor))
	end

	-- Fix for empty icon
	if self.Icon and not self.Icon:GetTexture() or self.Icon:GetTexture() == 136235 then
		self.Icon:SetTexture(136243)
	end
end

function Module:PostUpdateInterruptible(unit)
	if unit == "vehicle" or unit == "player" then
		return
	end

	local colors = K.Colors.castbar
	local r, g, b = unpack(self.casting and colors.CastingColor or colors.ChannelingColor)

	if self.notInterruptible and UnitCanAttack("player", unit) then
		r, g, b = colors.notInterruptibleColor[1], colors.notInterruptibleColor[2], colors.notInterruptibleColor[3]
	elseif C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, Class = UnitClass(unit)
		local t = Class and K.Colors.class[Class]
		if t then r, g, b = t[1], t[2], t[3] end
	elseif C["Unitframe"].CastReactionColor then
		local Reaction = UnitReaction(unit, 'player')
		local t = Reaction and K.Colors.reaction[Reaction]
		if t then r, g, b = t[1], t[2], t[3] end
	end

	self:SetStatusBarColor(r, g, b)
end

function Module:PostCastStop()
	if not self.fadeOut then
		self:SetStatusBarColor(K.Colors.castbar.CompleteColor[1], K.Colors.castbar.CompleteColor[2], K.Colors.castbar.CompleteColor[3])
		self.fadeOut = true
	end

	self:SetValue(self.max or 1)
	self:Show()
end

function Module:PostChannelStop()
	self.fadeOut = true
	self:SetValue(0)
	self:Show()
end

function Module:PostCastFailed()
	self:SetStatusBarColor(K.Colors.castbar.FailColor[1], K.Colors.castbar.FailColor[2], K.Colors.castbar.FailColor[3])
	self:SetValue(self.max or 1)
	self.fadeOut = true
	self:Show()

	local time = self.Time
	if (time) then
		time:SetText("")
	end

	local spark = self.Spark
	if (spark) then
		spark:SetPoint("CENTER", self, "RIGHT")
	end
end

function Module:CreateAuraTimer(elapsed)
	if (self.TimeLeft) then
		self.Elapsed = (self.Elapsed or 0) + elapsed

		if self.Elapsed >= 0.1 then
			if not self.First then
				self.TimeLeft = self.TimeLeft - self.Elapsed
			else
				self.TimeLeft = self.TimeLeft - GetTime()
				self.First = false
			end

			if self.TimeLeft > 0 then
				local Time = K.FormatTime(self.TimeLeft)
				self.Remaining:SetText(Time)

				if self.TimeLeft <= 5 then
					self.Remaining:SetTextColor(1, 0, 0)
				else
					self.Remaining:SetTextColor(1, 1, 1)
				end
			else
				self.Remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.Elapsed = 0
		end
	end
end

function Module:CancelPlayerBuff(index)
	if InCombatLockdown() then
		return
	end

	CancelUnitBuff("player", self.index)
end

function Module:PostCreateAura(button)
	local buttonFont = C["Media"].Font
	local buttonFontSize = self.fontSize or self.size * 0.45

	if string_match(button:GetName(), "NamePlate") and C["Nameplates"].Enable then
		button:CreateShadow(true)
		button:CreateInnerShadow()

		button.Remaining = button:CreateFontString(nil, "OVERLAY")
		button.Remaining:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
		button.Remaining:SetPoint("CENTER", 1, 0)

		button.cd.noOCC = true
		button.cd.noCooldownCount = true
		button.cd:SetReverse(true)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT")
		button.cd:SetPoint("BOTTOMRIGHT")
		button.cd:SetHideCountdownNumbers(true)

		button.icon:SetInside()
		button.icon:SetTexCoord(unpack(K.TexCoords))
		button.icon:SetDrawLayer("ARTWORK")

		button.count:SetPoint("BOTTOMRIGHT", 3, 0)
		button.count:SetJustifyH("RIGHT")
		button.count:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
		button.count:SetTextColor(0.84, 0.75, 0.65)

		button.OverlayFrame = CreateFrame("Frame", nil, button, nil)
		button.OverlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)
		button.overlay:SetParent(button.OverlayFrame)
		button.count:SetParent(button.OverlayFrame)
		button.Remaining:SetParent(button.OverlayFrame)
	else
		-- Set "self.Buffs.isCancellable" to true to a buffs frame to be able to cancel click
		local isCancellable = button:GetParent().isCancellable

		-- Right-click-cancel script
		if isCancellable then
			-- Add a button.index to allow CancelUnitAura to work with player
			local Name = button:GetName()
			local Index = tonumber(Name:gsub("%D",""))

			button.index = Index
			button:SetScript("OnMouseUp", Module.CancelPlayerBuff)
		end

		-- Skin aura button
		button:CreateBorder()
		button:CreateInnerShadow()

		button.Remaining = button:CreateFontString(nil, "OVERLAY")
		button.Remaining:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
		button.Remaining:SetPoint("CENTER", 1, 0)

		button.cd.noOCC = true
		button.cd.noCooldownCount = true
		button.cd:SetReverse(true)
		button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
		button.cd:ClearAllPoints()
		button.cd:SetPoint("TOPLEFT", 1, -1)
		button.cd:SetPoint("BOTTOMRIGHT", -1, 1)
		button.cd:SetHideCountdownNumbers(true)

		button.icon:SetInside()
		button.icon:SetTexCoord(unpack(K.TexCoords))
		button.icon:SetDrawLayer("ARTWORK")

		button.count:SetPoint("BOTTOMRIGHT", 3, 0)
		button.count:SetJustifyH("RIGHT")
		button.count:SetFont(buttonFont, buttonFontSize, "THINOUTLINE")
		button.count:SetTextColor(0.84, 0.75, 0.65)

		button.OverlayFrame = CreateFrame("Frame", nil, button, nil)
		button.OverlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)
		button.overlay:SetParent(button.OverlayFrame)
		button.count:SetParent(button.OverlayFrame)
		button.Remaining:SetParent(button.OverlayFrame)
	end
end

function Module:PostUpdateAura(unit, button, index)
	local Name, _, _, DType, Duration, ExpirationTime, UnitCaster, IsStealable, _, SpellID = UnitAura(unit, index, button.filter)

	if Duration == 0 and ExpirationTime == 0 then
		Duration, ExpirationTime = LCD:GetAuraDurationByUnit(unit, SpellID, UnitCaster, Name)

		button.IsLibClassicDuration = true
	end

	local isPlayer = (UnitCaster == "player" or UnitCaster == "vehicle")
	local isFriend = unit and UnitIsFriend("player", unit) and not UnitCanAttack("player", unit)
	local plateShadow = string_match(button:GetName(), "NamePlate") and button.Shadow

	if button then
		if (button.filter == "HARMFUL") then
			if (not isFriend and not isPlayer) then
				button:SetBackdropBorderColor()
				button.icon:SetDesaturated(unit and true or false)

				if plateShadow then
					button.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
				end
			else
				local color = (button.DType and DebuffTypeColor[button.DType]) or DebuffTypeColor.none
				if Name and (Name == "Unstable Affliction" or Name == "Vampiric Touch") and K.Class ~= "WARLOCK" then
					button:SetBackdropBorderColor(0.05, 0.85, 0.94)

					if plateShadow then
						button.Shadow:SetBackdropBorderColor(0.05, 0.85, 0.94)
					end
				else
					button:SetBackdropBorderColor(color.r, color.g, color.b)

					if plateShadow then
						button.Shadow:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
					end
				end

				button.icon:SetDesaturated(false)
			end
		end
	else
		if (IsStealable or DType == "Magic") and not isFriend then
			button:SetBackdropBorderColor(0.93, 0.91, 0.55, 1.0)
			K.Flash(button, 0.53, true)
		else
			button:SetBackdropBorderColor()
			K.StopFlash(button)
		end
	end

	if button.Remaining then
		if (Duration and Duration > 0) then
			button.Remaining:Show()
		else
			button.Remaining:Hide()
		end

		button:SetScript("OnUpdate", Module.CreateAuraTimer)
	end

	if (button.cd) and (button.IsLibClassicDuration) then
		if (Duration and Duration > 0) then
			button.cd:SetCooldown(ExpirationTime - Duration, Duration)
			button.cd:Show()
		else
			button.cd:Hide()
		end
	end

	button.Duration = Duration
	button.TimeLeft = ExpirationTime
	button.First = true
end

function Module:CreateAuraWatchIcon(icon)
	icon:CreateShadow(true)
	icon.icon:SetPoint("TOPLEFT")
	icon.icon:SetPoint("BOTTOMRIGHT")
	icon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon.icon:SetDrawLayer("ARTWORK")

	if (icon.cd) then
		icon.cd:SetHideCountdownNumbers(true)
		icon.cd:SetReverse(true)
	end

	icon.overlay:SetTexture()
end

function Module:CreateAuraWatch(frame)
	local buffs = {}
	local Class = select(2, UnitClass("player"))

	local Auras = CreateFrame("Frame", nil, frame)
	Auras:SetPoint("TOPLEFT", frame.Health, 2, -2)
	Auras:SetPoint("BOTTOMRIGHT", frame.Health, -2, 2)
	Auras.presentAlpha = 1
	Auras.missingAlpha = 0
	Auras.icons = {}
	Auras.PostCreateIcon = Module.CreateAuraWatchIcon
	Auras.strictMatching = true

	if (K.RaidBuffsTracking["ALL"]) then
		for _, value in pairs(K.RaidBuffsTracking["ALL"]) do
			table_insert(buffs, value)
		end
	end

	if (K.RaidBuffsTracking[Class]) then
		for _, value in pairs(K.RaidBuffsTracking[Class]) do
			table_insert(buffs, value)
		end
	end

	if (buffs) then
		for _, spell in pairs(buffs) do
			local Icon = CreateFrame("Frame", nil, Auras)
			Icon.spellID = spell[1]
			Icon.anyUnit = spell[4]
			Icon:SetWidth(C["Raid"].AuraWatchIconSize)
			Icon:SetHeight(C["Raid"].AuraWatchIconSize)
			Icon:SetPoint(spell[2], 0, 0)

			if C["Raid"].AuraWatchTexture then
				local Texture = Icon:CreateTexture(nil, "OVERLAY")
				Texture:SetInside(Icon)
				Texture:SetTexture(C["Media"].Blank)

				if (spell[3]) then
					Texture:SetVertexColor(unpack(spell[3]))
				else
					Texture:SetVertexColor(0.8, 0.8, 0.8)
				end
			end

			local Count = Icon:CreateFontString(nil, "OVERLAY")
			Count:SetFont(C["Media"].Font, 8, "THINOUTLINE")
			Count:SetPoint("CENTER", unpack(K.RaidBuffsTrackingPosition[spell[2]]))
			Icon.count = Count

			Auras.icons[spell[1]] = Icon
		end
	end

	frame.AuraWatch = Auras
end

function Module:UpdateNameplateTarget()
	local Nameplate = self
	if not Nameplate then
		return
	end

	local tAM = Nameplate.targetArrowMark
	local tAML = Nameplate.targetArrowMarkLeft
	local tAMR = Nameplate.targetArrowMarkRight
	local tHM = Nameplate.targetHightlightMark

	if UnitIsUnit(Nameplate.unit, "target") and not UnitIsUnit(Nameplate.unit, "player") then
		Nameplate:SetAlpha(1)

		if tHM and (Nameplate.frameType ~= "PLAYER") then
			tHM:Show()
		end

		if tAM and (C["Nameplates"].TargetArrowMark.Value ~= "NONE") and (Nameplate.frameType ~= "PLAYER") then
			tAM:Show()
		end

		if (tAML and tAMR) and (C["Nameplates"].TargetArrowMark.Value == "LEFT/RIGHT") and (Nameplate.frameType ~= "PLAYER") then
			tAML:Show()
			tAMR:Show()
		end
	else
		if UnitExists("target") and not UnitIsUnit(Nameplate.unit, "player") then
			Nameplate:SetAlpha(C["Nameplates"].NonTargetAlpha)

			if tAM then tAM:Hide() end
			if tAML then tAML:Hide() end
			if tAMR then tAMR:Hide() end
			if tHM then tHM:Hide() end
		else
			Nameplate:SetAlpha(1)

			if tAM then tAM:Hide() end
			if tAML then tAML:Hide() end
			if tAMR then tAMR:Hide() end
			if tHM then tHM:Hide() end
		end
	end
end

function Module:UpdatePlateCastbarInterrupt(...)
	local _, eventType, _, sourceGUID, sourceName, _, _, destGUID = ...
	if eventType == "SPELL_INTERRUPT" and destGUID and sourceName and sourceName ~= "" then
		local nameplate = Module.guidToPlate[destGUID]
		if nameplate and nameplate.Castbar then
			local _, class = GetPlayerInfoByGUID(sourceGUID)
			local r, g, b = K.ColorClass(class)
			local color = K.RGBToHex(r, g, b)
			local sourceName = Ambiguate(sourceName, "short")
			nameplate.Castbar.Text:SetText(INTERRUPTED.." > "..color..sourceName)
			nameplate.Castbar.Time:SetText("")
		end
	end
end

function Module:AddPlateInterruptInfo()
	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.UpdatePlateCastbarInterrupt)
end

function Module:NameplatesCallback(nameplate, event, unit)
	if not nameplate then
		return
	end

	if event == "NAME_PLATE_UNIT_ADDED" then
		unit = unit or nameplate.unit

		nameplate.unitName = UnitName(unit)
		nameplate.unitGUID = UnitGUID(unit)
		if nameplate.unitGUID then
			Module.guidToPlate[nameplate.unitGUID] = nameplate
		end
		nameplate.npcID = K.GetNPCID(nameplate.unitGUID)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		if nameplate.unitGUID then
			Module.guidToPlate[nameplate.unitGUID] = nil
		end
	end

	Module.UpdateQuestIndicator(nameplate)
	Module.UpdateNameplateTarget(nameplate)
	Module.UpdateUnitClassify(nameplate, unit)
end

function Module:GetPartyFramesAttributes()
	local PartyProperties = "custom [@raid6,exists] hide;show"

	return "oUF_Party", nil, PartyProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],

	"initial-width", 164,
	"initial-height", 34,
	"showSolo", false,
	"showParty", true,
	"showPlayer", C["Party"].ShowPlayer,
	"showRaid", true,
	"groupFilter", "1,2,3,4,5,6,7,8",
	"groupingOrder", "1,2,3,4,5,6,7,8",
	"groupBy", "GROUP",
	"yOffset", C["Party"].ShowBuffs and -52 or -18
end

function Module:GetPartyPetFramesAttributes()
	return "oUF_Party_Pet", "SecureGroupPetHeaderTemplate", "custom [@raid6,exists] hide;show",
		"oUF-initialConfigFunction", [[
			local header = self:GetParent()
			self:SetWidth(header:GetAttribute("initial-width"))
			self:SetHeight(header:GetAttribute("initial-height"))
		]],
		"initial-width", 180,
		"initial-height", 24,
		"showSolo", false,
		"showParty", true,
		"showPlayer", C["Party"].ShowPlayer,
		"showRaid", true,
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"groupBy", "GROUP",
		"yOffset", -50
end

function Module:GetDamageRaidFramesAttributes()
	local DamageRaidProperties = C["Party"].Enable and "custom [@raid6,exists] show;hide" or "solo,party,raid"

	return "oUF_Raid_Damage", nil, DamageRaidProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],

	"initial-width", C["Raid"].Width,
	"initial-height", C["Raid"].Height,
	"showParty", true,
	"showRaid", true,
	"showPlayer", true,
	"showSolo", false,
	"xoffset", 6,
	"yOffset", -6,
	"point", "TOP",
	"groupFilter", "1,2,3,4,5,6,7,8",
	"groupingOrder", "1,2,3,4,5,6,7,8",
	"groupBy", C["Raid"].GroupBy.Value,
	"maxColumns", math_ceil(40 / 5),
	"unitsPerColumn", C["Raid"].MaxUnitPerColumn,
	"columnSpacing", 6,
	"columnAnchorPoint", "LEFT"
end

function Module:GetHealerRaidFramesAttributes()
	local HealerRaidProperties = C["Party"].Enable and "custom [@raid6,exists] show;hide" or "solo,party,raid"

	return "oUF_Raid_Healer", nil, HealerRaidProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],

	"initial-width", C["Raid"].Width,
	"initial-height", C["Raid"].Height,
	"showParty", true,
	"showRaid", true,
	"showPlayer", true,
	"showSolo", false,
	"xoffset", 6,
	"yOffset", -6,
	"point", "LEFT",
	"groupFilter", "1,2,3,4,5,6,7,8",
	"groupingOrder", "1,2,3,4,5,6,7,8",
	"groupBy", C["Raid"].GroupBy.Value,
	"maxColumns", math_ceil(40 / 5),
	"unitsPerColumn", C["Raid"].MaxUnitPerColumn,
	"columnSpacing", 6,
	"columnAnchorPoint", "BOTTOM"
end

function Module:GetMainTankAttributes()
	local MainTankProperties = "raid"

	return "oUF_MainTank", nil, MainTankProperties,
	"oUF-initialConfigFunction", [[
	self:SetWidth(76)
	self:SetHeight(40)
	]],

	"showRaid", true,
	"yOffset", -8,
	"groupFilter", "MAINTANK",
	"template", "oUF_MainTank"
end

function Module:CreateStyle(unit)
	if (not unit) then
		return
	end

	local Parent = self:GetParent():GetName()

	if (unit == "player") then
		Module.CreatePlayer(self)
	elseif (unit == "target") then
		Module.CreateTarget(self)
	elseif (unit == "targettarget") then
		Module.CreateTargetOfTarget(self)
	elseif (unit == "pet") then
		Module.CreatePet(self)
	elseif (unit:find("raid")) or (unit:find("maintank")) then
		if Parent:match("Party") then
			Module.CreateParty(self)
		else
			Module.CreateRaid(self)
		end
	elseif unit:match("nameplate") then
		Module.CreateNameplates(self, unit)
	end

	return self
end

function Module:CreateUnits()
	if C["Unitframe"].Enable then
		local Player = oUF:Spawn("player")
		Player:SetPoint("BOTTOM", UIParent, "BOTTOM", -290, 320)
		Player:SetSize(210, 48)

		local Target = oUF:Spawn("target")
		Target:SetPoint("BOTTOM", UIParent, "BOTTOM", 290, 320)
		Target:SetSize(210, 48)

		if not C["Unitframe"].HideTargetofTarget then
			local TargetOfTarget = oUF:Spawn("targettarget")
			TargetOfTarget:SetPoint("TOPLEFT", Target, "BOTTOMRIGHT", -48, -6)
			TargetOfTarget:SetSize(116, 28)
			K.Mover(TargetOfTarget, "TargetOfTarget", "TargetOfTarget", {"TOPLEFT", Target, "BOTTOMRIGHT", -48, -6}, 116, 28)

			self.Units.TargetOfTarget = TargetOfTarget
		end

		local Pet = oUF:Spawn("pet")
		if C["Unitframe"].CombatFade and Player and not InCombatLockdown() then
			Pet:SetParent(Player)
		end
		Pet:SetPoint("TOPRIGHT", Player, "BOTTOMLEFT", 48, -6)
		Pet:SetSize(116, 28)

		self.Units.Player = Player
		self.Units.Target = Target
		self.Units.Pet = Pet

		if C["Party"].Enable then
			local Party = oUF:SpawnHeader(Module:GetPartyFramesAttributes())
			Party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -180)
			Module.Headers.Party = Party

			K.Mover(Party, "Party", "Party", {"TOPLEFT", UIParent, "TOPLEFT", 4, -180}, 164, 38)

			local testShowPartyPets = false
			if testShowPartyPets then
				local PartyPet = oUF:SpawnHeader(Module:GetPartyPetFramesAttributes())
				PartyPet:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 28, -28)

				Module.Headers.PartyPet = Pet

				K.Mover(Pet, "PartyPet", "PartyPet", {"TOPLEFT", UIParent, "TOPLEFT", 28, -28})
			end

		end

		if C["Raid"].Enable then
			local DamageRaid = oUF:SpawnHeader(Module:GetDamageRaidFramesAttributes())
			local HealerRaid = oUF:SpawnHeader(Module:GetHealerRaidFramesAttributes())
			local MainTankRaid = oUF:SpawnHeader(Module:GetMainTankAttributes())

			if C["Raid"].RaidLayout.Value == "Healer" then
				HealerRaid:SetPoint("TOPLEFT", "oUF_Player", "BOTTOMRIGHT", 8, 48)

				Module.Headers.Raid = HealerRaid

				K.Mover(HealerRaid, "HealRaid", "HealRaid", {"TOPLEFT", "oUF_Player", "BOTTOMRIGHT", 8, 48}, C["Raid"].Width, C["Raid"].Height)
			elseif C["Raid"].RaidLayout.Value == "Damage" then
				DamageRaid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -60)

				Module.Headers.Raid = DamageRaid

				K.Mover(DamageRaid, "DpsRaid", "DpsRaid", {"TOPLEFT", UIParent, "TOPLEFT", 4, -60}, C["Raid"].Width, C["Raid"].Height)
			end

			if C["Raid"].MainTankFrames then
				MainTankRaid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
				K.Mover(MainTankRaid, "MainTank", "MainTank", {"TOPLEFT", UIParent, "TOPLEFT", 6, -6}, 76, 40)
			end
		end

		K.Mover(Player, "Player", "Player", {"BOTTOM", UIParent, "BOTTOM", -290, 320}, 210, 50)
		K.Mover(Target, "Target", "Target", {"BOTTOM", UIParent, "BOTTOM", 290, 320}, 210, 50)
		K.Mover(Pet, "Pet", "Pet", {"TOPRIGHT", Player, "BOTTOMLEFT", 48, -6}, 116, 28)
	end

	if C["Nameplates"].Enable then
		oUF:SpawnNamePlates(" ", function(nameplate, event, unit)
			Module:NameplatesCallback(nameplate, event, unit)
		end)
	end
end

function Module:SetNameplateCVars()
	if InCombatLockdown() then
		return
	end

	if C["Nameplates"].Clamp then
		SetCVar("nameplateOtherBottomInset", 0.08)
		SetCVar("nameplateOtherTopInset", 0.05)
	else
		SetCVar("nameplateOtherBottomInset", -1)
		SetCVar("nameplateOtherTopInset", -1)
	end

	SetCVar("namePlateMaxScale", 1)
	SetCVar("namePlateMinScale", 1)
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateMaxAlpha", GetCVarDefault("nameplateMaxAlpha"))
	SetCVar("nameplateMaxDistance", GetCVarDefault("nameplateMaxDistance"))
	SetCVar("nameplateMinAlpha", GetCVarDefault("nameplateMinAlpha"))
	SetCVar("nameplateOverlapH", 0.8)
	SetCVar("nameplateOverlapV", 0.7)
	SetCVar("nameplateSelectedAlpha", 1)
	SetCVar("nameplateSelectedScale", C["Nameplates"].SelectedScale or 1)
end

function Module:NameplatesVarsReset()
	if InCombatLockdown() then
		return
		K.Print(_G.ERR_NOT_IN_COMBAT)
	end

	SetCVar("namePlateHorizontalScale", GetCVarDefault("NamePlateHorizontalScale"))
	SetCVar("nameplateClassResourceTopInset", GetCVarDefault("nameplateClassResourceTopInset"))
	SetCVar("nameplateGlobalScale", GetCVarDefault("nameplateGlobalScale"))
	SetCVar("nameplateLargeBottomInset", GetCVarDefault("nameplateLargeBottomInset"))
	SetCVar("nameplateLargeTopInset", GetCVarDefault("nameplateLargeTopInset"))
	SetCVar("nameplateLargerScale", 1)
	SetCVar("nameplateMaxAlpha", GetCVarDefault("nameplateMaxAlpha"))
	SetCVar("nameplateMaxAlphaDistance", 40)
	SetCVar("nameplateMaxScale", 1)
	SetCVar("nameplateMaxScaleDistance", GetCVarDefault("nameplateMaxScaleDistance"))
	SetCVar("nameplateMinAlpha", 1)
	SetCVar("nameplateMinAlphaDistance", 0)
	SetCVar("nameplateMinScale", 1)
	SetCVar("nameplateMinScaleDistance", GetCVarDefault("nameplateMinScaleDistance"))
	SetCVar("nameplateMotionSpeed", GetCVarDefault("nameplateMotionSpeed"))
	SetCVar("nameplateOccludedAlphaMult", GetCVarDefault("nameplateOccludedAlphaMult"))
	SetCVar("nameplateOtherAtBase", GetCVarDefault("nameplateOtherAtBase"))
	SetCVar("nameplateOverlapH", GetCVarDefault("nameplateOverlapH"))
	SetCVar("nameplateOverlapV", GetCVarDefault("nameplateOverlapV"))
	SetCVar("nameplateResourceOnTarget", GetCVarDefault("nameplateResourceOnTarget"))
	SetCVar("nameplateSelectedAlpha", GetCVarDefault("nameplateSelectedAlpha"))
	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateSelfAlpha", GetCVarDefault("nameplateSelfAlpha"))
	SetCVar("nameplateSelfBottomInset", GetCVarDefault("nameplateSelfBottomInset"))
	SetCVar("nameplateSelfScale", GetCVarDefault("nameplateSelfScale"))
	SetCVar("nameplateSelfTopInset", GetCVarDefault("nameplateSelfTopInset"))
	SetCVar("nameplateShowEnemies", GetCVarDefault("nameplateShowEnemies"))
	SetCVar("nameplateShowEnemyGuardians", GetCVarDefault("nameplateShowEnemyGuardians"))
	SetCVar("nameplateShowEnemyPets", GetCVarDefault("nameplateShowEnemyPets"))
	SetCVar("nameplateShowEnemyTotems", GetCVarDefault("nameplateShowEnemyTotems"))
	SetCVar("nameplateShowFriendlyGuardians", GetCVarDefault("nameplateShowFriendlyGuardians"))
	SetCVar("nameplateShowFriendlyNPCs", GetCVarDefault("nameplateShowFriendlyNPCs"))
	SetCVar("nameplateShowFriendlyPets", GetCVarDefault("nameplateShowFriendlyPets"))
	SetCVar("nameplateShowFriendlyTotems", GetCVarDefault("nameplateShowFriendlyTotems"))
	SetCVar("nameplateShowFriends", GetCVarDefault("nameplateShowFriends"))
	SetCVar("nameplateTargetBehindMaxDistance", GetCVarDefault("nameplateTargetBehindMaxDistance"))

	K.Print(_G.RESET_TO_DEFAULT.." ".._G.UNIT_NAMEPLATES)

	K.StaticPopup_Show("CHANGES_RL")
end

function Module:CreateFilgerAnchors()
	if C["Filger"].Enable and C["Unitframe"].Enable then
		P_BUFF_ICON_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 169)
		P_BUFF_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		P_PROC_ICON_Anchor:SetPoint("BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 169)
		P_PROC_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		SPECIAL_P_BUFF_ICON_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 211)
		SPECIAL_P_BUFF_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		T_DEBUFF_ICON_Anchor:SetPoint("BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 211)
		T_DEBUFF_ICON_Anchor:SetSize(C["Filger"].BuffSize, C["Filger"].BuffSize)

		T_BUFF_Anchor:SetPoint("BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 253)
		T_BUFF_Anchor:SetSize(C["Filger"].PvPSize, C["Filger"].PvPSize)

		PVE_PVP_DEBUFF_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 253)
		PVE_PVP_DEBUFF_Anchor:SetSize(C["Filger"].PvPSize, C["Filger"].PvPSize)

		PVE_PVP_CC_Anchor:SetPoint("TOPLEFT", "oUF_Player", "BOTTOMLEFT", -2, -44)
		PVE_PVP_CC_Anchor:SetSize(221, 25)

		COOLDOWN_Anchor:SetPoint("BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 63, 17)
		COOLDOWN_Anchor:SetSize(C["Filger"].CooldownSize, C["Filger"].CooldownSize)

		T_DE_BUFF_BAR_Anchor:SetPoint("TOPLEFT", "oUF_Target", "BOTTOMRIGHT", 6, 25)
		T_DE_BUFF_BAR_Anchor:SetSize(218, 25)

		K.Mover(P_BUFF_ICON_Anchor, "P_BUFF_ICON", "P_BUFF_ICON", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 169})
		K.Mover(P_PROC_ICON_Anchor, "P_PROC_ICON", "P_PROC_ICON", {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 169})
		K.Mover(SPECIAL_P_BUFF_ICON_Anchor, "SPECIAL_P_BUFF_ICON", "SPECIAL_P_BUFF_ICON", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 211})
		K.Mover(T_DEBUFF_ICON_Anchor, "T_DEBUFF_ICON", "T_DEBUFF_ICON", {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 211})
		K.Mover(T_BUFF_Anchor, "T_BUFF", "T_BUFF", {"BOTTOMLEFT", "oUF_Target", "TOPLEFT", -2, 253})
		K.Mover(PVE_PVP_DEBUFF_Anchor, "PVE_PVP_DEBUFF", "PVE_PVP_DEBUFF", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 2, 253})
		K.Mover(PVE_PVP_CC_Anchor, "PVE_PVP_CC", "PVE_PVP_CC", {"TOPLEFT", "oUF_Player", "BOTTOMLEFT", -2, -44})
		K.Mover(COOLDOWN_Anchor, "COOLDOWN", "COOLDOWN", {"BOTTOMRIGHT", "oUF_Player", "TOPRIGHT", 63, 17})
		K.Mover(T_DE_BUFF_BAR_Anchor, "T_DE_BUFF_BAR", "T_DE_BUFF_BAR", {"TOPLEFT", "oUF_Target", "BOTTOMRIGHT", 6, 25})
	end
end

function Module.PLAYER_REGEN_DISABLED()
	if (C["Nameplates"].ShowFriendlyCombat.Value == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 1)
	elseif (C["Nameplates"].ShowFriendlyCombat.Value == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 0)
	end

	if (C["Nameplates"].ShowEnemyCombat.Value == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 1)
	elseif (C["Nameplates"].ShowEnemyCombat.Value == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 0)
	end
end

function Module.PLAYER_REGEN_ENABLED()
	if (C["Nameplates"].ShowFriendlyCombat.Value == "TOGGLE_ON") then
		SetCVar("nameplateShowFriends", 0)
	elseif (C["Nameplates"].ShowFriendlyCombat.Value == "TOGGLE_OFF") then
		SetCVar("nameplateShowFriends", 1)
	end

	if (C["Nameplates"].ShowEnemyCombat.Value == "TOGGLE_ON") then
		SetCVar("nameplateShowEnemies", 0)
	elseif (C["Nameplates"].ShowEnemyCombat.Value == "TOGGLE_OFF") then
		SetCVar("nameplateShowEnemies", 1)
	end
end

function Module:UpdateRaidDebuffIndicator()
	local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs

	if (ORD) then
		local _, InstanceType = IsInInstance()

		if (ORD.RegisteredList ~= "RD") and (InstanceType == "party" or InstanceType == "raid") then
			ORD:ResetDebuffData()
			ORD:RegisterDebuffs(K.DebuffsTracking.RaidDebuffs.spells)
			ORD.RegisteredList = "RD"
		else
			if ORD.RegisteredList ~= "CC" then
				ORD:ResetDebuffData()
				ORD:RegisterDebuffs(K.DebuffsTracking.CCDebuffs.spells)
				ORD.RegisteredList = "CC"
			end
		end
	end
end

local function CreateTargetSound(unit)
	if UnitExists(unit) then
		if UnitIsEnemy(unit, "player") then
			PlaySound(SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
		elseif UnitIsFriend("player", unit) then
			PlaySound(SOUNDKIT.IG_CHARACTER_NPC_SELECT)
		else
			PlaySound(SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
		end
	else
		PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

function Module.PLAYER_FOCUS_CHANGED()
	CreateTargetSound("focus")
end

function Module.PLAYER_TARGET_CHANGED()
	CreateTargetSound("target")
end

local announcedPVP
function Module.UNIT_FACTION(_, unit)
	if (unit ~= "player") then
		return
	end

	if UnitIsPVPFreeForAll("player") or UnitIsPVP("player") then
		if not announcedPVP then
			announcedPVP = true
			PlaySound(SOUNDKIT.IG_PVP_UPDATE)
		end
	else
		announcedPVP = nil
	end
end

local function HideRaid()
	if InCombatLockdown() then
		return
	end

	_G.CompactRaidFrameManager:Kill()
	local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
	if compact_raid and compact_raid ~= "0" then
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
end

function Module.DisableBlizzardCompactRaid()
	if not CompactRaidFrameManager_UpdateShown then
		K.StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
	else
		if not _G.CompactRaidFrameManager.hookedHide then
			hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideRaid)
			_G.CompactRaidFrameManager:HookScript("OnShow", HideRaid)
			_G.CompactRaidFrameManager.hookedHide = true
		end
		CompactRaidFrameContainer:UnregisterAllEvents()

		HideRaid()
	end
end

function Module:OnEnable()
	Module.Backdrop = {
		bgFile = C["Media"].Blank,
		insets = {top = -1, left = -1, bottom = -1, right = -1}
	}

	oUF:RegisterStyle(" ", Module.CreateStyle)
	oUF:SetActiveStyle(" ")

	self.PlateGUID = {}
	self:CreateUnits()
	self:CreateFilgerAnchors()

	if C["Party"].Enable or C["Raid"].Enable then
		Module:DisableBlizzardCompactRaid()

		K:RegisterEvent("GROUP_ROSTER_UPDATE", Module.DisableBlizzardCompactRaid)
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE") -- This may fuck shit up.. we'll see...
	else
		CompactUnitFrameProfiles:RegisterEvent("VARIABLES_LOADED")
	end

	if C["Raid"].AuraWatch then
		local RaidDebuffs = CreateFrame("Frame")
		RaidDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
		RaidDebuffs:SetScript("OnEvent", self.UpdateRaidDebuffIndicator)

		local ORD = oUF_RaidDebuffs or K.oUF_RaidDebuffs
		if (ORD) then
			ORD.ShowDispellableDebuff = true
			ORD.FilterDispellableDebuff = true
			ORD.MatchBySpellName = false
		end
	end

	if C["Nameplates"].Enable then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED)
		K:RegisterEvent("PLAYER_REGEN_DISABLED", self.PLAYER_REGEN_DISABLED)
		self:PLAYER_REGEN_ENABLED()
		self:SetNameplateCVars()
		self:AddPlateInterruptInfo()
		self:QuestIconCheck()
	end

	if C["Unitframe"].Enable then
		K.HideInterfaceOption(InterfaceOptionsCombatPanelTargetOfTarget)
		K:RegisterEvent("PLAYER_TARGET_CHANGED", self.PLAYER_TARGET_CHANGED)
		K:RegisterEvent("UNIT_FACTION", self.UNIT_FACTION)
	end
end