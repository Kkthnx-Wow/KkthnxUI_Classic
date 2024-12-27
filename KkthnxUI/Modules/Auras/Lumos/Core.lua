local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Auras")

function Module:GetUnitAura(unit, spell, filter)
	for index = 1, 32 do
		local auraData = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
		if not auraData then
			break
		end
		if auraData.spellId == spell then
			return auraData.name, auraData.applications, auraData.duration, auraData.expirationTime, auraData.sourceUnit, auraData.spellId, auraData.points[1]
		end
	end
end

function Module:UpdateCooldown(button, spellID, texture)
	local chargeInfo = C_Spell.GetSpellCharges(spellID)
	local charges = chargeInfo and chargeInfo.currentCharges
	local maxCharges = chargeInfo and chargeInfo.maxCharges
	local chargeStart = chargeInfo and chargeInfo.cooldownStartTime
	local chargeDuration = chargeInfo and chargeInfo.cooldownDuration

	local cooldownInfo = C_Spell.GetSpellCooldown(spellID)
	local start = cooldownInfo and cooldownInfo.startTime
	local duration = cooldownInfo and cooldownInfo.duration

	if charges and maxCharges > 1 then
		button.Count:SetText(charges)
	else
		button.Count:SetText("")
	end
	if charges and charges > 0 and charges < maxCharges then
		button.CD:SetCooldown(chargeStart, chargeDuration)
		button.CD:Show()
		button.Icon:SetDesaturated(false)
		button.Count:SetTextColor(0, 1, 0)
	elseif start and duration > 1.5 then
		button.CD:SetCooldown(start, duration)
		button.CD:Show()
		button.Icon:SetDesaturated(true)
		button.Count:SetTextColor(1, 1, 1)
	else
		button.CD:Hide()
		button.Icon:SetDesaturated(false)
		if charges == maxCharges then
			button.Count:SetTextColor(1, 0, 0)
		end
	end

	if texture then
		button.Icon:SetTexture(C_Spell.GetSpellTexture(spellID))
	end
end

function Module:GlowOnEnd()
	local elapsed = self.expire - GetTime()
	if elapsed < 3 then
		K.ShowOverlayGlow(self.glowFrame)
	else
		K.HideOverlayGlow(self.glowFrame)
	end
end

function Module:UpdateAura(button, unit, auraID, filter, spellID, cooldown, glow)
	button.Icon:SetTexture(C_Spell.GetSpellTexture(spellID))
	local name, count, duration, expire, caster = self:GetUnitAura(unit, auraID, filter)
	if name and caster == "player" then
		if button.Count then
			if count == 0 then
				count = ""
			end
			button.Count:SetText(count)
		end
		button.CD:SetCooldown(expire - duration, duration)
		button.CD:Show()
		button.Icon:SetDesaturated(false)
		if glow then
			if glow == "END" then
				button.expire = expire
				button:SetScript("OnUpdate", Module.GlowOnEnd)
			else
				K.ShowOverlayGlow(button.glowFrame)
			end
		end
	else
		if cooldown then
			self:UpdateCooldown(button, spellID)
		else
			if button.Count then
				button.Count:SetText("")
			end
			button.CD:Hide()
			button.Icon:SetDesaturated(true)
		end
		if glow then
			button:SetScript("OnUpdate", nil)
			K.HideOverlayGlow(button.glowFrame)
		end
	end
end

function Module:UpdateTotemAura(button, texture, spellID, glow)
	button.Icon:SetTexture(texture)
	local found
	for slot = 1, 4 do
		local haveTotem, _, start, dur, icon = GetTotemInfo(slot)
		if haveTotem and icon == texture and (start + dur - GetTime() > 0) then
			button.CD:SetCooldown(start, dur)
			button.CD:Show()
			button.Icon:SetDesaturated(false)
			button.Count:SetText("")
			if glow then
				if glow == "END" then
					button.expire = start + dur
					button:SetScript("OnUpdate", Module.GlowOnEnd)
				else
					K.ShowOverlayGlow(button.glowFrame)
				end
			end
			found = true
			break
		end
	end
	if not found then
		if spellID then
			self:UpdateCooldown(button, spellID)
		else
			button.CD:Hide()
			button.Icon:SetDesaturated(true)
		end
		if glow then
			button:SetScript("OnUpdate", nil)
			K.HideOverlayGlow(button.glowFrame)
		end
	end
