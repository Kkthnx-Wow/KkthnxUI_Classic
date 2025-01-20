local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

local pairs, sort, tinsert = pairs, sort, tinsert
local GetSpellInfo, GetSpellCooldown, UnitAura = GetSpellInfo, GetSpellCooldown, UnitAura

local aspects = {
	[1] = { spellID = 13165, known = false }, -- 雄鹰
	[2] = { spellID = 415423, known = false }, -- 蝰蛇
	[3] = { spellID = 13163, known = false }, -- 灵猴
	[4] = { spellID = 5118, known = false }, -- 猎豹
	[5] = { spellID = 13159, known = false }, -- 豹群
	[6] = { spellID = 13161, known = false }, -- 野兽
	[7] = { spellID = 20043, known = false }, -- 野性
	[8] = { spellID = 409580, known = false }, -- 雄狮之心
	[9] = { spellID = 469145, known = false }, -- 猎鹰守护
}

local knownAspect = {}
local aspectButtons = {}
local aspectFrame

function Module:IsPlayerSpell(spellID)
	return IsPlayerSpell(spellID) or IsSpellKnownOrOverridesKnown(spellID)
end

function Module:UpdateAspectCooldown()
	local start, duration = GetSpellCooldown(self.spellID)
	if start > 0 and duration > 0 then
		self.CD:SetCooldown(start, duration)
		self.CD:Show()
	else
		self.CD:Hide()
	end
end

function Module:CreateAspectButton(spellID, index)
	local name, _, texture = GetSpellInfo(spellID)
	local size = C["ActionBar"].BarAspectSize

	local button = CreateFrame("Button", "$parentButton" .. index, aspectFrame, "SecureActionButtonTemplate")
	button:SetSize(size, size)
	button:SetAttribute("type", "spell")
	button:SetAttribute("spell", name)
	button:CreateBorder(nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Slot-Background", nil, nil, nil, { 1, 1, 1 })
	button:StyleButton()

	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAllPoints()
	button.Icon:SetTexCoord(unpack(K.TexCoords))
	button.Icon:SetTexture(texture)

	-- Enhanced tooltip
	button:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:SetSpellByID(spellID)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	button.CD = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.CD:SetAllPoints()
	button.CD:SetDrawEdge(false)
	button.spellID = spellID
	button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	button:SetScript("OnEvent", Module.UpdateAspectCooldown)

	button.cover = button:CreateTexture(nil, "ARTWORK", nil, 5)
	button.cover:SetAllPoints()
	button.cover:SetTexCoord(unpack(K.TexCoords))
	button.cover:SetTexture("Interface\\Icons\\Spell_Nature_WispSplode")

	if C["ActionBar"].BarAspectFade then
		if not button.isHooked then
			button:HookScript("OnEnter", Module.Button_OnEnter)
			button:HookScript("OnLeave", Module.Button_OnLeave)
			button.isHooked = true
		end
	else
		if button.isHooked then
			button:SetScript("OnEnter", nil)
			button:SetScript("OnLeave", nil)
			button.isHooked = false
		end
	end

	knownAspect[name] = true
	tinsert(aspectButtons, { button, index, name })
end

local function sortButtons(a, b)
	if a and b then
		return a[2] < b[2]
	end
end

function Module:UpdateAspectAnchor()
	sort(aspectButtons, sortButtons)

	local prevButton
	local growUp = C["ActionBar"].BarAspectGrowUp
	local spacing = 6

	for _, value in pairs(aspectButtons) do
		value[1]:ClearAllPoints()
		if not prevButton then
			-- Anchor the first button to the aspect frame
			if C["ActionBar"].BarAspectVerticle then
				if growUp then
					value[1]:SetPoint("BOTTOMLEFT", aspectFrame, "BOTTOMLEFT", 0, 0)
				else
					value[1]:SetPoint("TOPLEFT", aspectFrame, "TOPLEFT", 0, 0)
				end
			else
				value[1]:SetPoint("TOPLEFT", aspectFrame, "TOPLEFT", 0, 0)
			end
		else
			-- Adjust subsequent buttons based on the layout and growth direction
			if C["ActionBar"].BarAspectVerticle then
				if growUp then
					value[1]:SetPoint("BOTTOM", prevButton, "TOP", 0, spacing)
				else
					value[1]:SetPoint("TOP", prevButton, "BOTTOM", 0, -spacing)
				end
			else
				value[1]:SetPoint("LEFT", prevButton, "RIGHT", spacing, 0)
			end
		end
		prevButton = value[1]
	end
end

function Module:CheckKnownAspects()
	for index, value in pairs(aspects) do
		if not value.known and Module:IsPlayerSpell(value.spellID) then
			Module:CreateAspectButton(value.spellID, index)
			value.known = true
		end
	end

	Module:UpdateAspectAnchor()
end

local foundAspect = {}

function Module:CheckActiveAspect(unit)
	if unit ~= "player" then
		return
	end

	wipe(foundAspect)

	for i = 1, 40 do
		local name, _, _, _, _, _, caster = UnitAura("player", i)
		if not name then
			break
		end
		if knownAspect[name] and caster == "player" then
			foundAspect[name] = true
		end
	end

	for _, value in pairs(aspectButtons) do
		value[1].cover:SetShown(foundAspect[value[3]])
	end
end

function Module:UpdateAspectStatus()
	if not aspectFrame then
		return
	end

	local size = C["ActionBar"].BarAspectSize
	local num = #aspectButtons
	local spacing = 6
	local width, height = size, size * num + spacing * (num - 1)

	-- Adjust frame size based on layout and direction
	if C["ActionBar"].BarAspectVerticle then
		aspectFrame:SetSize(width, height)
		aspectFrame.mover:SetSize(width, height)
	else
		aspectFrame:SetSize(height, width)
		aspectFrame.mover:SetSize(height, width)
	end

	for _, value in pairs(aspectButtons) do
		value[1]:SetSize(size, size)
	end
	Module:UpdateAspectAnchor()
end

function Module:ToggleAspectBar()
	if not aspectFrame then
		return
	end

	if C["ActionBar"].BarAspect then
		Module:CheckKnownAspects()
		K:RegisterEvent("LEARNED_SPELL_IN_TAB", Module.CheckKnownAspects)
		Module:CheckActiveAspect("player")
		K:RegisterEvent("UNIT_AURA", Module.CheckActiveAspect)
		aspectFrame:Show()
	else
		K:UnregisterEvent("LEARNED_SPELL_IN_TAB", Module.CheckKnownAspects)
		K:UnregisterEvent("UNIT_AURA", Module.CheckActiveAspect)
		aspectFrame:Hide()
	end
end

function Module:CreateAspectbar()
	if K.Class ~= "HUNTER" then
		return
	end

	local size = C["ActionBar"].BarAspectSize or 50
	local num = #aspects
	local spacing = 6
	local width, height = size, size * num + spacing * (num - 1)

	aspectFrame = CreateFrame("Frame", "KKUI_ActionBarAspect", UIParent)
	if C["ActionBar"].BarAspectVerticle then
		aspectFrame:SetSize(width, height)
	else
		aspectFrame:SetSize(height, width)
	end
	aspectFrame.mover = K.Mover(aspectFrame, "AspectBar", "AspectBar", { "BOTTOMLEFT", 440, 4 })

	Module:ToggleAspectBar()
end
