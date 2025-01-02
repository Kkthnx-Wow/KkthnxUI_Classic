local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

local keyButton = gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = gsub(KEY_NUMPAD1, "%d", "")

local replaces = {
	{ "(" .. keyButton .. ")", "M" },
	{ "(" .. keyNumpad .. ")", "N" },
	{ "(a%-)", "a" },
	{ "(c%-)", "c" },
	{ "(s%-)", "s" },
	{ KEY_BUTTON3, "M3" },
	{ KEY_MOUSEWHEELUP, "MU" },
	{ KEY_MOUSEWHEELDOWN, "MD" },
	{ KEY_SPACE, "Sp" },
	{ "CAPSLOCK", "CL" },
	{ "Capslock", "CL" },
	{ "BUTTON", "M" },
	{ "NUMPAD", "N" },
	{ "(META%-)", "m" },
	{ "(Meta%-)", "m" },
	{ "(ALT%-)", "a" },
	{ "(CTRL%-)", "c" },
	{ "(SHIFT%-)", "s" },
	{ "MOUSEWHEELUP", "MU" },
	{ "MOUSEWHEELDOWN", "MD" },
	{ "SPACE", "Sp" },
}

function Module:UpdateHotKey()
	local text = self:GetText()
	if not text then
		return
	end

	if text == RANGE_INDICATOR then
		text = ""
	else
		for _, value in pairs(replaces) do
			text = gsub(text, value[1], value[2])
		end
	end
	self:SetFormattedText("%s", text)
end

function Module:UpdateBarBorderColor(button)
	if not button.__bg then
		return
	end

	if button.Border:IsShown() then
		button.__bg.KKUI_Border:SetVertexColor(0, 0.7, 0.1)
	else
		K.SetBorderColor(button.__bg.KKUI_Border)
	end
end

local function OverrideNormalTextureAndAtlas(self, texture)
	if texture and texture ~= 0 then
		self:SetNormalTexture(0)
	end
end

function Module:StyleActionButton(button)
	if not button then
		return
	end

	if button.__styled then
		return
	end

	local buttonName = button:GetName()
	local icon = button.icon or _G[buttonName .. "Icon"]
	local cooldown = button.cooldown or _G[buttonName .. "Cooldown"]
	local hotkey = button.HotKey
	local count = button.Count
	local name = button.Name or _G[buttonName .. "Name"]
	local flash = button.Flash or _G[buttonName .. "Flash"]
	local border = button.Border or _G[buttonName .. "Border"]
	local normal = button.GetNormalTexture and button:GetNormalTexture()
	local slotbg = button.SlotBackground or _G[buttonName .. "FloatingBG"]
	local pushed = button.PushedTexture or button:GetPushedTexture()
	local checked = button.CheckedTexture or button:GetCheckedTexture()
	local highlight = button.HighlightTexture or button:GetHighlightTexture()
	local newActionTexture = button.NewActionTexture
	local spellHighlight = button.SpellHighlightTexture
	local iconMask = button.IconMask
	local petShine = _G[buttonName .. "Shine"]
	local autoCastable = button.AutoCastable or _G[buttonName .. "AutoCastable"]

	if normal then
		normal:SetTexture(0)
		-- Hook the function to both SetNormalTexture and SetNormalAtlas methods
		hooksecurefunc(button, "SetNormalTexture", OverrideNormalTextureAndAtlas)
		hooksecurefunc(button, "SetNormalAtlas", OverrideNormalTextureAndAtlas)
	end

	if flash then
		flash:SetColorTexture(220 / 255, 68 / 255, 54 / 255, 0.65 / 255)
		flash:SetAllPoints()
	end

	if newActionTexture then
		newActionTexture:SetDrawLayer("OVERLAY", 2)
		newActionTexture:ClearAllPoints()
		newActionTexture:SetPoint("TOPLEFT", -5, 5)
		newActionTexture:SetPoint("BOTTOMRIGHT", 5, -5)
	end

	if border then
		border:SetTexture(nil)
	end

	if slotbg then
		slotbg:Hide()
		slotbg:SetAlpha(0)
	end

	if iconMask then
		iconMask:Hide()
	end

	if button.style then
		button.style:SetAlpha(0)
	end

	if petShine then
		petShine:ClearAllPoints()
		petShine:SetPoint("TOPLEFT", 1, -1)
		petShine:SetPoint("BOTTOMRIGHT", -1, 1)
	end

	if autoCastable then
		autoCastable:SetDrawLayer("OVERLAY", 2)
		autoCastable:ClearAllPoints()
		autoCastable:SetPoint("TOPLEFT", -12, 12)
		autoCastable:SetPoint("BOTTOMRIGHT", 12, -12)
	end

	if icon then
		icon:SetAllPoints()
		if not icon.__lockdown then
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		end

		if not button.__bgCreated then
			button.__bg = CreateFrame("Frame", nil, button, "BackdropTemplate")
			button.__bg:SetAllPoints(button)
			button.__bg:SetFrameLevel(button:GetFrameLevel())
			button.__bg:CreateBorder(nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Slot-Background", nil, nil, nil, { 1, 1, 1 })
			button.__bgCreated = true
		end
	end

	if cooldown then
		cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	end

	if pushed then
		button:SetPushedTexture("Interface\\Buttons\\CheckButtonHilight")
		button:GetPushedTexture():SetBlendMode("ADD")
		button:GetPushedTexture():SetAllPoints()
	end

	if checked then
		button:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight")
		button:GetCheckedTexture():SetBlendMode("ADD")
		button:GetCheckedTexture():SetAllPoints()
	end

	if highlight then
		button:SetHighlightTexture(button:IsObjectType("CheckButton") and "Interface\\Buttons\\CheckButtonHilight" or "Interface\\Buttons\\ButtonHilight-Square")
		button:GetHighlightTexture():SetBlendMode("ADD")
		button:GetHighlightTexture():SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
		button:GetHighlightTexture():SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
	end

	if spellHighlight then
		spellHighlight:SetDrawLayer("OVERLAY", 2)
		spellHighlight:ClearAllPoints()
		spellHighlight:SetPoint("TOPLEFT", -5, 5)
		spellHighlight:SetPoint("BOTTOMRIGHT", 5, -5)
	end

	if hotkey then
		Module.UpdateHotKey(hotkey)
		hooksecurefunc(hotkey, "SetText", Module.UpdateHotKey)
	end

	button.__styled = true
end

function Module:ReskinBars()
	for i = 1, 8 do
		for j = 1, 12 do
			Module:StyleActionButton(_G["KKUI_ActionBar" .. i .. "Button" .. j])
		end
	end

	-- petbar buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		Module:StyleActionButton(_G["PetActionButton" .. i])
	end

	-- stancebar buttons
	for i = 1, 10 do
		Module:StyleActionButton(_G["StanceButton" .. i])
	end

	-- leave vehicle
	Module:StyleActionButton(_G["KKUI_LeaveVehicleButton"])

	-- extra action button
	Module:StyleActionButton(ExtraActionButton1)
end