end

local function UpdateVisibility(self)
	if InCombatLockdown() or self.lumos.onFire then
		return
	end

	for i = 1, 5 do
		local bu = self.lumos[i]
		bu.Count:SetTextColor(1, 1, 1)
		bu.Count:SetText("")
		bu.CD:Hide()
		bu:SetScript("OnUpdate", nil)
		bu.Icon:SetDesaturated(true)
		K.HideOverlayGlow(bu.glowFrame)
	end
	if Module.PostUpdateVisibility then
		Module:PostUpdateVisibility(self)
	end
end

local lumosUnits = {
	["player"] = true,
	["target"] = true,
}
local function UpdateIcons(self, event, unit)
	if event == "UNIT_AURA" and not lumosUnits[unit] then
		return
	end
	Module:ChantLumos(self)
	UpdateVisibility(self)
end

local function TurnOn(self)
	self:RegisterEvent("UNIT_AURA", UpdateIcons)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateIcons, true)
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", UpdateIcons, true)
	self:RegisterEvent("SPELL_UPDATE_CHARGES", UpdateIcons, true)
end

local function TurnOff(self)
	self:UnregisterEvent("UNIT_AURA", UpdateIcons)
	self:UnregisterEvent("PLAYER_TARGET_CHANGED", UpdateIcons)
	self:UnregisterEvent("SPELL_UPDATE_COOLDOWN", UpdateIcons)
	self:UnregisterEvent("SPELL_UPDATE_CHARGES", UpdateIcons)
	UpdateVisibility(self)
end

local function OnTalentUpdate(self, event)
	UpdateIcons(self, event)
	if self.lumos.onFire then
		if Module.PostUpdateVisibility then
			Module:PostUpdateVisibility(self)
		end
	end
end

function Module:CreateLumos(self)
	if not Module.ChantLumos then
		return
	end

	self.lumos = {}
	self.lumos.onFire = C["Nameplate"].PPOnFire

	-- local iconSize = (C["Nameplate"].PPWidth + 2 * K.Mult - 3 * 4) / 5
	local iconSize = self.iconSize
	for i = 1, 5 do
		local bu = CreateFrame("Frame", nil, self.Health)
		bu:SetSize(iconSize, iconSize)

		bu.CD = CreateFrame("Cooldown", nil, bu, "CooldownFrameTemplate")
		bu.CD:SetAllPoints()
		bu.CD:SetReverse(true)

		bu.Icon = bu:CreateTexture(nil, "ARTWORK")
		bu.Icon:SetAllPoints()
		bu.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		bu:CreateShadow(true)

		bu.glowFrame = K.CreateGlowFrame(bu, iconSize)

		local fontParent = CreateFrame("Frame", nil, bu)
		fontParent:SetAllPoints()
		fontParent:SetFrameLevel(bu:GetFrameLevel() + 6)
		bu.Count = K.CreateFontString(fontParent, 16, "", "", false, "BOTTOM", 0, -10)
		if i == 1 then
			bu:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", -0, -5)
		else
			bu:SetPoint("LEFT", self.lumos[i - 1], "RIGHT", 2, 0)
		end

		self.lumos[i] = bu
	end

	if Module.PostCreateLumos then
		Module:PostCreateLumos(self)
	end

	UpdateIcons(self)
	if self.lumos.onFire then
		TurnOn(self)
	else
		self:RegisterEvent("PLAYER_REGEN_ENABLED", TurnOff, true)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", TurnOn, true)
	end
	self:RegisterEvent("PLAYER_TALENT_UPDATE", OnTalentUpdate, true)
end
