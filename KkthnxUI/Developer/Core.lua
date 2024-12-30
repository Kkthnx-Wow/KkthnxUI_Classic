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

--[[ ============================================================
	SECTION: Level-Up Announcements
	Announces level-ups for party members with fun congratulatory messages.
	=============================================================== ]]
--[[

Description:
    LevelCheers is a lightweight addon for World of Warcraft that announces level-ups for party members with fun congratulatory messages. 
    The addon prioritizes milestone levels (e.g., 10, 20, 30) with guaranteed announcements, while other levels have a 70% chance of being announced.
    Messages are sent with a natural delay to avoid spam, and both level-specific and generic messages are supported.

Features:
    - 100% guaranteed announcements for milestone levels (10, 20, 30, etc.).
    - 70% chance to announce non-milestone levels.
    - Randomly decides whether to include the level in the message or send a generic congratulatory message.
    - Smooth processing using a message queue with a 4-second delay between announcements.
    - Automatically tracks and updates party member levels.

How It Works:
    - Tracks level-ups for all party members using the UNIT_LEVEL event.
    - Ensures milestone levels are always announced with special congratulatory messages.
    - Applies a 70% chance for announcing non-milestone levels and randomly chooses the message format (with or without the level).
    - Updates party member information dynamically whenever the group changes (GROUP_ROSTER_UPDATE event).

Usage:
    - Install the addon in your WoW addons folder.
    - It will automatically activate when you're in a party, and level-up announcements will appear in party chat.

Enjoy celebrating your party's level-ups with LevelCheers!
]]

do
	local gratsFrame = CreateFrame("Frame")
	gratsFrame:RegisterEvent("UNIT_LEVEL") -- Detect party members' level changes
	gratsFrame:RegisterEvent("GROUP_ROSTER_UPDATE") -- Track party changes

	local partyMembers = {} -- Tracks party members and their levels
	local messageQueue = {} -- Queue for delayed messages

	-- Update the party members list and their current levels
	local function UpdatePartyMembers()
		wipe(partyMembers) -- Clear the existing data
		for i = 1, GetNumGroupMembers() do
			local unitID = "party" .. i
			local name = UnitName(unitID)
			if name and name ~= UnitName("player") then
				local level = UnitLevel(unitID)
				partyMembers[name] = level
			end
		end
	end

	-- Queue a congratulatory message
	local function QueueGratsMessage(message)
		table.insert(messageQueue, message)
	end

	-- Process the message queue with a delay
	local function ProcessMessageQueue()
		if #messageQueue > 0 then
			local message = table.remove(messageQueue, 1) -- Get the first message
			SendChatMessage(message, "PARTY") -- Send the message in party chat

			-- Schedule the next message after 4 seconds
			if #messageQueue > 0 then
				C_Timer.After(4, ProcessMessageQueue)
			end
		end
	end

	-- Send a congratulatory message with optional level
	local function SendGrats(level, isMilestone)
		local gratsMessages = {
			"Grats!",
			"Congrats!",
			"Awesome, grats!",
		}
		local includeLevelMessages = {
			"Grats on level %s!",
			"Welcome to level %s!",
			"Level %s! Grats!",
		}
		local milestoneMessages = {
			"Wow, level %s! Huge grats!",
			"Congratulations on reaching level %s!",
			"Big milestone: level %s! Grats!",
		}

		local message
		if isMilestone then
			-- Always use a milestone-specific message
			message = milestoneMessages[math.random(#milestoneMessages)]:format(level)
		elseif math.random() > 0.3 then
			-- 70% chance to announce
			if level and math.random() > 0.5 then
				-- 50% chance to include level in the message
				message = includeLevelMessages[math.random(#includeLevelMessages)]:format(level)
			else
				-- Otherwise, send a generic congratulatory message
				message = gratsMessages[math.random(#gratsMessages)]
			end
		else
			-- Do not send any message (30% chance)
			return
		end

		QueueGratsMessage(message)

		-- Start processing the queue if not already active
		if #messageQueue == 1 then
			C_Timer.After(4, ProcessMessageQueue)
		end
	end

	-- Check if a level is a milestone
	local function IsMilestoneLevel(level)
		return level % 10 == 0
	end

	-- Event handling
	gratsFrame:SetScript("OnEvent", function(_, event, arg1)
		if event == "UNIT_LEVEL" and UnitInParty(arg1) then
			-- Party member level-up
			local name = UnitName(arg1)
			local newLevel = UnitLevel(arg1)

			if name and partyMembers[name] and name ~= UnitName("player") then
				local previousLevel = partyMembers[name]
				if newLevel > previousLevel then -- Only announce if the level increased
					local isMilestone = IsMilestoneLevel(newLevel)
					if isMilestone or math.random() > 0.3 then -- Always announce milestones
						SendGrats(newLevel, isMilestone)
					end
				end
				partyMembers[name] = newLevel -- Update the stored level
			end
		elseif event == "GROUP_ROSTER_UPDATE" then
			-- Update the party members when the group changes
			UpdatePartyMembers()
		end
	end)

	-- Initialize the party member list on login or reload
	UpdatePartyMembers()
end
