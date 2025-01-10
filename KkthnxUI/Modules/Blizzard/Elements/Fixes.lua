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
	-- Hook the GetClassColor function to return the custom Shaman color
	hooksecurefunc("GetClassColor", function(englishClass)
		if englishClass == "SHAMAN" then
			return K.FixShamanColor.r, K.FixShamanColor.g, K.FixShamanColor.b, 1.0
		end
	end)

	-- Update chat color configuration for Shamans
	local function UpdateShamanChatColor()
		local shamanColor = CreateColor(K.FixShamanColor.r, K.FixShamanColor.g, K.FixShamanColor.b)
		RAID_CLASS_COLORS["SHAMAN"] = shamanColor
		RAID_CLASS_COLORS["SHAMAN"].colorStr = K.FixShamanColor.colorStr
	end

	-- Initialize the Shaman color functionality
	local function InitializeShamanColor()
		UpdateShamanChatColor()
	end

	-- Register the initialization event
	K:RegisterEvent("PLAYER_LOGIN", InitializeShamanColor)
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
