local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

local strmatch, strfind, gsub, format = string.match, string.find, string.gsub, string.format
local mod, tonumber, pairs, floor = mod, tonumber, pairs, math.floor
local soundKitID = SOUNDKIT.ALARM_CLOCK_WARNING_3
local QUEST_COMPLETE, LE_QUEST_FREQUENCY_DAILY = QUEST_COMPLETE, LE_QUEST_FREQUENCY_DAILY
local GetQuestLogTitle = GetQuestLogTitle
local GetNumQuestLogEntries = GetNumQuestLogEntries

local debugMode = false
local completedQuest, initComplete = {}

local function acceptText(link, daily)
	if daily then
		return format("%s: [%s]%s", "Accepted", DAILY, link)
	else
		return format("%s: %s", "Accepted", link)
	end
end

local function completeText(link)
	PlaySound(soundKitID, "Master")
	return format("%s (%s)", link, QUEST_COMPLETE)
end

local function sendQuestMsg(msg)
	if C["Announcements"].OnlyCompleteRing then
		return
	end

	if debugMode and K.isDeveloper then
		print(msg)
	elseif IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		SendChatMessage(msg, "INSTANCE_CHAT")
	elseif IsInRaid() then
		SendChatMessage(msg, "RAID")
	elseif IsInGroup() and not IsInRaid() then
		SendChatMessage(msg, "PARTY")
	end
end

local function getPattern(pattern)
	pattern = gsub(pattern, "%(", "%%%1")
	pattern = gsub(pattern, "%)", "%%%1")
	pattern = gsub(pattern, "%%%d?$?.", "(.+)")
	return format("^%s$", pattern)
end

local questMatches = {
	["Found"] = getPattern(ERR_QUEST_ADD_FOUND_SII),
	["Item"] = getPattern(ERR_QUEST_ADD_ITEM_SII),
	["Kill"] = getPattern(ERR_QUEST_ADD_KILL_SII),
	["PKill"] = getPattern(ERR_QUEST_ADD_PLAYER_KILL_SII),
	["ObjectiveComplete"] = getPattern(ERR_QUEST_OBJECTIVE_COMPLETE_S),
	["QuestComplete"] = getPattern(ERR_QUEST_COMPLETE_S),
	["QuestFailed"] = getPattern(ERR_QUEST_FAILED_S),
}

function Module:FindQuestProgress(_, msg)
	if not C["Announcements"].QuestProgress then
		return
	end

	if C["Announcements"].OnlyCompleteRing then
		return
	end

	for _, pattern in pairs(questMatches) do
		if strmatch(msg, pattern) then
			local _, _, _, cur, max = strfind(msg, "(.*)[:：]%s*([-%d]+)%s*/%s*([-%d]+)%s*$")
			cur, max = tonumber(cur), tonumber(max)
			if cur and max and max >= 10 then
				if mod(cur, floor(max / 5)) == 0 then
					sendQuestMsg(msg)
				end
			else
				sendQuestMsg(msg)
			end
			break
		end
	end
end

function Module:FindQuestAccept(questLogIndex)
	local name, _, _, _, _, _, frequency = GetQuestLogTitle(questLogIndex)
	if name then
		sendQuestMsg(acceptText(name, frequency == LE_QUEST_FREQUENCY_DAILY))
	end
end

function Module:FindQuestComplete()
	for i = 1, GetNumQuestLogEntries() do
		local name, _, _, _, _, isComplete, _, questID = GetQuestLogTitle(i)
		if name and isComplete and not completedQuest[questID] then
			if initComplete then
				sendQuestMsg(completeText(name))
			end
			completedQuest[questID] = true
		end
	end
	initComplete = true
end

function Module:CreateQuestNotifier()
	if C["Announcements"].QuestNotifier and not K.CheckAddOnState("QuestNotifier") then
		Module:FindQuestComplete()
		K:RegisterEvent("QUEST_ACCEPTED", Module.FindQuestAccept)
		K:RegisterEvent("QUEST_LOG_UPDATE", Module.FindQuestComplete)
		K:RegisterEvent("UI_INFO_MESSAGE", Module.FindQuestProgress)
	else
		wipe(completedQuest)
		K:UnregisterEvent("QUEST_ACCEPTED", Module.FindQuestAccept)
		K:UnregisterEvent("QUEST_LOG_UPDATE", Module.FindQuestComplete)
		K:UnregisterEvent("UI_INFO_MESSAGE", Module.FindQuestProgress)
	end
end
