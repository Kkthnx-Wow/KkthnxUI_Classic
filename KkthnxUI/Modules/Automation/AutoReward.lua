local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local CreateFrame = _G.CreateFrame
local GetQuestItemLink = _G.GetQuestItemLink
local GetQuestItemInfo = _G.GetQuestItemInfo
local GetItemInfo = _G.GetItemInfo
local GetNumQuestChoices = _G.GetNumQuestChoices

local _
local bestValue, totalValue, bestItem, itemSellPrice
local questLink, amount, numQuests

function Module:QUEST_COMPLETE()
	if not C["Automation"].AutoReward then
		return
	end

	bestValue = 0
	numQuests = GetNumQuestChoices()

	if numQuests <= 0 then
		return -- no choices, quick exit
	end

	if not self.QuestRewardGoldIconFrame then
		local frame = CreateFrame("Frame", nil, _G.QuestInfoRewardsFrameQuestInfoItem1)
		frame:SetFrameStrata("HIGH")
		frame:SetSize(20, 20)
		frame:Hide()
		frame.Icon = frame:CreateTexture(nil, "OVERLAY")
		frame.Icon:SetAllPoints(frame)
		frame.Icon:SetTexture("Interface\\MONEYFRAME\\UI-GoldIcon")
		self.QuestRewardGoldIconFrame = frame
	end

	self.QuestRewardGoldIconFrame:Hide()

	for i = 1, numQuests do
		questLink = GetQuestItemLink("choice", i)
		_, _, amount = GetQuestItemInfo("choice", i)
		itemSellPrice = questLink and select(11, GetItemInfo(questLink))

		totalValue = (itemSellPrice and itemSellPrice * amount) or 0
		if totalValue > bestValue then
			bestValue = totalValue
			bestItem = i
		end
	end

	if bestItem then
		local btn = _G["QuestInfoRewardsFrameQuestInfoItem"..bestItem]
		if btn.type == "choice" then
			self.QuestRewardGoldIconFrame:ClearAllPoints()
			self.QuestRewardGoldIconFrame:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
			self.QuestRewardGoldIconFrame:Show()
		end
	end
end

function Module:CreateAutoReward()
	if not C["Automation"].AutoReward then
		return
	end

	K:RegisterEvent("QUEST_COMPLETE", self.QUEST_COMPLETE)
end