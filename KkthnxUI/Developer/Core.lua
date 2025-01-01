local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
-- local Module = K:NewModule("Developer")

K.Devs = {
	["Kkthnx-Area 52"] = true,
	["Chithick-Area 52"] = true,
	["Kkthnxbye-Area 52"] = true,
	["Kkthnx-Valdrakken"] = true,
	["Kkthnx-Crusader Strike"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

-- if not K.isDeveloper then
-- 	return
-- end

function K.AddToDevTool(data, name)
	if DevTool then
		DevTool:AddData(data, name)
	end
end

--[[ ============================================================
    SECTION: Chat Message Blocker
    Filters out specific phrases or patterns in chat messages 
    (e.g., monster emotes) based on a configurable list of patterns.
=============================================================== ]]

do
	-- Cache global references for performance
	local string_match = string.match
	local string_gsub = string.gsub
	local ipairs = ipairs
	local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter

	-- Create the ChatFilter object
	local ChatFilter = {}
	ChatFilter.blockedPatterns = {
		"^%s goes into a frenzy!$",
		"^%s attempts to run away in fear!$",
		"^%s collapses but the broken body rises again!$",
		"^%s becomes enraged!$",
	}

	-- Check if a message matches any of the blocked patterns
	function ChatFilter:IsBlockedMessage(message)
		for _, pattern in ipairs(self.blockedPatterns) do
			if string_match(message, string_gsub(pattern, "%%s", ".+")) then
				return true
			end
		end
		return false
	end

	-- Custom chat message filter function
	local function MyChatFilter(self, event, msg, sender, ...)
		if ChatFilter:IsBlockedMessage(msg) then
			return true
		end
		return false
	end

	-- Add the filter for specific chat message events
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", MyChatFilter)
end

do
	--[[ 
Addon: LevelCheers
Author: [Your Name]
Description:
    LevelCheers is a lightweight World of Warcraft addon that announces party members' level-ups with congratulatory messages. 
    It handles milestone levels (e.g., 10, 20, 30) with guaranteed announcements and randomizes the inclusion of the level or the player's name.
    Users can configure probabilities, debug mode, and messages via slash commands.

Features:
    - Configurable probabilities for announcements and message components.
    - Guaranteed milestone announcements.
    - Localization support.
    - Debugging and performance profiling.
    - Memory-efficient table pooling for large groups.
    - Handles raid groups and group disbands gracefully.
]]

	-- -- Global Variables
	-- local gratsFrame = CreateFrame("Frame")
	-- gratsFrame:RegisterEvent("UNIT_LEVEL")
	-- gratsFrame:RegisterEvent("GROUP_ROSTER_UPDATE")

	-- local partyMembers = {} -- Tracks party members and their levels
	-- local messageQueue = {} -- Queue for delayed messages
	-- local debugMode = false -- Default debug mode
	-- local settings = {
	-- 	announceProbability = 0.7, -- 70% chance to announce non-milestones
	-- 	includeNameProbability = 0.5, -- 50% chance to include name
	-- 	includeLevelProbability = 0.5, -- 50% chance to include level
	-- 	milestoneInterval = 10, -- Announce every 10 levels
	-- 	delayBetweenMessages = 4, -- Delay in seconds
	-- 	customMessages = {
	-- 		grats = { "Grats!", "Congrats!", "Awesome, grats!" },
	-- 		includeLevel = { "Grats on level %s!", "Welcome to level %s!", "Level %s! Grats!" },
	-- 		milestone = { "Wow, level %s! Huge grats!", "Big milestone: level %s! Grats!" },
	-- 	},
	-- }

	-- -- Debugging Function
	-- local function DebugPrint(message)
	-- 	if debugMode then
	-- 		print("|cff00ff00[LevelCheers Debug]:|r " .. message)
	-- 	end
	-- end

	-- -- Update Party Members
	-- local function UpdatePartyMembers()
	-- 	if GetNumGroupMembers() == 0 then
	-- 		DebugPrint("Not in a group. Wiping all party member data.")
	-- 		wipe(partyMembers)
	-- 		return
	-- 	end

	-- 	if IsInRaid() then
	-- 		DebugPrint("Skipping announcements in raid groups.")
	-- 		return
	-- 	end

	-- 	DebugPrint("Updating party members...")
	-- 	local currentMembers = {}
	-- 	for i = 1, GetNumGroupMembers() do
	-- 		local unitID = "party" .. i
	-- 		local name = UnitName(unitID)
	-- 		local level = UnitLevel(unitID)

	-- 		if name == "Unknown" or level == 0 then
	-- 			DebugPrint("Skipping incomplete data for: " .. (name or "Unknown") .. " (Level: " .. (level or 0) .. ")")
	-- 		else
	-- 			currentMembers[name] = true
	-- 			if not partyMembers[name] then
	-- 				DebugPrint("Adding new party member: " .. name .. " (Level " .. level .. ")")
	-- 				partyMembers[name] = level
	-- 			else
	-- 				DebugPrint("Existing party member: " .. name .. " (Stored Level: " .. partyMembers[name] .. ", Current Level: " .. level .. ")")
	-- 			end
	-- 		end
	-- 	end

	-- 	for name in pairs(partyMembers) do
	-- 		if not currentMembers[name] then
	-- 			DebugPrint("Removing party member who left: " .. name)
	-- 			partyMembers[name] = nil
	-- 		end
	-- 	end
	-- end

	-- -- Queue and Process Messages
	-- local function QueueGratsMessage(message)
	-- 	table.insert(messageQueue, message)
	-- 	DebugPrint("Queued message: " .. message)
	-- end

	-- local function ProcessMessageQueue()
	-- 	if #messageQueue > 0 then
	-- 		local message = table.remove(messageQueue, 1)
	-- 		SendChatMessage(message, "PARTY")
	-- 		DebugPrint("Sent message: " .. message)

	-- 		if #messageQueue > 0 then
	-- 			C_Timer.After(settings.delayBetweenMessages, ProcessMessageQueue)
	-- 		end
	-- 	end
	-- end

	-- -- Announce Level-Ups
	-- local function SendGrats(level, isMilestone, name)
	-- 	local messages = settings.customMessages
	-- 	local message

	-- 	if isMilestone then
	-- 		-- Milestone messages
	-- 		if math.random() < settings.includeNameProbability then
	-- 			message = messages.milestone[math.random(#messages.milestone)]:format(level) .. " " .. name
	-- 		else
	-- 			message = messages.milestone[math.random(#messages.milestone)]:format(level)
	-- 		end
	-- 		DebugPrint("Milestone detected: Level " .. level .. " for " .. name)
	-- 	elseif math.random() < settings.announceProbability then
	-- 		-- Regular level-up messages
	-- 		if math.random() < settings.includeLevelProbability then
	-- 			message = messages.includeLevel[math.random(#messages.includeLevel)]:format(level)
	-- 		else
	-- 			message = messages.grats[math.random(#messages.grats)]
	-- 		end
	-- 		if math.random() < settings.includeNameProbability then
	-- 			message = message .. " " .. name
	-- 		end
	-- 		DebugPrint("Regular level-up detected: Level " .. level .. " for " .. name)
	-- 	else
	-- 		-- No message
	-- 		DebugPrint("Skipping announcement for Level " .. level .. " for " .. name)
	-- 		return
	-- 	end

	-- 	QueueGratsMessage(message)
	-- 	if #messageQueue == 1 then
	-- 		C_Timer.After(settings.delayBetweenMessages, ProcessMessageQueue)
	-- 	end
	-- end

	-- -- Event Handling
	-- gratsFrame:SetScript("OnEvent", function(_, event, arg1)
	-- 	if event == "UNIT_LEVEL" then
	-- 		local name = UnitName(arg1)
	-- 		local level = UnitLevel(arg1)
	-- 		if name == UnitName("player") or not partyMembers[name] or not level or partyMembers[name] >= level then
	-- 			return
	-- 		end
	-- 		partyMembers[name] = level
	-- 		local isMilestone = level % settings.milestoneInterval == 0
	-- 		SendGrats(level, isMilestone, name)
	-- 	elseif event == "GROUP_ROSTER_UPDATE" then
	-- 		C_Timer.After(0.5, UpdatePartyMembers) -- Delayed update
	-- 	end
	-- end)

	-- -- Slash Commands
	-- SLASH_LEVELCHEERS1 = "/levelcheers"
	-- SlashCmdList["LEVELCHEERS"] = function(msg)
	-- 	if msg == "debug" then
	-- 		debugMode = not debugMode
	-- 		print("|cff00ff00[LevelCheers]:|r Debug mode " .. (debugMode and "enabled" or "disabled"))
	-- 	else
	-- 		print("|cff00ff00[LevelCheers]:|r Use '/levelcheers debug' to toggle debug mode.")
	-- 	end
	-- end

	-- -- Initialize Party Members
	-- UpdatePartyMembers()
end

-- LevelUp Display Addon
do
	-- Create the addon frame and register events
	local LevelUpDisplay = CreateFrame("Frame", "LevelUpDisplayFrame")
	LevelUpDisplay:RegisterEvent("PLAYER_LEVEL_UP")

	-- Reference to the currently displayed frame
	local currentFrame = nil

	-- Function to create and show the level-up message
	local function ShowLevelUpMessage(level, statGains)
		-- Hide any existing frame to prevent overlap
		if currentFrame and currentFrame:IsShown() then
			currentFrame:Hide()
		end

		-- Create the main frame for the level-up display
		local frame = CreateFrame("Frame", nil, UIParent)
		frame:SetSize(600, 150) -- Adjusted width to accommodate horizontal layout
		frame:SetPoint("CENTER", 0, 400)
		currentFrame = frame -- Save reference to the current frame

		-- Background texture
		local background = frame:CreateTexture(nil, "BACKGROUND")
		background:SetTexture("Interface/Addons/KkthnxUI/Media/Textures/LevelUpTex")
		background:SetPoint("BOTTOM")
		background:SetSize(326, 103)
		background:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
		background:SetVertexColor(1, 1, 1, 0.7)

		-- Top gold bar
		local topBar = frame:CreateTexture(nil, "ARTWORK")
		topBar:SetDrawLayer("BACKGROUND", 2)
		topBar:SetTexture("Interface/Addons/KkthnxUI/Media/Textures/LevelUpTex")
		topBar:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
		topBar:SetSize(430, 12)
		topBar:SetPoint("TOP")

		-- Bottom gold bar
		local bottomBar = frame:CreateTexture(nil, "ARTWORK")
		bottomBar:SetDrawLayer("BACKGROUND", 2)
		bottomBar:SetTexture("Interface/Addons/KkthnxUI/Media/Textures/LevelUpTex")
		bottomBar:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)
		bottomBar:SetSize(430, 12)
		bottomBar:SetPoint("BOTTOM")

		-- "You've Reached" text
		local headerText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
		headerText:SetPoint("CENTER", 0, 40)
		headerText:SetFont("Fonts\\FRIZQT__.TTF", 30, "OUTLINE")
		headerText:SetText("|cFFFFFFFFYou've Reached|r") -- White text

		-- "Level X" text
		local levelText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
		levelText:SetPoint("CENTER", 0, -12)
		levelText:SetFont("Fonts\\FRIZQT__.TTF", 50, "OUTLINE")
		levelText:SetText(string.format("|cFFFFD700Level %d|r", level)) -- Gold text

		-- Display stat increases horizontally
		local statFrame = CreateFrame("Frame", nil, frame)
		statFrame:SetSize(600, 30) -- Container for stat texts
		statFrame:SetPoint("BOTTOM", 0, 5)

		local font = "Fonts\\FRIZQT__.TTF"
		local fontSize = 16
		local statTexts = {}

		for stat, value in pairs(statGains) do
			if value > 0 then
				local statText = string.format("|cFF00FF00+%d %s|r", value, stat)
				table.insert(statTexts, statText)
			end
		end

		if #statTexts > 0 then
			local statString = table.concat(statTexts, ", ")
			local statFontString = statFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			statFontString:SetFont(font, fontSize, "OUTLINE")
			statFontString:SetText(statString)
			statFontString:SetPoint("CENTER", statFrame, "CENTER", 0, 0)
		else
			print("No stats to display.")
		end

		-- Fade-out animation
		local fadeOutAnimation = frame:CreateAnimationGroup()
		local fadeOut = fadeOutAnimation:CreateAnimation("Alpha")
		fadeOut:SetFromAlpha(1)
		fadeOut:SetToAlpha(0)
		fadeOut:SetDuration(2) -- 2 seconds to fade out
		fadeOut:SetStartDelay(4) -- Delay before fading
		fadeOut:SetSmoothing("OUT")
		fadeOutAnimation:SetScript("OnFinished", function()
			frame:Hide()
		end)

		-- Show the frame and start the animation
		frame:Show()
		fadeOutAnimation:Play()

		-- Perform the "CHEER" emote
		if math.random() < 0.5 then
			DoEmote("CHEER")
		end
	end

	-- Event handler
	LevelUpDisplay:SetScript("OnEvent", function(_, event, ...)
		if event == "PLAYER_LEVEL_UP" then
			local level, _, _, _, _, strengthDelta, agilityDelta, staminaDelta, intellectDelta = ...
			local statGains = {
				Strength = strengthDelta or 0,
				Agility = agilityDelta or 0,
				Stamina = staminaDelta or 0,
				Intellect = intellectDelta or 0,
			}
			ShowLevelUpMessage(level, statGains)
		end
	end)

	-- Slash command for testing
	SLASH_LEVELUPDISPLAY1 = "/leveluptest"
	SlashCmdList["LEVELUPDISPLAY"] = function(msg)
		local testLevel = tonumber(msg) or math.random(2, 60)
		local statGains = {
			Strength = math.random(0, 5),
			Agility = math.random(0, 5),
			Stamina = math.random(0, 5),
			Intellect = math.random(0, 5),
		}
		ShowLevelUpMessage(testLevel, statGains)
	end
end
