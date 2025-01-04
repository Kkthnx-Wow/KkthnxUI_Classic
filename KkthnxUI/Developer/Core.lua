local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
-- local Module = K:NewModule("Developer")

K.Devs = {
	["Kkthnx-Area 52"] = true,
	["Chithick-Area 52"] = true,
	["Kkthnxbye-Area 52"] = true,
	["Kkthnx-Valdrakken"] = true,
	["Kkthnx-Crusader Strike"] = true,
	["Kkthnxbye-Crusader Strike"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

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

-- do
-- 	local playerGUID = UnitGUID("player")

-- 	-- Create a frame for displaying critical hit numbers
-- 	local critFrame = CreateFrame("Frame", "CritFrame", UIParent)
-- 	critFrame:SetSize(400, 100)
-- 	critFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 200)
-- 	critFrame:Hide()

-- 	critFrame.icon = critFrame:CreateTexture(nil, "OVERLAY")
-- 	critFrame.icon:SetSize(32, 32)
-- 	critFrame.icon:SetPoint("LEFT", critFrame, "LEFT", 10, 0)

-- 	critFrame.text = critFrame:CreateFontString(nil, "OVERLAY")
-- 	critFrame.text:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
-- 	critFrame.text:SetTextColor(1, 0.82, 0) -- Gold color
-- 	critFrame.text:SetPoint("LEFT", critFrame.icon, "RIGHT", 10, 0)

-- 	critFrame.amount = critFrame:CreateFontString(nil, "OVERLAY")
-- 	critFrame.amount:SetFont("Fonts\\FRIZQT__.TTF", 48, "OUTLINE") -- Increased font size for crit amount
-- 	critFrame.amount:SetTextColor(1, 0, 0) -- Red color
-- 	critFrame.amount:SetPoint("LEFT", critFrame.text, "RIGHT", 10, 0)

-- 	local function ShowCritAnimation(spellName, spellIcon, amount)
-- 		-- Stop any ongoing animations
-- 		if critFrame.animGroup and critFrame.animGroup:IsPlaying() then
-- 			critFrame.animGroup:Stop()
-- 		end

-- 		-- Set the spell icon and text
-- 		critFrame.icon:SetTexture(spellIcon)
-- 		critFrame.text:SetText(spellName .. " Crit For")
-- 		critFrame.amount:SetText(amount)
-- 		critFrame:Show()

-- 		-- Play a sound effect
-- 		PlaySound(39517, "Master")

-- 		-- Create animation group
-- 		critFrame.animGroup = critFrame:CreateAnimationGroup()

-- 		-- Create translation animation (move up)
-- 		local moveUp = critFrame.animGroup:CreateAnimation("Translation")
-- 		moveUp:SetOffset(0, 100) -- Move up by 100 pixels
-- 		moveUp:SetDuration(1.5) -- Duration of 1.5 seconds
-- 		moveUp:SetSmoothing("OUT")

-- 		-- Create fade out animation
-- 		local fadeOut = critFrame.animGroup:CreateAnimation("Alpha")
-- 		fadeOut:SetFromAlpha(1)
-- 		fadeOut:SetToAlpha(0)
-- 		fadeOut:SetDuration(1.5) -- Duration of 1.5 seconds
-- 		fadeOut:SetStartDelay(1.0) -- Start delay of 1.0 seconds
-- 		fadeOut:SetSmoothing("OUT")

-- 		critFrame.animGroup:SetScript("OnFinished", function()
-- 			critFrame:Hide()
-- 		end)

-- 		critFrame.animGroup:Play()
-- 	end

-- 	local eventFrame = CreateFrame("Frame", "CritEventFrame", UIParent)
-- 	eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
-- 	eventFrame:SetScript("OnEvent", function(self, event)
-- 		local _, subevent, _, sourceGUID, _, _, _, destGUID, destName = CombatLogGetCurrentEventInfo()
-- 		local spellId, amount, critical

-- 		if subevent == "SWING_DAMAGE" then
-- 			amount, _, _, _, _, _, critical = select(12, CombatLogGetCurrentEventInfo())
-- 			spellId = 6603 -- Auto Attack spell ID
-- 		elseif subevent == "SPELL_DAMAGE" then
-- 			spellId, _, _, amount, _, _, _, _, _, critical = select(12, CombatLogGetCurrentEventInfo())
-- 		end

-- 		if critical and sourceGUID == playerGUID then
-- 			local spellName = GetSpellInfo(spellId) or "Auto Attack"
-- 			local spellIcon = GetSpellTexture(spellId) or "Interface\\Icons\\INV_Misc_QuestionMark"
-- 			ShowCritAnimation(spellName, spellIcon, amount)
-- 		end
-- 	end)

-- 	-- Test command to simulate a critical hit
-- 	SLASH_TESTCRIT1 = "/testcrit"
-- 	SlashCmdList["TESTCRIT"] = function()
-- 		local testSpellName = "Test Spell"
-- 		local testSpellIcon = "Interface\\Icons\\Spell_Nature_StarFall"
-- 		local testAmount = 12345
-- 		ShowCritAnimation(testSpellName, testSpellIcon, testAmount)
-- 	end
-- end
