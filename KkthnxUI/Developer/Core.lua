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
    SECTION: Chat Message Blocker (WIP)
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
	-- Create a frame to listen for events
	local frame = CreateFrame("Frame")

	-- Register for the "CHAT_MSG_SYSTEM" event to capture system messages
	frame:RegisterEvent("CHAT_MSG_SYSTEM")

	-- Helper function to check if the player is in a guild and get the guild name
	local function GetPlayerGuildName()
		if IsInGuild() then
			local guildName = GetGuildInfo("player")
			return guildName
		end
		return nil
	end

	-- Pool of randomized welcome messages
	local welcomeMessages = {
		"Welcome aboard, %s!",
		"Glad to have you here, %s! 😊",
		"Hail and well met, %s! 🎉",
		"Welcome to the guild, %s!",
		"Another brave soul joins us. Welcome!",
		"Make yourself at home, %s!",
		"Welcome, %s! We're glad you're here!",
		"We're thrilled to have you, %s!",
		"A warm welcome to our new member!",
		"Welcome to the guild family, %s!",
		-- Generic messages without player name
		"Welcome!",
		"Welcome aboard!",
		"Welcome to %s!",
		"Glad to see a new face here!",
		"Let's give a warm welcome to our newest member!",
		"Another champion joins %s! Welcome!",
		"Welcome to the family!",
		"Welcome, adventurer!",
	}

	-- Function to remove the realm name from a player name
	local function StripRealmName(playerName)
		return string.match(playerName, "^(.-)%-.+$") or playerName
	end

	-- Function to handle the event
	local function OnEvent(self, event, message)
		-- Get the guild name and terminate if the player is not in a guild
		local guildName = GetPlayerGuildName()
		if not guildName then
			return
		end

		-- Check if the message matches the "has joined the guild" pattern
		local playerNameWithRealm = string.match(message, "^(.-) has joined the guild%.$")
		if playerNameWithRealm then
			-- Strip the realm name from the player's name
			local playerName = StripRealmName(playerNameWithRealm)

			-- Schedule the welcome message with a random delay between 3 and 6 seconds
			local delay = math.random(3, 6)
			C_Timer.After(delay, function()
				-- Select a random message from the pool
				local randomIndex = math.random(1, #welcomeMessages)
				local welcomeMessage = welcomeMessages[randomIndex]

				-- Format the message only if it contains '%s' for the player's name or guild name
				if string.find(welcomeMessage, "%%s") then
					if string.find(welcomeMessage, guildName) then
						welcomeMessage = string.format(welcomeMessage, guildName)
					else
						welcomeMessage = string.format(welcomeMessage, playerName)
					end
				end

				-- Send the welcome message to guild chat
				SendChatMessage(welcomeMessage, "GUILD")
			end)
		end
	end

	-- Set the event handler
	frame:SetScript("OnEvent", OnEvent)
end
