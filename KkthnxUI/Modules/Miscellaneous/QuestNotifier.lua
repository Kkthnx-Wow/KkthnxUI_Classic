local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")


local _G = _G
local math_floor = _G.math.floor
local mod = _G.mod
local string_find = _G.string.find
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_match = _G.string.match

local ERR_QUEST_ADD_FOUND_SII = _G.ERR_QUEST_ADD_FOUND_SII
local ERR_QUEST_ADD_ITEM_SII = _G.ERR_QUEST_ADD_ITEM_SII
local ERR_QUEST_ADD_KILL_SII = _G.ERR_QUEST_ADD_KILL_SII
local ERR_QUEST_ADD_PLAYER_KILL_SII = _G.ERR_QUEST_ADD_PLAYER_KILL_SII
local ERR_QUEST_COMPLETE_S = _G.ERR_QUEST_COMPLETE_S
local ERR_QUEST_FAILED_S = _G.ERR_QUEST_FAILED_S
local ERR_QUEST_OBJECTIVE_COMPLETE_S = _G.ERR_QUEST_OBJECTIVE_COMPLETE_S
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetQuestLogTitle = _G.GetQuestLogTitle
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local IsPartyLFG = _G.IsPartyLFG
local LE_QUEST_FREQUENCY_DAILY = _G.LE_QUEST_FREQUENCY_DAILY
local PlaySound = _G.PlaySound
local QUEST_COMPLETE = _G.QUEST_COMPLETE
local SendChatMessage = _G.SendChatMessage

local soundKitID = _G.SOUNDKIT.ALARM_CLOCK_WARNING_3

local completedQuest, initComplete = {}

local function acceptText(link, daily)
	if daily then
		return string_format("%s [%s]%s", "AcceptQuest", DAILY, link)
	else
		return string_format("%s %s", "AcceptQuest", link)
	end
end

local function completeText(link)
	PlaySound(soundKitID, "Master")
	return string_format("%s %s", link, QUEST_COMPLETE)
end

local function sendQuestMsg(msg)
	if C["QuestNotifier"].OnlyCompleteRing then
		return
	end

	if K.CodeDebug then
		print(msg)
	elseif IsInRaid() then
		SendChatMessage(msg, "RAID")
	elseif IsInGroup() and not IsInRaid() then
		SendChatMessage(msg, "PARTY")
	end
end

local function getPattern(pattern)
	pattern = string_gsub(pattern, "%(", "%%%1")
	pattern = string_gsub(pattern, "%)", "%%%1")
	pattern = string_gsub(pattern, "%%%d?$?.", "(.+)")
	return string_format("^%s$", pattern)
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
	if not C["QuestNotifier"].QuestProgress then
		return
	end

	if C["QuestNotifier"].OnlyCompleteRing then
		return
	end

	for _, pattern in pairs(questMatches) do
		if string_match(msg, pattern) then
			local _, _, _, cur, max = string_find(msg, "(.*)[:：]%s*([-%d]+)%s*/%s*([-%d]+)%s*$")
			cur, max = tonumber(cur), tonumber(max)
			if cur and max and max >= 10 then
				if mod(cur, math_floor(max/5)) == 0 then
					sendQuestMsg(msg)
				end
			else
				sendQuestMsg(msg)
			end
			break
		end
	end
end

function Module:FindQuestAccept(questLogIndex, questID)
	if not C["QuestNotifier"].PickupQuest then
		return
	end

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
	if C["QuestNotifier"].Enable and not IsAddOnLoaded("QuestNotifier") then
		self:FindQuestComplete()
		K:RegisterEvent("QUEST_ACCEPTED", self.FindQuestAccept)
		K:RegisterEvent("QUEST_LOG_UPDATE", self.FindQuestComplete)
		K:RegisterEvent("UI_INFO_MESSAGE", self.FindQuestProgress)
	else
		wipe(completedQuest)
		K:UnregisterEvent("QUEST_ACCEPTED", self.FindQuestAccept)
		K:UnregisterEvent("QUEST_LOG_UPDATE", self.FindQuestComplete)
		K:UnregisterEvent("UI_INFO_MESSAGE", self.FindQuestProgress)
	end
end