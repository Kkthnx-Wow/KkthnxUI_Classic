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
	local congratulatoryMessages = { "Grats!", "Congrats!", "Congratulations!", "Way to go!", "Awesome!" }
	local lastPopupTime = 0
	local popupCooldown = 5 -- seconds

	-- Localized patterns for matching messages
	local localizedPatterns = {
		enUS = {
			levelUp = {
				"^level 60$", -- Exact match: "level 60"
				"^lvl 60$", -- Exact match: "lvl 60"
				"^ding 60$", -- Exact match: "ding 60"
				"^hit 60$", -- Exact match: "hit 60"
				"^60$", -- Exact match: "60"
				"^reached level 60$", -- Exact match: "reached level 60"
				"^finally 60$", -- Exact match: "finally 60"
				"^ding$", -- Exact match: "ding"
				"^level cap$", -- Exact match: "level cap"
				".*60.*finally.*", -- Contains "60" and "finally"
				".*finally.*60.*", -- Contains "finally" and "60"
				".*woot.*60.*", -- Contains "woot" and "60"
			},
			attunement = {
				"^attunement complete$", -- Exact match: "attunement complete"
				"^completed attunement$", -- Exact match: "completed attunement"
				"^attunement achieved$", -- Exact match: "attunement achieved"
				"^onyxia attuned$", -- Exact match: "onyxia attuned"
				"^mc attuned$", -- Exact match: "mc attuned"
				"^bwl attuned$", -- Exact match: "bwl attuned"
			},
		},
	}

	-- Function to get patterns based on locale
	local function GetPatterns()
		local clientLocale = GetLocale()
		return localizedPatterns[clientLocale] or localizedPatterns["enUS"]
	end

	-- Advanced pattern matcher: Strict and specific
	local function MatchesPattern(message, patterns)
		for _, pattern in ipairs(patterns) do
			if message:find(pattern) then
				return true
			end
		end
		return false
	end

	-- Function to check if a message matches level-up patterns
	local function IsLevelUpMessage(message)
		return MatchesPattern(message, GetPatterns().levelUp)
	end

	-- Function to check if a message matches attunement completion patterns
	local function IsAttunementCompleteMessage(message)
		return MatchesPattern(message, GetPatterns().attunement)
	end

	-- Cooldown mechanism to prevent spamming popups
	local function CanShowPopup()
		if GetTime() - lastPopupTime > popupCooldown then
			lastPopupTime = GetTime()
			return true
		end
		return false
	end

	-- StaticPopup definition
	StaticPopupDialogs["CONGRATULATE_POPUP"] = {
		text = "%s just %s! What do you want to do?",
		button1 = "Congratulate",
		button2 = "Ignore",
		OnAccept = function(self, data)
			SendChatMessage(data.message, "GUILD")
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}

	-- Main function to handle guild chat messages
	local function OnGuildChat(_, _, message, sender)
		-- Normalize the message for easier matching
		local lowerMessage = message:lower():gsub("%s+", " ") -- Normalize spaces

		-- Extract sender's name without realm
		local senderName = sender:match("^(.-)%-") or sender

		-- Check for level-up or attunement completion messages
		local action = nil
		if IsLevelUpMessage(lowerMessage) then
			action = "reached level 60"
		elseif IsAttunementCompleteMessage(lowerMessage) then
			action = "completed their attunement"
		end

		if action and CanShowPopup() then
			-- Prepare the message and show the popup
			local randomCongrats = congratulatoryMessages[math.random(#congratulatoryMessages)]
			local congratsMessage = randomCongrats .. " " .. senderName
			StaticPopup_Show("CONGRATULATE_POPUP", senderName, action, { message = congratsMessage })
		end
	end

	-- Register event listener for guild chat
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("CHAT_MSG_GUILD")
	frame:SetScript("OnEvent", OnGuildChat)
end
