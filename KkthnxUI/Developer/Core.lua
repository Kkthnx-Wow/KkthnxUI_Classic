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

do
	-- GearScoreTooltip.lua

	local GearScoreTooltip = CreateFrame("Frame")
	local GS_CACHE = {}

	local function CalculateGearScore(player)
		local totalScore = 0
		for i = 1, 19 do -- 19 slots for gear in WoW Classic
			local itemLink = GetInventoryItemLink(player, i)
			if itemLink then
				local _, _, itemRarity, itemLevel = GetItemInfo(itemLink)
				if itemLevel then
					-- Here you would apply your GearScore formula.
					-- For simplicity, let's assume Score = ItemLevel * Rarity (where Rarity is 1-5)
					totalScore = totalScore + (itemLevel * (itemRarity or 1))
				end
			end
		end
		return math.floor(totalScore / 19) -- Average gear score
	end

	local function UpdateTooltip(tooltip, unit)
		local cachedScore = GS_CACHE[unit]
		if cachedScore then
			tooltip:AddLine("|cFF00FF00GearScore: " .. cachedScore .. "|r")
		else
			local score = CalculateGearScore(unit)
			GS_CACHE[unit] = score
			tooltip:AddLine("|cFF00FF00GearScore: " .. score .. "|r")
		end
	end

	-- Hook onto the tooltip for players
	local function HookTooltip(tooltip, method)
		local oldMethod = tooltip[method]
		tooltip[method] = function(self, ...)
			local unit = select(2, ...)
			if unit and UnitIsPlayer(unit) then
				UpdateTooltip(self, unit)
			end
			return oldMethod(self, ...)
		end
	end

	-- Hooking into OnTooltipSetUnit for both GameTooltip and UnitPopup_ShowUnitTooltip
	HookTooltip(GameTooltip, "OnTooltipSetUnit")
	-- HookTooltip(UnitPopup_ShowUnitTooltip, "OnTooltipSetUnit")

	-- For item tooltips, we'll hook into SetItemRef for tradeskills, auction house, etc.
	local old_SetItemRef = SetItemRef
	SetItemRef = function(link, ...)
		local type, id = link:match("^item:(%d+):")
		if type then
			local itemLink = "item:" .. id
			local _, _, itemRarity, itemLevel = GetItemInfo(itemLink)
			if itemLevel then
				GameTooltip:AddLine("|cFF00FF00GearScore: " .. (itemLevel * (itemRarity or 1)) .. "|r")
			end
		end
		return old_SetItemRef(link, ...)
	end

	-- Event handler for clearing cache when player logs out or zones
	GearScoreTooltip:RegisterEvent("PLAYER_LOGOUT")
	GearScoreTooltip:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	GearScoreTooltip:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_LOGOUT" or event == "ZONE_CHANGED_NEW_AREA" then
			GS_CACHE = {}
		end
	end)

	-- Print a message when the addon loads to confirm it's working
	print("GearScore Tooltip Loaded")
end
