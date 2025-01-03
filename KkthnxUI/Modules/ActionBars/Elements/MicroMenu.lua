local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

local insert, ipairs, pairs = table.insert, ipairs, pairs
local type, wipe = type, table.wipe

local MicroButtons = {}
local updateWatcher = 0

-- Helper function to reset button positions
local function ResetButtonProperties(button)
	button:ClearAllPoints()
	button:SetAllPoints(button.__owner)
end

-- Helper function to configure button textures
local function SetupMicroButtonTextures(button)
	local function SetTextureProperties(texture)
		texture:SetTexCoord(0.17, 0.87, 0.5, 0.908)
		texture:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
		texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	end

	local highlight = button:GetHighlightTexture()
	local normal = button:GetNormalTexture()
	local pushed = button:GetPushedTexture()
	local disabled = button:GetDisabledTexture()
	local flash = button.FlashBorder
	local flashTexture = K.MediaFolder .. "Skins\\HighlightMicroButtonWhite"

	if highlight then
		highlight:SetAlpha(0)
	end
	if normal then
		SetTextureProperties(normal)
	end
	if pushed then
		SetTextureProperties(pushed)
	end
	if disabled then
		SetTextureProperties(disabled)
	end
	if flash then
		flash:SetTexture(flashTexture)
		flash:SetVertexColor(K.r, K.g, K.b)
		flash:SetPoint("TOPLEFT", button, "TOPLEFT", -24, 18)
		flash:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 24, -18)
	end

	if button.FlashContent then
		button.FlashContent:SetTexture(nil)
	end
	if button.Background then
		button.Background:SetAlpha(0)
	end
	if button.PushedBackground then
		button.PushedBackground:SetAlpha(0)
	end
end

-- Fades out the micro menu bar
local function FadeOutMicroMenu()
	local KKUI_MenuBar = _G.KKUI_MenuBar
	if KKUI_MenuBar then
		K.UIFrameFadeOut(KKUI_MenuBar, 0.2, KKUI_MenuBar:GetAlpha(), 0)
	end
end

-- Updates fade on mouseover
local function UpdateOnMouseOver(_, elapsed)
	local KKUI_MenuBar = _G.KKUI_MenuBar
	if not KKUI_MenuBar then
		return
	end

	updateWatcher = updateWatcher + elapsed
	if updateWatcher > 0.1 then
		if not KKUI_MenuBar:IsMouseOver() then
			KKUI_MenuBar.IsMouseOvered = nil
			KKUI_MenuBar:SetScript("OnUpdate", nil)
			FadeOutMicroMenu()
		end
		updateWatcher = 0
	end
end

-- Handles mouse enter for micro buttons
local function OnMicroButtonEnter()
	local KKUI_MenuBar = _G.KKUI_MenuBar
	if KKUI_MenuBar and not KKUI_MenuBar.IsMouseOvered then
		KKUI_MenuBar.IsMouseOvered = true
		KKUI_MenuBar:SetScript("OnUpdate", UpdateOnMouseOver)
		K.UIFrameFadeIn(KKUI_MenuBar, 0.2, KKUI_MenuBar:GetAlpha(), 1)
	end
end

-- Dynamically determines which button to show
local function GetActiveGuildButton()
	return C_CVar.GetCVarBool("useClassicGuildUI") and "SocialsMicroButton" or "GuildMicroButton"
end

-- Creates individual micro buttons
local function CreateMicroButton(parent, buttonName, FadeMicroMenuEnabled)
	local buttonFrame = CreateFrame("Frame", nil, parent)
	buttonFrame:SetSize(22, 30)
	buttonFrame:CreateBorder()
	insert(MicroButtons, buttonFrame)

	local button = _G[buttonName]
	if not button then
		return
	end

	button:SetParent(buttonFrame)
	button.__owner = buttonFrame
	ResetButtonProperties(button)
	hooksecurefunc(button, "SetParent", ResetButtonProperties)
	hooksecurefunc(button, "SetPoint", ResetButtonProperties)

	button:SetHitRectInsets(0, 0, 0, 0)
	button:SetHighlightTexture(0)
	button.SetHighlightTexture = K.Noop

	SetupMicroButtonTextures(button)

	if FadeMicroMenuEnabled then
		button:HookScript("OnEnter", OnMicroButtonEnter)
	end
end

-- Rebuilds the micro menu dynamically
local function RebuildMicroMenu()
	local KKUI_MenuBar = _G.KKUI_MenuBar
	if not KKUI_MenuBar then
		return
	end

	wipe(MicroButtons)

	local buttonInfo = {
		"CharacterMicroButton",
		"SpellbookMicroButton",
		"TalentMicroButton",
		"QuestLogMicroButton",
		GetActiveGuildButton(), -- Dynamically determines Guild/Socials button
		"WorldMapMicroButton",
		"HelpMicroButton",
		"MainMenuMicroButton",
	}

	for i, buttonName in ipairs(buttonInfo) do
		CreateMicroButton(KKUI_MenuBar, buttonName, C["ActionBar"].FadeMicroMenu)
		if i > 1 then
			MicroButtons[i]:SetPoint("LEFT", MicroButtons[i - 1], "RIGHT", 6, 0)
		else
			MicroButtons[i]:SetPoint("LEFT", KKUI_MenuBar, "LEFT", 0, 0)
		end
	end
end

-- Handles CVAR updates
local function HandleCVARUpdate(event, cvarName)
	if cvarName == "useClassicGuildUI" then
		RebuildMicroMenu()
	end
end

-- Main function to create the micro menu
function Module:CreateMicroMenu()
	if not C["ActionBar"].MicroMenu then
		return
	end

	local FadeMicroMenuEnabled = C["ActionBar"].FadeMicroMenu

	-- Create the menu bar
	local KKUI_MenuBar = CreateFrame("Frame", "KKUI_MenuBar", K.PetBattleFrameHider)
	KKUI_MenuBar:SetSize(218, 30)
	KKUI_MenuBar:SetAlpha(FadeMicroMenuEnabled and 0 or 1)
	KKUI_MenuBar:EnableMouse(false)
	K.Mover(KKUI_MenuBar, "Menubar", "Menubar", { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 })

	-- Initial build of the micro menu
	RebuildMicroMenu()

	-- Hook into Blizzard's UpdateMicroButtons to adjust portrait positioning
	hooksecurefunc("UpdateMicroButtons", function()
		if MicroButtonPortrait then
			MicroButtonPortrait:ClearAllPoints()
			MicroButtonPortrait:SetPoint("TOPLEFT", CharacterMicroButton, "TOPLEFT", 2, -2)
			MicroButtonPortrait:SetPoint("BOTTOMRIGHT", CharacterMicroButton, "BOTTOMRIGHT", -2, 2)
		end
	end)

	-- Hook into CVAR updates to rebuild the menu dynamically
	K:RegisterEvent("CVAR_UPDATE", HandleCVARUpdate)
end
