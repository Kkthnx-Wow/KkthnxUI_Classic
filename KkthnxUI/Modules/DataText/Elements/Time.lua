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

local title
local function addTitle(text)
	if not title then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(text .. ":")
		title = true
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
	GameTooltip:AddDoubleLine(L["Local Time"], GameTime_GetLocalTime(true), nil, nil, nil, 192 / 255, 192 / 255, 192 / 255)
	GameTooltip:AddDoubleLine(L["Realm Time"], GameTime_GetGameTime(true), nil, nil, nil, 192 / 255, 192 / 255, 192 / 255)

	-- Herioc/Mythic Dungeons
	title = false
	for i = 1, GetNumSavedInstances() do
		local name, _, reset, diff, locked, extended, _, _, maxPlayers, diffName, numEncounters, encounterProgress = GetSavedInstanceInfo(i)
		if (diff == 2 or diff == 23) and (locked or extended) and name then
			addTitle("Saved Dungeon(s)")
			if extended then
				r, g, b = 0.3, 1, 0.3
			else
				r, g, b = 192 / 255, 192 / 255, 192 / 255
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
				r, g, b = 192 / 255, 192 / 255, 192 / 255
			end

			local progressColor = (numEncounters == encounterProgress) and "ff0000" or "00ff00"
			local progressStr = format(" |cff%s(%s/%s)|r", progressColor, encounterProgress, numEncounters)
			GameTooltip:AddDoubleLine(name .. " - " .. diffName .. progressStr, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
		end
	end

	if GameTooltip:NumLines() > 0 then
		GameTooltip:AddLine(" ")
	end

	local dailyReset = C_DateAndTime.GetSecondsUntilDailyReset()
	if dailyReset then
		GameTooltip:AddDoubleLine("Daily Reset", SecondsToTime(dailyReset), nil, nil, nil, 192 / 255, 192 / 255, 192 / 255)
	end

	local weeklyReset = C_DateAndTime.GetSecondsUntilWeeklyReset()
	if weeklyReset then
		GameTooltip:AddDoubleLine(format("%s %s", WEEKLY, RESET), SecondsToTime(weeklyReset), nil, nil, nil, 192 / 255, 192 / 255, 192 / 255)
	end

	-- Help Info
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(K.LeftButton .. GAMETIME_TOOLTIP_TOGGLE_CALENDAR)
	GameTooltip:AddLine(K.RightButton .. TIMEMANAGER_SHOW_STOPWATCH)
	GameTooltip:Show()
end

local function OnLeave()
	Module.Entered = true
	K.HideTooltip()
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
