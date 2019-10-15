local K, C = unpack(select(2, ...))
if C["Automation"].AutoQuest ~= true then
	return
end

local _G = _G
local next = _G.next
local select = _G.select
local string_match = _G.string.match
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber

local AcceptQuest = _G.AcceptQuest
local CompleteQuest = _G.CompleteQuest
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetActiveTitle = _G.GetActiveTitle
local GetGossipActiveQuests = _G.GetGossipActiveQuests
local GetGossipAvailableQuests = _G.GetGossipAvailableQuests
local GetGossipOptions = _G.GetGossipOptions
local GetInstanceInfo = _G.GetInstanceInfo
local GetItemInfo = _G.GetItemInfo
local GetNumActiveQuests = _G.GetNumActiveQuests
local GetNumAvailableQuests = _G.GetNumAvailableQuests
local GetNumGossipActiveQuests = _G.GetNumGossipActiveQuests
local GetNumGossipAvailableQuests = _G.GetNumGossipAvailableQuests
local GetNumGossipOptions = _G.GetNumGossipOptions
local GetNumQuestChoices = _G.GetNumQuestChoices
local GetNumQuestItems = _G.GetNumQuestItems
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetQuestID = _G.GetQuestID
local GetQuestItemInfo = _G.GetQuestItemInfo
local GetQuestItemLink = _G.GetQuestItemLink
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetQuestReward = _G.GetQuestReward
local GetQuestTagInfo = _G.GetQuestTagInfo
local GetRealmName = _G.GetRealmName
local IsQuestCompletable = _G.IsQuestCompletable
local IsShiftKeyDown = _G.IsShiftKeyDown
local QuestInfoItem_OnClick = _G.QuestInfoItem_OnClick
local SelectActiveQuest = _G.SelectActiveQuest
local SelectAvailableQuest = _G.SelectAvailableQuest
local SelectGossipActiveQuest = _G.SelectGossipActiveQuest
local SelectGossipAvailableQuest = _G.SelectGossipAvailableQuest
local SelectGossipOption = _G.SelectGossipOption
local UnitGUID = _G.UnitGUID
local UnitName = _G.UnitName

local created
local function setupCheckButton()
	if created then return end
	local mono = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame, "OptionsCheckButtonTemplate")
	mono:SetPoint("TOPRIGHT", -140, 0)
	mono:SetSize(24, 24)
	mono.text = mono:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	mono.text:SetPoint("LEFT", 24, 0)
	mono.text:SetText("Auto Quest")
	mono:SetHitRectInsets(0, 0 - mono.text:GetWidth(), 0, 0)
	mono:SetChecked(KkthnxUIData[GetRealmName()][UnitName("player")].AutoQuest)
	mono:SetScript("OnClick", function(self)
		KkthnxUIData[GetRealmName()][UnitName("player")].AutoQuest = self:GetChecked()
	end)

	created = true

	function mono.UpdateTooltip(self)
		if (GameTooltip:IsForbidden()) then
			return
		end

		GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)

		local r, g, b = 0.2, 1.0, 0.2

		if KkthnxUIData[GetRealmName()][UnitName("player")].AutoQuest == true then
			GameTooltip:AddLine("Disable Auto Accept")
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Disable to not auto accept.", r, g, b)
		else
			GameTooltip:AddLine("Enable Auto Accept")
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Enable to auto accept.", r, g, b)
		end

		GameTooltip:Show()
	end

	mono:HookScript("OnEnter", function(self)
		if (GameTooltip:IsForbidden()) then
			return
		end

		self:UpdateTooltip()
	end)

	mono:HookScript("OnLeave", function()
		if (GameTooltip:IsForbidden()) then
			return
		end

		GameTooltip:Hide()
	end)

	mono:SetScript("OnClick", function(self)
		KkthnxUIData[GetRealmName()][UnitName("player")].AutoQuest = self:GetChecked()
	end)
end
WorldMapFrame:HookScript("OnShow", setupCheckButton)

local quests, choiceQueue = {}
local QuickQuest = CreateFrame("Frame")
QuickQuest:SetScript("OnEvent", function(self, event, ...) self[event](...) end)

function QuickQuest:Register(event, func)
	self:RegisterEvent(event)
	self[event] = function(...)
		if KkthnxUIData[GetRealmName()][UnitName("player")].AutoQuest and not IsShiftKeyDown() then
			func(...)
		end
	end
end

local function GetNPCID()
	return K.GetNPCID(UnitGUID("npc"))
end

local function GetQuestLogQuests(onlyComplete)
	table_wipe(quests)

	for index = 1, GetNumQuestLogEntries() do
		local title, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(index)
		if (not isHeader) then
			if (onlyComplete and isComplete or not onlyComplete) then
				quests[title] = questID
			end
		end
	end

	return quests
end

