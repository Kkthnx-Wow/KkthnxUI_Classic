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

do
	local gratsFrame = CreateFrame("Frame")
	gratsFrame:RegisterEvent("UNIT_LEVEL") -- Detect party members' level changes
	gratsFrame:RegisterEvent("GROUP_ROSTER_UPDATE") -- Track party changes

	local partyMembers = {} -- Tracks party members and their levels
	local messageQueue = {} -- Queue for delayed messages
	local debugMode = true -- Set to false to disable debugging

	-- Debugging function
	local function DebugPrint(message)
		if debugMode then
			print("|cff00ff00[LevelCheers Debug]:|r " .. message)
		end
	end

	-- Update the party members list and their current levels
	local function UpdatePartyMembers()
		DebugPrint("Updating party members...")
		for i = 1, GetNumGroupMembers() do
			local unitID = "party" .. i
			local name = UnitName(unitID)
			if name and name ~= UnitName("player") then
				local level = UnitLevel(unitID)
				if level then
					if not partyMembers[name] then
						DebugPrint("Adding new party member: " .. name .. " (Level " .. level .. ")")
						partyMembers[name] = level -- Add new members without announcing
					else
						DebugPrint("Existing party member: " .. name .. " (Stored Level: " .. partyMembers[name] .. ", Current Level: " .. level .. ")")
					end
				end
			end
		end
	end

	-- Queue a congratulatory message
	local function QueueGratsMessage(message)
		table.insert(messageQueue, message)
		DebugPrint("Queued message: " .. message)
	end

	-- Process the message queue with a delay
	local function ProcessMessageQueue()
		if #messageQueue > 0 then
			local message = table.remove(messageQueue, 1) -- Get the first message
			SendChatMessage(message, "PARTY") -- Send the message in party chat
			DebugPrint("Sent message: " .. message)

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
			DebugPrint("Milestone detected: Level " .. level)
		elseif math.random() > 0.3 then
			-- 70% chance to announce
			if math.random() > 0.5 then
				-- 50% chance to include level in the message
				message = includeLevelMessages[math.random(#includeLevelMessages)]:format(level)
				DebugPrint("Announcing level-specific message for Level " .. level)
			else
				-- Otherwise, send a generic congratulatory message
				message = gratsMessages[math.random(#gratsMessages)]
				DebugPrint("Announcing generic message.")
			end
		else
			-- Do not send any message (30% chance)
			DebugPrint("Skipping announcement for Level " .. level)
			return
		end

		QueueGratsMessage(message)

		-- Start processing the queue if not already active
		if #messageQueue == 1 then
			C_Timer.After(4, ProcessMessageQueue)
		end
	end

	-- Event handling
	gratsFrame:SetScript("OnEvent", function(_, event, arg1)
		if event == "UNIT_LEVEL" then
			-- Handle level changes
			local name = UnitName(arg1)
			local level = UnitLevel(arg1)
			if name and level and partyMembers[name] and partyMembers[name] < level then
				DebugPrint("Level-up detected for " .. name .. " (New Level: " .. level .. ")")
				partyMembers[name] = level
				local isMilestone = level % 10 == 0
				SendGrats(level, isMilestone)
			end
		elseif event == "GROUP_ROSTER_UPDATE" then
			-- Update party members when the group changes
			DebugPrint("GROUP_ROSTER_UPDATE event triggered.")
			UpdatePartyMembers()
		end
	end)

	-- Initialize the party member list on login or reload
	UpdatePartyMembers()
end
