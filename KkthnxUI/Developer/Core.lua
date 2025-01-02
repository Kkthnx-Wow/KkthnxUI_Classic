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

do
	-- Define the spells to thank for
	local buffsToThank = {
		[1126] = true, -- Mark of the Wild (Druid)
		[1459] = true, -- Arcane Intellect (Mage)
		[1243] = true, -- Power Word: Fortitude (Priest)
		[6756] = true, -- Gift of the Wild (Druid)
		[782] = true, -- Thorns (Druid) -- Add only if desired
	}

	-- Create a table to track cooldowns for each caster
	local lastThanked = {}

	-- Get the player's name
	local playerName = UnitName("player")

	-- Create a frame for handling events
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	frame:SetScript("OnEvent", function()
		-- Get combat log details
		local _, subEvent, _, _, sourceName, _, _, _, destName, _, _, spellID = CombatLogGetCurrentEventInfo()

		-- Ensure the destination is exactly the player and the event is relevant
		if destName == playerName and (subEvent == "SPELL_CAST_SUCCESS" or subEvent == "SPELL_AURA_APPLIED") then
			-- Check if the spell is in our thank list
			if buffsToThank[spellID] then
				-- Get the current time
				local currentTime = GetTime()

				-- Check if we have already thanked this player within the cooldown period
				if not lastThanked[sourceName] or (currentTime - lastThanked[sourceName]) > 60 then
					-- Randomize the delay between 1-2 seconds
					local delay = math.random(1, 20) / 10 -- Generates 1.0 to 2.0 seconds

					-- Fetch the buff name
					local spellName = GetSpellInfo(spellID)

					-- Delay the thank-you emote
					C_Timer.After(delay, function()
						-- print("Thanking", sourceName, "for buff", spellName, "(Spell ID:", spellID, ")", "after", delay, "seconds")
						DoEmote("THANK", sourceName)
					end)

					-- Update the cooldown tracker
					lastThanked[sourceName] = currentTime
				else
					-- print("Cooldown active. Not thanking", sourceName)
				end
			else
				-- Spell is not in the thank list
				local spellName = GetSpellInfo(spellID) or "Unknown Spell"
				print("Buff not in the thank list!")
				print("Source:", sourceName, "Buff:", spellName, "(Spell ID:", spellID, ")")
				print("Consider adding this buff to your thank list. Tell the developer.")
			end
		else
			-- Debug only if destination is not the player
			if destName ~= playerName then
				-- print("Ignored event. DestName:", destName, "SubEvent:", subEvent)
			end
		end
	end)
end
