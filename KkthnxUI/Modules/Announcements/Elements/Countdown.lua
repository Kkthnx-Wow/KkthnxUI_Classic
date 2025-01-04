local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

local UnitName, CreateFrame, SendChatMessage, IsInGroup = UnitName, CreateFrame, SendChatMessage, IsInGroup

local frame, timerframe, firstdone, delay, target, interval, lastupdate

local function reset()
	timerframe:SetScript("OnUpdate", nil)
	firstdone, delay, target = nil, nil, nil
	lastupdate = 0
end

local function pull(_, elapsed)
	local tname = UnitName("target")
	if tname then
		target = tname
	else
		target = ""
	end
	if not firstdone then
		SendChatMessage(string.format(L["Pulling In"], target, tostring(delay)), K.CheckChat(true))
		firstdone = true
		delay = delay - 1
	end
	lastupdate = lastupdate + elapsed
	if lastupdate >= interval then
		lastupdate = 0
		if delay > 0 then
			SendChatMessage(tostring(delay) .. "..", K.CheckChat(true))
			delay = delay - 1
		else
			SendChatMessage(L["Leeeeeroy!"], K.CheckChat(true))
			reset()
		end
	end
end

local function startPull(timer)
	delay = timer or 3
	if timerframe:GetScript("OnUpdate") then
		reset()
		SendChatMessage(L["Pull ABORTED!"], K.CheckChat(true))
	else
		timerframe:SetScript("OnUpdate", pull)
	end
end

local function handleSlashCommand(msg)
	if not IsInGroup() then
		return
	end
	if tonumber(msg) ~= nil then
		startPull(msg)
	else
		startPull()
	end
end

function Module:CreatePullCountdown()
	frame = CreateFrame("Frame", "KKUI_PullCountdown")
	timerframe = CreateFrame("Frame")
	firstdone, delay, target = nil, nil, nil
	interval = 1.5
	lastupdate = 0

	frame.Pull = startPull
	SlashCmdList.PULLCOUNTDOWN = handleSlashCommand
	SLASH_PULLCOUNTDOWN1 = "/pc"
	SLASH_PULLCOUNTDOWN2 = "/jenkins"
end
