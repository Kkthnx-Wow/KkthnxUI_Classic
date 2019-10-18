local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local table_insert = _G.table.insert
local table_remove = _G.table.remove

local CreateFrame = _G.CreateFrame
local FauxScrollFrame_GetOffset = _G.FauxScrollFrame_GetOffset
local GetCVarBool = _G.GetCVarBool
local GetNumQuestLeaderBoards = _G.GetNumQuestLeaderBoards
local GetNumQuestLogEntries = _G.GetNumQuestLogEntries
local GetNumQuestWatches = _G.GetNumQuestWatches
local GetQuestIDFromLogIndex = _G.GetQuestIDFromLogIndex
local GetQuestIndexForWatch = _G.GetQuestIndexForWatch
local GetQuestLogLeaderBoard = _G.GetQuestLogLeaderBoard
local GetQuestLogTitle = _G.GetQuestLogTitle
local IsShiftKeyDown = _G.IsShiftKeyDown
local PlaySound = _G.PlaySound
local SOUNDKIT_IG_MAINMENU_OPTION_CHECKBOX_ON = _G.SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON
local hooksecurefunc = _G.hooksecurefunc

local MAX_QUESTLOG_QUESTS = _G.MAX_QUESTLOG_QUESTS or 20
local MAX_WATCHABLE_QUESTS = _G.MAX_WATCHABLE_QUESTS or 5
local headerString = _G.QUESTS_LABEL.." %s/%s"

local frame
function Module:QuestLogLevel()
	local numEntries = GetNumQuestLogEntries()

	for i = 1, QUESTS_DISPLAYED, 1 do
		local questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
		if questIndex <= numEntries then
			local questLogTitle = _G["QuestLogTitle"..i]
			local questTitleTag = _G["QuestLogTitle"..i.."Tag"]
			local questLogTitleText, level, _, isHeader, _, isComplete = GetQuestLogTitle(questIndex)

			if not isHeader then
				questLogTitle:SetText("["..level.."] "..questLogTitleText)
				if isComplete then
					questLogTitle.r = 1
					questLogTitle.g = .5
					questLogTitle.b = 1
					questTitleTag:SetTextColor(1, .5, 1)
				end
			end

			local questText = _G["QuestLogTitle"..i.."NormalText"]
			local questCheck = _G["QuestLogTitle"..i.."Check"]
			if questText then
				local width = questText:GetStringWidth()
				if width then
					if width <= 210 then
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", width + 22, 0)
					else
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", 210, 0)
					end
				end
			end

			local questNumGroupMates = _G["QuestLogTitle"..i.."GroupMates"]
			if not questNumGroupMates.anchored then
				questNumGroupMates:SetPoint("LEFT")
				questNumGroupMates.anchored = true
			end
		end
	end
end

