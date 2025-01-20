local K, C = KkthnxUI[1], KkthnxUI[2]
-- local Module = K:GetModule("Blizzard")

do
	-- Fix blizz error
	MAIN_MENU_MICRO_ALERT_PRIORITY = MAIN_MENU_MICRO_ALERT_PRIORITY or {}
end

do
	-- Still exisits in 1.14.3.43154
	if not InspectTalentFrameSpentPoints then
		InspectTalentFrameSpentPoints = CreateFrame("Frame")
	end
end

do
	-- Fix blizz bug in addon list
	local _AddonTooltip_Update = AddonTooltip_Update
	function AddonTooltip_Update(owner)
		if not owner then
			return
		end
		if owner:GetID() < 1 then
			return
		end
		_AddonTooltip_Update(owner)
	end
end

do
	-- Fix MasterLooterFrame anchor issue
	hooksecurefunc(MasterLooterFrame, "Show", function(self)
		self:ClearAllPoints()
	end)
end

do
	local function SetShamanColor(colorTable, color)
		if colorTable then
			colorTable["SHAMAN"].r = color.r
			colorTable["SHAMAN"].g = color.g
			colorTable["SHAMAN"].b = color.b
			colorTable["SHAMAN"].colorStr = color.colorStr
		end
	end

	SetShamanColor(RAID_CLASS_COLORS, K.FixShamanColor)
	SetShamanColor(CUSTOM_CLASS_COLORS, K.FixShamanColor)
end

do
	-- This script fixes the quest icon textures in the QuestFrameGreetingPanel.
	-- It checks if the QuestFrameFixer addon is loaded and returns early if it is to avoid conflicts.
	-- It then initializes the quest title buttons and their associated icon textures.
	-- When the QuestFrameGreetingPanel is shown, it updates the quest icon textures to the active or available quest icon based on whether the quest is active.

	local _G = _G
	local tinsert = table.insert
	local GetFileIDFromPath = GetFileIDFromPath
	local MAX_NUM_QUESTS = MAX_NUM_QUESTS

	-- Check if QuestFrameFixer addon is loaded
	if IsAddOnLoaded("QuestFrameFixer") then
		return
	end

	local ACTIVE_QUEST_ICON_FILEID = GetFileIDFromPath("Interface\\GossipFrame\\ActiveQuestIcon")
	local AVAILABLE_QUEST_ICON_FILEID = GetFileIDFromPath("Interface\\GossipFrame\\AvailableQuestIcon")

	local questTitleButtons = {}
	local questIconTextures = {}

	-- Initialize quest title buttons and icon textures
	for i = 1, MAX_NUM_QUESTS do
		local questTitleButton = _G["QuestTitleButton" .. i]
		if questTitleButton then
			tinsert(questTitleButtons, questTitleButton)
			local questIconTexture = _G[questTitleButton:GetName() .. "QuestIcon"]
			if questIconTexture then
				tinsert(questIconTextures, questIconTexture)
			else
				-- Debugging: Log missing quest icon texture
				print("Missing quest icon texture for button: " .. questTitleButton:GetName())
			end
		else
			-- Debugging: Log missing quest title button
			print("Missing quest title button: QuestTitleButton" .. i)
		end
	end

	-- Hook the OnShow event of the QuestFrameGreetingPanel
	QuestFrameGreetingPanel:HookScript("OnShow", function()
		for i, questTitleButton in ipairs(questTitleButtons) do
			if questTitleButton:IsVisible() then
				local questIconTexture = questIconTextures[i]
				if questIconTexture then
					if questTitleButton.isActive == 1 then
						questIconTexture:SetTexture(ACTIVE_QUEST_ICON_FILEID)
					else
						questIconTexture:SetTexture(AVAILABLE_QUEST_ICON_FILEID)
					end
				else
					-- Debugging: Log missing quest icon texture
					print("Missing quest icon texture for visible button: " .. questTitleButton:GetName())
				end
			end
		end
	end)
end

do
	-- This ensures the 'scriptErrors' CVar is always disabled to prevent spam caused by Blizzard's bug with 'FCF_DockUpdate' in Classic Era.
	-- Even if a user or another addon attempts to enable 'scriptErrors', this script will immediately turn it back off.

	-- Create a frame to handle events
	local eventHandlerFrame = CreateFrame("Frame")

	-- Function to ensure 'scriptErrors' is always set to 0
	local function EnsureScriptErrorsDisabled()
		if GetCVar("scriptErrors") ~= "0" then
			SetCVar("scriptErrors", 0)
		end
	end

	-- Event handler function to manage specific events
	local function OnEvent(self, event, ...)
		if event == "PLAYER_ENTERING_WORLD" or event == "CVAR_UPDATE" then
			-- Ensure 'scriptErrors' is always disabled, introduces a small delay to allow the CVars to updateReason
			C_Timer.After(0.5, EnsureScriptErrorsDisabled)
		end
	end

	-- Register events to enforce the 'scriptErrors' setting
	eventHandlerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventHandlerFrame:RegisterEvent("CVAR_UPDATE")
	eventHandlerFrame:SetScript("OnEvent", OnEvent)

	-- Initial check to disable 'scriptErrors' during addon load
	EnsureScriptErrorsDisabled()
end

-- do
-- 	-- This script ensures the RuneFrameControlButton is clicked to toggle the Rune Frame's state,
-- 	-- preventing it from being shown by default unlike Blizzard's implementation where it's always open (which can be annoying).

-- 	-- Create a frame to handle the toggling of Rune Frame visibility
-- 	local runeVisibilityController = CreateFrame("Frame")

-- 	-- Frames that, when shown, should trigger the Rune Frame toggle
-- 	local framesToToggle = {
-- 		"CharacterFrame",
-- 		"ReputationFrame",
-- 		"SkillFrame",
-- 		"HonorFrame",
-- 	}

-- 	-- Tabs that, when clicked, should trigger the Rune Frame toggle
-- 	local tabsToToggle = {
-- 		"CharacterFrameTab1",
-- 		"CharacterFrameTab3",
-- 		"CharacterFrameTab4",
-- 		"CharacterFrameTab5",
-- 	}

-- 	-- Function to toggle the Rune Frame
-- 	local function toggleRuneFrame()
-- 		if _G.RuneFrameControlButton then
-- 			_G.RuneFrameControlButton:Click()
-- 		end
-- 	end

-- 	-- Function to set up event hooks for toggling
-- 	local function setupToggleHooks()
-- 		-- Hook the OnShow event for frames to toggle the Rune Frame
-- 		for _, frameName in ipairs(framesToToggle) do
-- 			local frame = _G[frameName]
-- 			if frame then
-- 				frame:HookScript("OnShow", toggleRuneFrame)
-- 			end
-- 		end

-- 		-- Hook the OnClick event for tabs to toggle the Rune Frame
-- 		for _, tabName in ipairs(tabsToToggle) do
-- 			local tab = _G[tabName]
-- 			if tab then
-- 				tab:HookScript("OnClick", toggleRuneFrame)
-- 			end
-- 		end
-- 	end

-- 	-- Register for the PLAYER_LOGIN event to ensure all UI elements are loaded before setting hooks
-- 	runeVisibilityController:RegisterEvent("PLAYER_LOGIN")
-- 	runeVisibilityController:SetScript("OnEvent", function(self, event)
-- 		if event == "PLAYER_LOGIN" then
-- 			setupToggleHooks()
-- 		end
-- 	end)
-- end
