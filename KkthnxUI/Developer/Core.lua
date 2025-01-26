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
	-- Personal Level 60 Guild Announcement Addon
	local eventFrame = CreateFrame("Frame")

	-- Function to check if you've hit certain levels and announce to guild
	local function CheckLevel(newLevel)
		if newLevel % 10 == 0 and newLevel <= 60 then
			local announcement
			if newLevel == 60 then
				announcement = "Ding! I, " .. K.Name .. ", have reached the epic level of 60! Let's celebrate this monumental achievement!"
			else
				announcement = "Ding! I, " .. K.Name .. ", have hit level " .. newLevel .. "! On to the next milestone!"
			end
			-- Send announcement to guild chat
			SendChatMessage(announcement, "GUILD")
		end
	end

	-- Event handler for player level changes
	local function OnPlayerLevelChanged(_, _, newLevel)
		CheckLevel(newLevel)
	end

	-- Register for player level changed events
	eventFrame:RegisterEvent("PLAYER_LEVEL_CHANGED")
	eventFrame:SetScript("OnEvent", OnPlayerLevelChanged)
end
