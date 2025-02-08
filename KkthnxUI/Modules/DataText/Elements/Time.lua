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

-- Function to calculate the reset day of the week
local function GetResetDay(resetSeconds)
	local currentTime = time() -- Current Unix time
	local resetTime = currentTime + resetSeconds
	local weekday = date("%A", resetTime) -- Get the day of the week
	return weekday
end

-- Function to format remaining time into days, hours, and minutes
local function FormatTimeRemaining(reset)
	local days = math.floor(reset / 86400) -- Convert seconds to days
	local hours = math.floor((reset % 86400) / 3600) -- Convert remaining seconds to hours
	local minutes = math.floor((reset % 3600) / 60) -- Convert remaining seconds to minutes

	return string.format("%d days, %d hours, %d minutes", days, hours, minutes)
end

-- Function to determine raid name color
local function GetRaidColor(name)
	if name:lower():find("molten core") then
		return "|cFFFF7D0A" -- Orange
	elseif name:lower():find("blackwing lair") then
		return "|cFF707070" -- Lighter Grey (Better contrast)
	elseif name:lower():find("ahn'quiraj") or name:lower():find("aq") then
		return "|cFF00FF00" -- Green
	elseif name:lower():find("naxxramas") then
		return "|cFF0070DD" -- Blue
	end
	return "|cFFFFFFFF" -- White for other raids
end

-- Function to update lockouts
local function UpdateLockouts()
	local raidLockoutText = "|cFFFFD100Raids:|r\n"
	local dungeonLockoutText = "|cFFFFD100Dungeons:|r\n"
	local hasRaids, hasDungeons = false, false

	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, _, _, _, _, _, difficulty = GetSavedInstanceInfo(i)
		local reset = tonumber(reset)
		local difficulty = tonumber(difficulty)

		-- Skip invalid entries
		if difficulty == 1 or difficulty == 2 then
			-- Skip Normal and Heroic for Classic clients
		else
			local resetFormatted = FormatTimeRemaining(reset)
			local resetDay = reset and GetResetDay(reset) or "Unknown"

			-- Ensure we don't display "Unknown" for Classic's Normal difficulty
			local difficultyName = "Normal"

			local raidColor = GetRaidColor(name or "Unknown Instance")

			local lockoutText = string.format("%s%s (%s)\n%s\nResets on |cFFFFFFFF%s|r\n", raidColor, name or "Unknown Instance", difficultyName, resetFormatted, resetDay)

			raidLockoutText = raidLockoutText .. lockoutText
			hasRaids = true
		end
	end

	local finalText = ""
	if hasRaids then
		finalText = finalText .. raidLockoutText .. "\n"
	end
	if finalText == "" then
		finalText = "No active lockouts."
	end

	content:SetText(finalText)
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

	local raidLockoutText = "|cFFFFD100Raids:|r\n"
	local hasRaids = false

	for i = 1, GetNumSavedInstances() do
		local name, _, reset, _, _, _, _, _, _, difficulty = GetSavedInstanceInfo(i)
		local reset = tonumber(reset)
		local difficulty = tonumber(difficulty)

		-- Skip invalid entries
		if difficulty == 1 or difficulty == 2 then
			-- Skip Normal and Heroic for Classic clients
		else
			local resetFormatted = FormatTimeRemaining(reset)
			local resetDay = reset and GetResetDay(reset) or "Unknown"

			-- Ensure we don't display "Unknown" for Classic's Normal difficulty
			local difficultyName = "Normal"

			local raidColor = GetRaidColor(name or "Unknown Instance")

			local lockoutText = string.format("%s%s (%s)\n%s\nResets on |cFFFFFFFF%s|r\n", raidColor, name or "Unknown Instance", difficultyName, resetFormatted, resetDay)

			raidLockoutText = raidLockoutText .. lockoutText
			hasRaids = true
		end
	end

	local finalText = ""
	if hasRaids then
		finalText = finalText .. raidLockoutText .. "\n"
	end

	if finalText == "" then
		finalText = "No active lockouts."
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(finalText, 0.75, 0.75, 0.75)

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
