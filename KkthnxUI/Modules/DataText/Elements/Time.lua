-- Constants and module setup
local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- Local references to global functions for performance
local date = date
local string_format = string.format
local tonumber = tonumber

-- API calls
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

-- UI element for time display
local TimeDataText

-- Helper function to format the time display
local function updateTimerFormat(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return string_format(color .. TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local amPm = K.MyClassColor .. (hour < 12 and TIMEMANAGER_AM or TIMEMANAGER_PM)

		-- Convert hour to 12-hour format
		hour = hour % 12
		if hour == 0 then
			hour = 12
		end

		return string_format(color .. TIMEMANAGER_TICKER_12HOUR .. amPm, hour, minute)
	end
end

-- Timer for updating the time display
local onUpdateTimer = 0

-- Update function for the time display
local function OnUpdate(self, elapsed)
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
		onUpdateTimer = 0 -- Reset timer
	end
end

-- Helper function for adding titles to tooltips
local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text .. ":")
		title = true
	end
end

-- Function to handle tooltip display when hovering over the time datatext
function Module:OnEnter()
	Module.Entered = true
	RequestRaidInfo()

	GameTooltip:SetOwner(TimeDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(TimeDataText))
	GameTooltip:ClearLines()

	local today = C_DateAndTime_GetCurrentCalendarTime()
	local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
	GameTooltip:AddLine(string_format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0.4, 0.6, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), nil, nil, nil, 0.75, 0.75, 0.75)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), nil, nil, nil, 0.75, 0.75, 0.75)

	-- Define a table for raid difficulties
	local RAID_DIFFICULTIES = { 2, 23, 148, 174, 185, 198, 201, 215 }

	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diff, locked, extended, _, isRaid, maxPlayers, diffName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)

		-- Check if the instance is a raid with the specific difficulties
		if tContains(RAID_DIFFICULTIES, diff) and (locked or extended) then
			addTitle(L["Saved Raid(s)"])
			local r, g, b = extended and { 0.3, 1, 0.3 } or { 0.75, 0.75, 0.75 }

			local progressColor = (numEncounters == encounterProgress) and "ff0000" or "00ff00"
			local progressStr = format(" |cff%s(%s/%s)|r", progressColor, encounterProgress, numEncounters)
			GameTooltip:AddDoubleLine(name .. " - " .. diffName .. progressStr, SecondsToTime(reset, true, nil, 3), 1, 1, 1, unpack(r, g, b))
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

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.LeftButton .. GAMETIME_TOOLTIP_TOGGLE_CLOCK)
	GameTooltip:AddLine(K.RightButton .. TIMEMANAGER_SHOW_STOPWATCH)
	GameTooltip:Show()
end

-- Hide tooltip when mouse leaves the datatext
local function OnLeave()
	Module.Entered = false
	K.HideTooltip()
end

-- Handle mouse clicks on the time datatext
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

-- Create and setup the time datatext
function Module:CreateTimeDataText()
	if not C["DataText"].Time or not Minimap then
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
