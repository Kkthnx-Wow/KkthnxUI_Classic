local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

-- Utility function to create a toggle button
local function CreateToggleButton(parentFrame, name, label, anchorPoint, offsetX, offsetY, onClickCallback)
	local button = CreateFrame("CheckButton", name, parentFrame, "OptionsBaseCheckButtonTemplate")
	button:SetPoint(anchorPoint, offsetX, offsetY)
	button:SetSize(22, 22)
	button:SetFrameStrata("HIGH")
	button:SetAlpha(0.1)

	local buttonText = button:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	buttonText:SetText(label)
	buttonText:SetPoint("LEFT", button, "RIGHT", 4, 0)
	button:SetHitRectInsets(3, -buttonText:GetStringWidth(), 0, 0)

	-- Button highlight fade-in and fade-out effects
	button:HookScript("OnEnter", function(self)
		UIFrameFadeIn(self, 0.1, self:GetAlpha(), 1)
	end)

	button:HookScript("OnLeave", function(self)
		UIFrameFadeOut(self, 1, self:GetAlpha(), 0.1)
	end)

	button:HookScript("OnClick", onClickCallback)

	return button
end

-- Toggle helm visibility
local function ToggleHelmVisibility(self)
	self:Disable()
	self:SetAlpha(1.0)

	C_Timer.After(0.5, function()
		ShowHelm(not ShowingHelm())
		self:Enable()
		if not self:IsMouseOver() then
			self:SetAlpha(0.25)
		end
	end)
end

-- Toggle cloak visibility
local function ToggleCloakVisibility(self)
	self:Disable()
	self:SetAlpha(1.0)

	C_Timer.After(0.5, function()
		ShowCloak(not ShowingCloak())
		self:Enable()
		if not self:IsMouseOver() then
			self:SetAlpha(0.25)
		end
	end)
end

-- Update toggle button states based on helm and cloak visibility
local function UpdateToggleStates(helmButton, cloakButton)
	helmButton:SetChecked(ShowingHelm())
	cloakButton:SetChecked(ShowingCloak())
end

-- Main function to create helm and cloak toggle buttons
function Module:CreateHelmCloakToggle()
	if not C["Misc"].HelmCloakToggle then
		return
	end

	-- Hide default character model rotate buttons
	if CharacterModelFrameRotateLeftButton then
		CharacterModelFrameRotateLeftButton:Hide()
	end

	if CharacterModelFrameRotateRightButton then
		CharacterModelFrameRotateRightButton:Hide()
	end

	-- Create helm and cloak toggle buttons
	local helmButton = CreateToggleButton(CharacterModelFrame, "KKUI_ShowHelmButton", "Helm", "TOPLEFT", 2, -2, ToggleHelmVisibility)
	local cloakButton = CreateToggleButton(CharacterModelFrame, "KKUI_ShowCloakButton", "Cloak", "TOPLEFT", 2, -24, ToggleCloakVisibility)

	-- Update button states when the cloak button is shown
	cloakButton:HookScript("OnShow", function()
		UpdateToggleStates(helmButton, cloakButton)
	end)
end