QuickQuest:Register("QUEST_GREETING", function()
	local npcID = GetNPCID()
	if (K.QuickQuest_IgnoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumActiveQuests()
	if (active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, complete = GetActiveTitle(index)
			if (complete) then
				local questID = logQuests[name]
				if (not questID) then
					SelectActiveQuest(index)
				else
					local _, _, worldQuest = GetQuestTagInfo(questID)
					if (not worldQuest) then
						SelectActiveQuest(index)
					end
				end
			end
		end
	end

	local available = GetNumAvailableQuests()
	if (available > 0) then
		for index = 1, available do
			local isTrivial = IsActiveQuestTrivial(index)
			if not isTrivial then
				SelectAvailableQuest(index)
			end
		end
	end
end)

-- This should be part of the API, really
local function GetAvailableGossipQuestInfo(index)
	local name, level, isTrivial, frequency, isRepeatable, isLegendary, isIgnored = select(((index * 7) - 7) + 1, GetGossipAvailableQuests())
	return name, level, isTrivial, isIgnored, isRepeatable, frequency == 2, frequency == 3, isLegendary
end

local function GetActiveGossipQuestInfo(index)
	local name, level, isTrivial, isComplete, isLegendary, isIgnored = select(((index * 6) - 6) + 1, GetGossipActiveQuests())
	return name, level, isTrivial, isIgnored, isComplete, isLegendary
end

QuickQuest:Register("GOSSIP_SHOW", function()
	local npcID = GetNPCID()
	if (K.QuickQuest_IgnoreQuestNPC[npcID]) then
		return
	end

	local active = GetNumGossipActiveQuests()
	if (active > 0) then
		local logQuests = GetQuestLogQuests(true)
		for index = 1, active do
			local name, _, _, _, complete = GetActiveGossipQuestInfo(index)
			if (complete) then
				local questID = logQuests[name]
				if (not questID) then
					SelectGossipActiveQuest(index)
				else
					local _, _, worldQuest = GetQuestTagInfo(questID)
					if (not worldQuest) then
						SelectGossipActiveQuest(index)
					end
				end
			end
		end
	end

	local available = GetNumGossipAvailableQuests()
	if (available > 0) then
		for index = 1, available do
			local _, _, trivial, ignored = GetAvailableGossipQuestInfo(index)
			if (not trivial and not ignored) then
				SelectGossipAvailableQuest(index)
			end
		end
	end

	if (K.QuickQuest_RogueClassHallInsignia[npcID]) then
		return SelectGossipOption(1)
	end

	if (available == 0 and active == 0) then
		if GetNumGossipOptions() == 1 then
			-- if (npcID == 57850) then
			-- 	return SelectGossipOption(1)
			-- end

			local _, instance, _, _, _, _, _, mapID = GetInstanceInfo()
			if (instance ~= "raid" and not K.QuickQuest_IgnoreGossipNPC[npcID] and not (instance == "scenario" and mapID == 1626)) then
				local _, type = GetGossipOptions()
				if (type == "gossip") then
					SelectGossipOption(1)
					return
				end
			end
		elseif K.QuickQuest_FollowerAssignees[npcID] and GetNumGossipOptions() > 1 then
			return SelectGossipOption(1)
		end
	end
end)

-- We will keep this because Classic will have DMF
-- local darkmoonNPC = {
-- 	[57850] = true, -- Teleportologist Fozlebub
-- 	[55382] = true, -- Darkmoon Faire Mystic Mage (Horde)
-- 	[54334] = true, -- Darkmoon Faire Mystic Mage (Alliance)
-- }

-- QuickQuest:Register("GOSSIP_CONFIRM", function(index)
-- 	local npcID = GetNPCID()
-- 	if (npcID and darkmoonNPC[npcID]) then
-- 		SelectGossipOption(index, "", true)
-- 		StaticPopup_Hide("GOSSIP_CONFIRM")
-- 	end
-- end)

QuickQuest:Register("QUEST_DETAIL", function()
	AcceptQuest()
end)

QuickQuest:Register("QUEST_ACCEPT_CONFIRM", AcceptQuest)

QuickQuest:Register("QUEST_ACCEPTED", function()
	if QuestFrame:IsShown() then
		CloseQuest()
	end
end)

QuickQuest:Register("QUEST_ITEM_UPDATE", function()
	if (choiceQueue and QuickQuest[choiceQueue]) then
		QuickQuest[choiceQueue]()
	end
end)

QuickQuest:Register("QUEST_PROGRESS", function()
	if (IsQuestCompletable()) then
		local id, _, worldQuest = GetQuestTagInfo(GetQuestID())
		if id == 153 or worldQuest then
			return
		end

		local npcID = GetNPCID()
		if K.QuickQuest_IgnoreProgressNPC[npcID] then
			return
		end

		local requiredItems = GetNumQuestItems()
		if (requiredItems > 0) then
			for index = 1, requiredItems do
				local link = GetQuestItemLink("required", index)
				if (link) then
					local id = tonumber(string_match(link, "item:(%d+)"))
					for _, itemID in next, K.QuickQuest_ItemBlacklist do
						if(itemID == id) then
							return
						end
					end
				else
					choiceQueue = "QUEST_PROGRESS"
					return
				end
			end
		end

		CompleteQuest()
	end
end)

QuickQuest:Register("QUEST_COMPLETE", function()
	local choices = GetNumQuestChoices()
	if (choices <= 1) then
		GetQuestReward(1)
	elseif (choices > 1) then
		local bestValue, bestIndex = 0
		for index = 1, choices do
			local link = GetQuestItemLink("choice", index)
			if(link) then
				local _, _, _, _, _, _, _, _, _, _, value = GetItemInfo(link)
				value = K.QuickQuest_CashRewards[tonumber(string_match(link, "item:(%d+):"))] or value

				if (value > bestValue) then
					bestValue, bestIndex = value, index
				end
			else
				choiceQueue = "QUEST_COMPLETE"
				return GetQuestItemInfo("choice", index)
			end
		end

		local button = bestIndex and QuestInfoRewardsFrame.RewardButtons[bestIndex]
		if button then
			QuestInfoItem_OnClick(button)
		end
	end
end)

local function AttemptAutoComplete(event)
	K.Delay(1, AttemptAutoComplete)

	if(event == "PLAYER_REGEN_ENABLED") then
		QuickQuest:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
end
QuickQuest:Register("PLAYER_LOGIN", AttemptAutoComplete)
QuickQuest:Register("QUEST_AUTOCOMPLETE", AttemptAutoComplete)