function Module:EnhancedQuestTracker()
	local header = CreateFrame("Frame", nil, frame)
	header:SetAllPoints()
	header:SetParent(QuestWatchFrame)
	header.Text = K.CreateFontString(header, 14, "", "", true, "TOPLEFT", 0, 15)

	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetVertexColor(K.r, K.g, K.b, .8)
	bg:SetPoint("TOPLEFT", 0, 20)
	bg:SetSize(250, 30)

	local bu = CreateFrame("Button", nil, frame)
	bu:SetSize(20, 20)
	bu:SetPoint("TOPRIGHT", 0, 18)
	bu.collapse = false
	bu:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	bu:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	bu:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
	bu:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)
	bu:SetHighlightTexture(false or "")
	bu:SetShown(GetNumQuestWatches() > 0)

	bu.Text = K.CreateFontString(bu, 14, TRACKER_HEADER_OBJECTIVE, "", "system", "RIGHT", -24, 0)
	bu.Text:Hide()

	bu:SetScript("OnClick", function(self)
		self.collapse = not self.collapse
		PlaySound(SOUNDKIT_IG_MAINMENU_OPTION_CHECKBOX_ON)
		if self.collapse then
			self:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
			self:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
			self:GetPushedTexture():SetTexCoord(0.5, 1, 0, 0.5)
			self.Text:Show()
			QuestWatchFrame:Hide()
		else
			self:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
			self:GetNormalTexture():SetTexCoord(0, 0.5, 0.5, 1)
			self:GetPushedTexture():SetTexCoord(0.5, 1, 0.5, 1)
			self.Text:Hide()
			if GetNumQuestWatches() > 0 then
				QuestWatchFrame:Show()
			end
		end
	end)

	-- ModernQuestWatch, Ketho
	local function onMouseUp(self)
		if IsShiftKeyDown() then -- untrack quest
			local questID = GetQuestIDFromLogIndex(self.questIndex)
			for index, value in ipairs(QUEST_WATCH_LIST) do
				if value.id == questID then
					table_remove(QUEST_WATCH_LIST, index)
				end
			end
			RemoveQuestWatch(self.questIndex)
			QuestWatch_Update()
		else -- open to quest log
			if QuestLogEx then -- https://www.wowinterface.com/downloads/info24980-QuestLogEx.html
				ShowUIPanel(QuestLogExFrame)
				QuestLogEx:QuestLog_SetSelection(self.questIndex)
				QuestLogEx:Maximize()
			elseif ClassicQuestLog then -- https://www.wowinterface.com/downloads/info24937-ClassicQuestLogforClassic.html
				ShowUIPanel(ClassicQuestLog)
				QuestLog_SetSelection(self.questIndex)
			elseif QuestGuru then -- https://www.curseforge.com/wow/addons/questguru_classic
				ShowUIPanel(QuestGuru)
				QuestLog_SetSelection(self.questIndex)
			else
				ShowUIPanel(QuestLogFrame)
				QuestLog_SetSelection(self.questIndex)
				local valueStep = QuestLogListScrollFrame.ScrollBar:GetValueStep()
				QuestLogListScrollFrame.ScrollBar:SetValue(self.questIndex*valueStep/2)
			end
		end
		QuestLog_Update()
	end

	local function onEnter(self)
		if self.completed then
			-- use normal colors instead as highlight
			self.headerText:SetTextColor(.75, .61, 0)
			for _, text in ipairs(self.objectiveTexts) do
				text:SetTextColor(.8, .8, .8)
			end
		else
			self.headerText:SetTextColor(1, .8, 0)
			for _, text in ipairs(self.objectiveTexts) do
				text:SetTextColor(1, 1, 1)
			end
		end
	end

	local ClickFrames = {}
	local function SetClickFrame(watchIndex, questIndex, headerText, objectiveTexts, completed)
		if not ClickFrames[watchIndex] then
			ClickFrames[watchIndex] = CreateFrame("Frame")
			ClickFrames[watchIndex]:SetScript("OnMouseUp", onMouseUp)
			ClickFrames[watchIndex]:SetScript("OnEnter", onEnter)
			ClickFrames[watchIndex]:SetScript("OnLeave", QuestWatch_Update)
		end

		local f = ClickFrames[watchIndex]
		f:SetAllPoints(headerText)
		f.watchIndex = watchIndex
		f.questIndex = questIndex
		f.headerText = headerText
		f.objectiveTexts = objectiveTexts
		f.completed = completed
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
					local headerText = _G["QuestWatchLine"..watchTextIndex]
					if watchTextIndex > 1 then
						headerText:SetPoint("TOPLEFT", "QuestWatchLine"..(watchTextIndex - 1), "BOTTOMLEFT", 0, -10)
					end
					watchTextIndex = watchTextIndex + 1
					local objectivesGroup = {}
					local objectivesCompleted = 0
					for j = 1, numObjectives do
						local finished = select(3, GetQuestLogLeaderBoard(j, questIndex))
						if finished then
							objectivesCompleted = objectivesCompleted + 1
						end
						_G["QuestWatchLine"..watchTextIndex]:SetPoint("TOPLEFT", "QuestWatchLine"..(watchTextIndex - 1), "BOTTOMLEFT", 0, -5)
						table_insert(objectivesGroup, _G["QuestWatchLine"..watchTextIndex])
						watchTextIndex = watchTextIndex + 1
					end
					SetClickFrame(i, questIndex, headerText, objectivesGroup, objectivesCompleted == numObjectives)
				end
			end
		end
		-- hide/show frames so it doesnt eat clicks, since we cant parent to a FontString
		for _, frame in pairs(ClickFrames) do
			frame[GetQuestIndexForWatch(frame.watchIndex) and "Show" or "Hide"](frame)
		end

		bu:SetShown(numWatches > 0)
		if bu.collapse then
			QuestWatchFrame:Hide()
		end
	end)

	local function autoQuestWatch(_, questIndex)
		-- tracking otherwise untrackable quests (without any objectives) would still count against the watch limit
		-- calling AddQuestWatch() while on the max watch limit silently fails
		if GetCVarBool("autoQuestWatch") and GetNumQuestLeaderBoards(questIndex) ~= 0 and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS then
			AutoQuestWatch_Insert(questIndex, QUEST_WATCH_NO_EXPIRE)
		end
	end
	K:RegisterEvent("QUEST_ACCEPTED", autoQuestWatch)
end

function Module:QuestTracker()
	-- Mover for quest tracker
	frame = CreateFrame("Frame", "KKUIQuestMover", UIParent)
	frame:SetSize(240, 50)
	K.Mover(frame, "QuestTracker", "QuestTracker", {"TOPRIGHT", Minimap, "BOTTOMRIGHT", -130, -100})

	-- QuestWatchFrame:SetHeight(GetScreenHeight()*.65)
	QuestWatchFrame:SetClampedToScreen(false)
	QuestWatchFrame:SetMovable(true)
	QuestWatchFrame:SetUserPlaced(true)

	hooksecurefunc(QuestWatchFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == _G.MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", frame, 5, -5)
		end
	end)

	local timerMover = CreateFrame("Frame", "KKUIQuestTimerMover", UIParent)
	timerMover:SetSize(150, 30)
	K.Mover(timerMover, QUEST_TIMERS, "QuestTimer", {"TOPRIGHT", frame, "TOPLEFT", -10, 0})

	hooksecurefunc(QuestTimerFrame, "SetPoint", function(self, _, parent)
		if parent ~= timerMover then
			self:ClearAllPoints()
			self:SetPoint("TOP", timerMover)
		end
	end)

	-- if not C["Skins"].QuestTracker then
	-- 	return
	-- end

	Module:EnhancedQuestTracker()
	hooksecurefunc("QuestLog_Update", Module.QuestLogLevel)
end

function Module:CreateQuestTrackerMover()
    self:QuestTracker()
end