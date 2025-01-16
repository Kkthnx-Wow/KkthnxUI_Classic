local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

local date = date
local string_format = string.format
local tonumber = tonumber

local CALENDAR_FULLDATE_MONTH_NAMES = CALENDAR_FULLDATE_MONTH_NAMES
local CALENDAR_WEEKDAY_NAMES = CALENDAR_WEEKDAY_NAMES
local C_Calendar_GetNumPendingInvites = C_Calendar.GetNumPendingInvites
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local FULLDATE = FULLDATE
local GameTime_GetGameTime = GameTime_GetGameTime
local GameTime_GetLocalTime = GameTime_GetLocalTime
local GameTooltip = GameTooltip
local GetCVarBool = GetCVarBool
local GetGameTime = GetGameTime
local GetNumSavedInstances = GetNumSavedInstances
local GetSavedInstanceInfo = GetSavedInstanceInfo
local RequestRaidInfo = RequestRaidInfo
local SecondsToTime = SecondsToTime
local TIMEMANAGER_TICKER_12HOUR = TIMEMANAGER_TICKER_12HOUR
local TIMEMANAGER_TICKER_24HOUR = TIMEMANAGER_TICKER_24HOUR

local TimeDataText

local function updateTimerFormat(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return string_format(color .. TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = K.MyClassColor .. (hour < 12 and TIMEMANAGER_AM or TIMEMANAGER_PM)

		if hour >= 12 then
			if hour > 12 then
				hour = hour - 12
			end
		else
			if hour == 0 then
				hour = 12
			end
		end

		return string_format(color .. TIMEMANAGER_TICKER_12HOUR .. timerUnit, hour, minute)
	end
end

-- Declare onUpdateTimer as a local variable
local onUpdateTimer = onUpdateTimer or 3

local function OnUpdate(_, elapsed)
	onUpdateTimer = onUpdateTimer + elapsed
	if onUpdateTimer > 5 then
		local color = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""
		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		TimeDataText.Text:SetText(updateTimerFormat(color, hour, minute))

		onUpdateTimer = 0
	end
end

-- Blood Moon Tracker for WoW Lua
local BloodMoon = {
	name = "Blood Moon",
	level = 40,
	type = "PvP",
	cycle = 3 * 3600, -- Event repeats every 3 hours (in seconds)
	duration = 30 * 60, -- Event lasts for 30 minutes (in seconds)
}

-- Utility: Format time into human-readable format
local function FormatTime(seconds)
	local hours = math.floor(seconds / 3600)
	local mins = math.floor((seconds % 3600) / 60)
	return hours > 0 and string.format("%dh %dm", hours, mins) or string.format("%dm", mins)
end

-- Get time since midnight in seconds
local function GetTimeSinceMidnight()
	local gameHour, gameMinute = GetGameTime()
	return gameHour * 3600 + gameMinute * 60
end

-- Calculate Blood Moon event status
local function GetBloodMoonStatus()
	local timeSinceMidnight = GetTimeSinceMidnight()
	local elapsed = timeSinceMidnight % BloodMoon.cycle -- Time since the last event cycle started
	local timeUntilNextEvent = BloodMoon.cycle - elapsed -- Time remaining until the next event cycle starts
	local timeUntilEventEnd = BloodMoon.duration - elapsed -- Time remaining until the current event ends

	if elapsed < BloodMoon.duration then
		-- Event is active
		return "Active ", FormatTime(timeUntilEventEnd)
	elseif timeUntilNextEvent <= 600 then
		-- Event is starting soon (10 minutes or less)
		return "Starting Soon ", FormatTime(timeUntilNextEvent)
	else
		-- Event is in cooldown (waiting for the next cycle)
		return "Starts In ", FormatTime(timeUntilNextEvent)
	end
end
-- Define the quest list with relevant data
local nightmareQuestList = {
	["Duskwood"] = { -- Level 25
		level = 25,
		quests = {
			{ id = 81730 }, -- "Defeat Worgen
			{ id = 81731 }, -- "Defeat Ogres
			{ id = 81732 }, -- "Defeat Dragonkin
			{ id = 81733 }, -- "Ogre Intelligence
			{ id = 81734 }, -- "Worgen Intelligence
			{ id = 81735 }, -- "Dragon Intelligence
			{ id = 81736 }, -- "Recover Shadowscythe
			{ id = 81737 }, -- "Recover Ogre Magi Text
			{ id = 81738 }, -- "Recover Dragon Egg
			{ id = 81739 }, -- "Nightmare Moss
			{ id = 81740 }, -- "Cold Iron Ore
			{ id = 81741 }, -- "Dream-Touched Dragonscale
			{ id = 81742 }, -- "Defeat Ylanthrius
			{ id = 81743 }, -- "Defeat Vvarc'zul
			{ id = 81744 }, -- "Defeat Amokarok
			{ id = 81745 }, -- "Rescue Kroll Mountainshade
			{ id = 81746 }, -- "Rescue Alara Grovemender
			{ id = 81747 }, -- "Rescue Elenora Marshwalker
		},
	},
	["Ashenvale"] = { -- Level 40
		level = 40,
		quests = {
			{ id = 81768 }, -- Defeat Satyrs
			{ id = 81769 }, -- Defeat Treants
			{ id = 81770 }, -- Defeat Dragonkin
			{ id = 81771 }, -- Dragon Intelligence
			{ id = 81772 }, -- Satyr Intelligence
			{ id = 81773 }, -- Treant Intelligence
			{ id = 81774 }, -- Recover Dreamengine
			{ id = 81775 }, -- Recover Azsharan Prophecy
			{ id = 81776 }, -- Recover Dream-Touched Dragonegg
			{ id = 81777 }, -- Dreamroot
			{ id = 81778 }, -- Fool's Gold Dust
			{ id = 81779 }, -- Dream-Infused Dragonscale
			{ id = 81780 }, -- Defeat Larsera
			{ id = 81781 }, -- Defeat Zalius
			{ id = 81782 }, -- Defeat Shredder 9000
			{ id = 81783 }, -- Rescue Alyssian Windcaller
			{ id = 81784 }, -- Rescue Doran Dreambough
			{ id = 81785 }, -- Rescue Maseara Autumnmoon
		},
	},
	["Hinterlands"] = { -- Level 50
		level = 50,
		quests = {
			{ id = 81786 }, -- Defeat Moonkin
			{ id = 81787 }, -- Defeat Giant Turtles
			{ id = 81788 }, -- Defeat Dragonkin
			{ id = 81789 }, -- Dragon Intelligence
			{ id = 81832 }, -- Recover Dreampearl
			{ id = 81817 }, --  Turtle Intelligence
			{ id = 81820 }, --  Moonkin Intelligence
			{ id = 81826 }, --  Recover Star-Touched Dragonegg
			{ id = 81830 }, -- Recover Elunar Relic
			{ id = 81833 }, -- Star Lotus
			{ id = 81834 }, -- Starsilver Ore
			{ id = 81835 }, -- Starshells
			{ id = 81837 }, -- Defeat Florius
			{ id = 81838 }, --  Defeat Doomkin
			{ id = 81839 }, --  Defeat Ghamoo-Raja
			{ id = 81850 }, -- Rescue Elianar Shadowdrinker
			{ id = 81851 }, -- Rescue Serlina Starbright
			{ id = 81852 }, -- Rescue Veanna Cloudsleeper
		},
	},
	["Feralas"] = { -- Level 50
		level = 50,
		quests = {
			{ id = 81855 }, -- Defeat Children of Cenarius
			{ id = 81856 }, -- Defeat Harpies
			{ id = 81857 }, -- Defeat Dragonkin
			{ id = 81858 }, -- Dragon Intelligence
			{ id = 81859 }, -- Cenarion Intelligence
			{ id = 81860 }, -- Harpy Intelligence
			{ id = 81861 }, -- Recover Moonglow Dragonegg
			{ id = 81863 }, -- Recover Keeper's Notes
			{ id = 81864 }, -- Recover Harpy Screed
			{ id = 81865 }, -- Moonroot
			{ id = 81866 }, -- Greater Moonstone
			{ id = 81867 }, -- Greater Moondragon Scales
			{ id = 81868 }, -- Defeat Tyrannikus
			{ id = 81870 }, -- Defeat Alondrius
			{ id = 81871 }, -- Defeat Slirena
			{ id = 81872 }, -- Rescue Mellias Earthtender
			{ id = 81873 }, -- Rescue Nerene Brooksinger
			{ id = 81874 }, -- Rescue Jamniss Treemender
		},
	},
}

-- Function to count completed quests for a zone
local function GetCompletedQuestCount(zone)
	local quests = nightmareQuestList[zone].quests
	local completedCount = 0
	for _, quest in pairs(quests) do
		if C_QuestLog.IsQuestFlaggedCompleted(quest.id) then
			completedCount = completedCount + 1
		end
	end
	return completedCount, #quests
end

local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text .. ":")
		title = true
	end
end

local function OnShiftDown()
	if Module.Entered then
		Module:OnEnter()
	end
end

function Module:OnEnter()
	Module.Entered = true

	RequestRaidInfo()

	local r, g, b
	GameTooltip:SetOwner(TimeDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(TimeDataText))
	GameTooltip:ClearLines()

	local today = C_DateAndTime_GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	GameTooltip:AddLine(string_format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0.4, 0.6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), nil, nil, nil, 0.75, 0.75, 0.75)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), nil, nil, nil, 0.75, 0.75, 0.75)

	-- Herioc/Mythic Dungeons
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diff, locked, extended, _, _, maxPlayers, diffName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if (diff == 2 or diff == 23) and (locked or extended) and name then
			addTitle("Saved Dungeon(s)")
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 0.75, 0.75, 0.75
			end

			GameTooltip:AddDoubleLine(name .. " - " .. maxPlayers .. " " .. PLAYER .. " (" .. diffName .. ") (" .. encounterProgress .. "/" .. numEncounters .. ")", SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	-- Raids
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, locked, extended, _, isRaid, _, diffName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if isRaid and (locked or extended) and name then
			addTitle(L["Saved Raid(s)"])
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 0.75, 0.75, 0.75
			end

			local progressColor = (numEncounters == encounterProgress) and "ff0000" or "00ff00"
			local progressStr = format(" |cff%s(%s/%s)|r", progressColor, encounterProgress, numEncounters)
			GameTooltip:AddDoubleLine(name .. " - " .. diffName .. progressStr, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	title = false
	addTitle("Reset Times")
	local dailyReset = C_DateAndTime.GetSecondsUntilDailyReset()
	if dailyReset then
		GameTooltip:AddDoubleLine("Daily Reset", SecondsToTime(dailyReset), 1, 1, 1, 0.75, 0.75, 0.75)
	end

	local weeklyReset = C_DateAndTime.GetSecondsUntilWeeklyReset()
	if weeklyReset then
		GameTooltip:AddDoubleLine(format("%s %s", WEEKLY, RESET), SecondsToTime(weeklyReset), 1, 1, 1, 0.75, 0.75, 0.75)
	end

	if IsShiftKeyDown() then
		-- Add Blood Moon STV information to tooltip
		if K.Level >= BloodMoon.level - 10 then -- Recommended level is 40 but allows level 30 players
			title = false
			addTitle("World Events")
			local status, remaining = GetBloodMoonStatus()
			GameTooltip:AddDoubleLine(BloodMoon.name, string.format("%s%s", status, remaining), 1, 1, 1, 0.75, 0.75, 0.75)
		end

		-- Add Nightmare Incursions
		title = false
		for zone, data in pairs(nightmareQuestList) do
			if K.Level >= data.level - 5 then -- Idk when you can do them, so I am assuming 5 levels below the quest level?
				addTitle("Nightmare Incursions")
				local completedCount, totalCount = GetCompletedQuestCount(zone)
				GameTooltip:AddDoubleLine(zone, string.format("%d / %d", completedCount, totalCount), 1, 1, 1, 0.75, 0.75, 0.75)
			end
		end
	end

	-- Help Info
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.LeftButton .. GAMETIME_TOOLTIP_TOGGLE_CLOCK)
	GameTooltip:AddLine(K.RightButton .. TIMEMANAGER_SHOW_STOPWATCH)
	GameTooltip:Show()

	K:RegisterEvent("MODIFIER_STATE_CHANGED", OnShiftDown)
end

local function OnLeave()
	Module.Entered = true
	K.HideTooltip()
	K:UnregisterEvent("MODIFIER_STATE_CHANGED", OnShiftDown)
end

local function OnMouseUp(_, btn)
	if btn == "RightButton" then
		if Stopwatch_Toggle then
			Stopwatch_Toggle()
		end
	elseif btn == "LeftButton" then
		TimeManager_LoadUI()
		if TimeManager_Toggle then
			TimeManager_Toggle()
		end
	end
end

function Module:CreateTimeDataText()
	if not C["DataText"].Time then
		return
	end

	if not Minimap then
		return
	end

	TimeDataText = CreateFrame("Frame", nil, UIParent)
	TimeDataText:SetFrameLevel(8)
	TimeDataText:SetHitRectInsets(0, 0, -10, -10)

	TimeDataText.Text = K.CreateFontString(TimeDataText, 13)
	TimeDataText.Text:ClearAllPoints()
	TimeDataText.Text:SetPoint("BOTTOM", _G.Minimap, "BOTTOM", 0, 2)

	TimeDataText:SetAllPoints(TimeDataText.Text)

	TimeDataText:SetScript("OnEnter", Module.OnEnter)
	TimeDataText:SetScript("OnLeave", OnLeave)
	TimeDataText:SetScript("OnMouseUp", OnMouseUp)
	TimeDataText:SetScript("OnUpdate", OnUpdate)
end
