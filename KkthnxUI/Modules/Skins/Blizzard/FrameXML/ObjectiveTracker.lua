local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

local _G = _G
local pairs, tinsert, tremove, select = pairs, table.insert, table.remove, select
local GetNumQuestLogEntries, GetNumQuestWatches = GetNumQuestLogEntries, GetNumQuestWatches
local IsShiftKeyDown, RemoveQuestWatch, ShowUIPanel, GetCVarBool = IsShiftKeyDown, RemoveQuestWatch, ShowUIPanel, GetCVarBool
local GetQuestIndexForWatch, GetNumQuestLeaderBoards, GetQuestLogLeaderBoard = GetQuestIndexForWatch, GetNumQuestLeaderBoards, GetQuestLogLeaderBoard

local MAX_QUESTLOG_QUESTS = MAX_QUESTLOG_QUESTS or 20
local MAX_WATCHABLE_QUESTS = MAX_WATCHABLE_QUESTS or 5
local headerString = QUESTS_LABEL .. " %s/%s"

-- Local cache for performance
local frame

function Module:EnhancedQuestTracker()
	if not frame then
		return
	end -- Ensure frame exists before proceeding

	local header = CreateFrame("Frame", nil, frame)
	header:SetAllPoints()
	header:SetParent(QuestWatchFrame)
	header.Text = K.CreateFontString(header, 16, nil, nil, true, "TOPLEFT", 0, 15)

	local bu = CreateFrame("Button", nil, frame)
	bu:SetSize(18, 18)
	bu:SetPoint("TOPRIGHT", 0, 18)
	bu.collapse = false
	bu:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
	bu:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
	bu:SetShown(GetNumQuestWatches() > 0)

	bu.Text = K.CreateFontString(bu, 16, TRACKER_HEADER_OBJECTIVE, nil, "system", "RIGHT", -24, 0)
	bu.Text:Hide()

	bu:SetScript("OnClick", function(self)
		self.collapse = not self.collapse
		if self.collapse then
			self:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up")
			self.Text:Show()
			QuestWatchFrame:Hide()
		else
			self:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up")
			self.Text:Hide()
			if GetNumQuestWatches() > 0 then
				QuestWatchFrame:Show()
			end
		end
	end)

	local ClickFrames = setmetatable({}, { __mode = "k" }) -- Weak table for ClickFrames

	local function onMouseUp(self)
		if IsShiftKeyDown() then
			local questID = GetQuestIDFromLogIndex(self.questIndex)
			for index, value in ipairs(QUEST_WATCH_LIST) do
				if value.id == questID then
					tremove(QUEST_WATCH_LIST, index)
					break
				end
			end
			RemoveQuestWatch(self.questIndex)
		else
			local questLogFrame = QuestLogExFrame or ClassicQuestLog or QuestGuru_QuestLog or QuestLogFrame
			ShowUIPanel(questLogFrame)

			if QuestLogEx then
				QuestLogEx:QuestLog_SetSelection(self.questIndex)
				QuestLogEx:Maximize()
			elseif ClassicQuestLog then
				QuestLog_SetSelection(self.questIndex)
			elseif QuestGuru then
				QuestGuru_QuestLog_SetSelection(self.questIndex)
			else
				QuestLog_SetSelection(self.questIndex)
				local valueStep = QuestLogListScrollFrame.ScrollBar:GetValueStep()
				QuestLogListScrollFrame.ScrollBar:SetValue((self.questIndex - 1) * valueStep)
			end
		end
		QuestLog_Update()
	end

	local function onEnter(self)
		local r, g, b = self.completed and { 0.75, 0.61, 0 } or { 1, 0.8, 0 }
		self.headerText:SetTextColor(unpack(r, g, b))
		for _, text in ipairs(self.objectiveTexts) do
			text:SetTextColor(self.completed and 0.8 or 1, self.completed and 0.8 or 1, self.completed and 0.8 or 1)
		end
	end

	local function SetClickFrame(watchIndex, questIndex, headerText, objectiveTexts, completed)
		local f = ClickFrames[watchIndex] or CreateFrame("Frame")
		f:SetAllPoints(headerText)
		f.watchIndex = watchIndex
		f.questIndex = questIndex
		f.headerText = headerText
		f.objectiveTexts = objectiveTexts
		f.completed = completed
		f:SetScript("OnMouseUp", onMouseUp)
		f:SetScript("OnEnter", onEnter)
		f:SetScript("OnLeave", QuestWatch_Update)
		ClickFrames[watchIndex] = f
	end

	hooksecurefunc("QuestWatch_Update", function()
		local numQuests = select(2, GetNumQuestLogEntries())
		header.Text:SetFormattedText(headerString, numQuests, MAX_QUESTLOG_QUESTS)

		local watchTextIndex = 1
		local numWatches = GetNumQuestWatches()
		for i = 1, numWatches do
			local questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				local numObjectives = GetNumQuestLeaderBoards(questIndex)
				if numObjectives > 0 then
					local headerText = _G["QuestWatchLine" .. watchTextIndex]
					if watchTextIndex > 1 then
						headerText:SetPoint("TOPLEFT", "QuestWatchLine" .. (watchTextIndex - 1), "BOTTOMLEFT", 0, -10)
					end
					watchTextIndex = watchTextIndex + 1
					local objectivesGroup = {}
					local objectivesCompleted = 0
					for j = 1, numObjectives do
						local finished = select(3, GetQuestLogLeaderBoard(j, questIndex))
						if finished then
							objectivesCompleted = objectivesCompleted + 1
						end
						local objLine = _G["QuestWatchLine" .. watchTextIndex]
						objLine:SetPoint("TOPLEFT", "QuestWatchLine" .. (watchTextIndex - 1), "BOTTOMLEFT", 0, -5)
						tinsert(objectivesGroup, objLine)
						watchTextIndex = watchTextIndex + 1
					end
					SetClickFrame(i, questIndex, headerText, objectivesGroup, objectivesCompleted == numObjectives)
				end
			end
		end

		for _, frame in pairs(ClickFrames) do
			frame[(GetQuestIndexForWatch(frame.watchIndex) and "Show" or "Hide")](frame)
		end

		bu:SetShown(numWatches > 0)
		if bu.collapse then
			QuestWatchFrame:Hide()
		end
	end)

	local function autoQuestWatch(_, questIndex)
		if GetCVarBool("autoQuestWatch") and GetNumQuestLeaderBoards(questIndex) ~= 0 and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS then
			AddQuestWatch(questIndex)
		end
	end
	K:RegisterEvent("QUEST_ACCEPTED", autoQuestWatch)
end

function Module:QuestTracker()
	frame = CreateFrame("Frame", "KKUI_QuestMover", UIParent)
	frame:SetSize(240, 50)
	K.Mover(frame, "QuestTracker", "QuestTracker", { "TOPRIGHT", Minimap, "BOTTOMRIGHT", -150, -260 })

	QuestWatchFrame:SetHeight(GetScreenHeight() * 0.65)
	QuestWatchFrame:SetClampedToScreen(false)
	QuestWatchFrame:SetMovable(true)

	local function QuestFrameReset(self, _, parent)
		if parent ~= frame then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", frame, 5, -5)
		end
	end

	QuestFrameReset(QuestWatchFrame)
	hooksecurefunc(QuestWatchFrame, "SetPoint", QuestFrameReset)

	if not C["Skins"].QuestTracker then
		return
	end

	self:EnhancedQuestTracker()
end
