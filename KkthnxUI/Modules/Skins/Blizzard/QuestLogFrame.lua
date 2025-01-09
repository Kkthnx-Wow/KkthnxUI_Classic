local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

-- Cached global functions for performance
local GetQuestLogSelection = GetQuestLogSelection
local GetNumQuestLogEntries = GetNumQuestLogEntries
local GetQuestLogTitle = GetQuestLogTitle
local CreateFrame = CreateFrame
local format = string.format

-- Set increased height of quest log frame and maximum number of quests listed
local tall, numTallQuests = 73, 21

local function SetupQuestLogFrame()
	-- Make the quest log frame double-wide
	UIPanelWindows["QuestLogFrame"] = { area = "override", pushable = 0, xoffset = -16, yoffset = 12, bottomClampOverride = 140 + 12, width = 685, height = 487, whileDead = 1 }

	-- Size the quest log frame
	QuestLogFrame:SetWidth(714)
	QuestLogFrame:SetHeight(487 + tall)

	-- Adjust quest log title text
	QuestLogTitleText:ClearAllPoints()
	QuestLogTitleText:SetPoint("TOP", QuestLogFrame, "TOP", 0, -18)

	-- Move the detail frame to the right and stretch it to full height
	QuestLogDetailScrollFrame:ClearAllPoints()
	QuestLogDetailScrollFrame:SetPoint("TOPLEFT", QuestLogListScrollFrame, "TOPRIGHT", 31, 1)
	QuestLogDetailScrollFrame:SetHeight(336 + tall)

	-- Expand the quest list to full height
	QuestLogListScrollFrame:SetHeight(336 + tall)

	-- Create additional quest rows
	local oldQuestsDisplayed = QUESTS_DISPLAYED
	_G.QUESTS_DISPLAYED = _G.QUESTS_DISPLAYED + numTallQuests
	for i = oldQuestsDisplayed + 1, QUESTS_DISPLAYED do
		local button = CreateFrame("Button", "QuestLogTitle" .. i, QuestLogFrame, "QuestLogTitleButtonTemplate")
		button:SetID(i)
		button:Hide()
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", _G["QuestLogTitle" .. (i - 1)], "BOTTOMLEFT", 0, 1)
	end

	-- Get quest frame textures
	local regions = { QuestLogFrame:GetRegions() }

	-- Set top left texture
	regions[3]:SetSize(512, 512)
	regions[3]:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Skins\\QuestLogFrame")
	regions[3]:SetTexCoord(0.25, 0.75, 0, 1)

	-- Set top right texture
	regions[4]:ClearAllPoints()
	regions[4]:SetPoint("TOPLEFT", regions[3], "TOPRIGHT", 0, 0)
	regions[4]:SetSize(256, 512)
	regions[4]:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Skins\\QuestLogFrame")
	regions[4]:SetTexCoord(0.75, 1, 0, 1)

	-- Hide bottom left and bottom right textures
	regions[5]:Hide()
	regions[6]:Hide()
end

local function SetupQuestLogButtons()
	-- Position and resize abandon button
	QuestLogFrameAbandonButton:SetSize(110, 21)
	QuestLogFrameAbandonButton:SetText(ABANDON_QUEST_ABBREV)
	QuestLogFrameAbandonButton:ClearAllPoints()
	QuestLogFrameAbandonButton:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 17, 54)

	-- Position and resize share button
	QuestFramePushQuestButton:SetSize(100, 21)
	QuestFramePushQuestButton:SetText(SHARE_QUEST_ABBREV)
	QuestFramePushQuestButton:ClearAllPoints()
	QuestFramePushQuestButton:SetPoint("LEFT", QuestLogFrameAbandonButton, "RIGHT", -3, 0)

	QuestLogTrack:Hide()

	local QuestTrackButton = CreateFrame("Button", "QuestTrackButton", QuestLogFrame, "UIPanelButtonTemplate")
	QuestTrackButton:SetText(TRACK_QUEST)
	QuestTrackButton:ClearAllPoints()
	QuestTrackButton:SetPoint("LEFT", QuestFramePushQuestButton, "RIGHT", -3, 0)
	QuestTrackButton:SetSize(100, 21)
	QuestTrackButton:HookScript("OnClick", function()
		if IsQuestWatched(GetQuestLogSelection()) then
			RemoveQuestWatch(GetQuestLogSelection())
			QuestWatch_Update()
		else
			if GetNumQuestLeaderBoards(GetQuestLogSelection()) == 0 then
				UIErrorsFrame:AddMessage(QUEST_WATCH_NO_OBJECTIVES, 1.0, 0.1, 0.1, 1.0)
				return
			end

			if GetNumQuestWatches() >= MAX_WATCHABLE_QUESTS then
				UIErrorsFrame:AddMessage(format(QUEST_WATCH_TOO_MANY, MAX_WATCHABLE_QUESTS), 1.0, 0.1, 0.1, 1.0)
				return
			end

			AddQuestWatch(GetQuestLogSelection())
			QuestLog_Update()
			QuestWatch_Update()
		end

		QuestLog_Update()
	end)

	-- Position and size close button
	QuestFrameExitButton:SetSize(80, 22)
	QuestFrameExitButton:SetText(CLOSE)
	QuestFrameExitButton:ClearAllPoints()
	QuestFrameExitButton:SetPoint("BOTTOMRIGHT", QuestLogFrame, "BOTTOMRIGHT", -42, 54)

	-- Empty quest frame
	QuestLogNoQuestsText:ClearAllPoints()
	QuestLogNoQuestsText:SetPoint("TOP", QuestLogListScrollFrame, 0, -50)
	hooksecurefunc(EmptyQuestLogFrame, "Show", function()
		EmptyQuestLogFrame:ClearAllPoints()
		EmptyQuestLogFrame:SetPoint("BOTTOMLEFT", QuestLogFrame, "BOTTOMLEFT", 20, -76)
		EmptyQuestLogFrame:SetHeight(487)
	end)
end

local function SetupShowMapButton()
	-- Create and configure the Show Map button
	local showMapButton = CreateFrame("Button", nil, QuestLogFrame)
	showMapButton:SetSize(36, 25)
	showMapButton:SetPoint("TOPRIGHT", -390, -44)

	-- Normal texture
	local normalTexture = showMapButton:CreateTexture(nil, "ARTWORK", nil, 1)
	normalTexture:SetTexture("Interface/QuestFrame/UI-QuestMap_Button")
	normalTexture:SetTexCoord(0.125, 0.875, 0.0, 0.5)
	normalTexture:SetAllPoints()
	showMapButton:SetNormalTexture(normalTexture)

	-- Pushed texture
	local pushedTexture = showMapButton:CreateTexture(nil, "ARTWORK", nil, 1)
	pushedTexture:SetTexture("Interface/QuestFrame/UI-QuestMap_Button")
	pushedTexture:SetTexCoord(0.125, 0.875, 0.5, 1.0)
	pushedTexture:SetAllPoints()
	showMapButton:SetPushedTexture(pushedTexture)

	-- Highlight texture
	local highlightTexture = showMapButton:CreateTexture(nil, "HIGHLIGHT")
	highlightTexture:SetTexture("Interface/Buttons/ButtonHilight-Square")
	highlightTexture:SetSize(24, 18)
	highlightTexture:SetPoint("RIGHT", -7, 0)
	showMapButton:SetHighlightTexture(highlightTexture)

	-- Set the OnClick script to toggle the world map
	showMapButton:SetScript("OnClick", ToggleWorldMap)
end

local function UpdateQuestDetails()
	if C["Skins"].QuestLevels then
		local quest = GetQuestLogSelection()
		if quest then
			local title, level, suggestedGroup = GetQuestLogTitle(quest)
			if title and level then
				if suggestedGroup then
					if suggestedGroup == LFG_TYPE_DUNGEON then
						level = level .. L["D"]
					elseif suggestedGroup == RAID then
						level = level .. L["R"]
					elseif suggestedGroup == ELITE then
						level = level .. L["+"]
					elseif suggestedGroup == GROUP then
						level = level .. L["+"]
					elseif suggestedGroup == PVP then
						level = level .. L["P"]
					end
				end
				QuestLogQuestTitle:SetText("[" .. level .. "] " .. title)
			end
		end
	end
end

local function UpdateQuestLog()
	local numEntries = GetNumQuestLogEntries()
	if numEntries == 0 then
		QuestTrackButton:Disable()
		return
	else
		QuestTrackButton:Enable()
	end

	QuestLogListScrollFrame:Show()

	-- Traverse quests in log
	for i = 1, QUESTS_DISPLAYED do
		local questIndex = i + FauxScrollFrame_GetOffset(QuestLogListScrollFrame)
		if questIndex <= numEntries then
			-- Get quest title and check
			local questLogTitle = _G["QuestLogTitle" .. i]
			local questCheck = _G["QuestLogTitle" .. i .. "Check"]
			local title, level, suggestedGroup, isHeader = GetQuestLogTitle(questIndex)
			if title and level and not isHeader and C["Skins"].QuestLevels then
				-- Add level tag if its not a header
				local levelSuffix = ""
				if suggestedGroup and C["Skins"].QuestDifficulty then
					if suggestedGroup == LFG_TYPE_DUNGEON then
						levelSuffix = "D"
					elseif suggestedGroup == RAID then
						levelSuffix = "R"
					elseif suggestedGroup == ELITE then
						levelSuffix = "+"
					elseif suggestedGroup == GROUP then
						levelSuffix = "+"
					elseif suggestedGroup == PVP then
						levelSuffix = "P"
					end
				end
				local questTextFormatted = format("  [%d%s] %s", level, L[levelSuffix] or "", title)
				questLogTitle:SetText(questTextFormatted)
				QuestLogDummyText:SetText(questTextFormatted)
			end

			-- Show tracking check mark
			local checkText = _G["QuestLogTitle" .. i .. "NormalText"]
			if checkText then
				local checkPos = checkText:GetStringWidth()
				if checkPos then
					if checkPos <= 210 then
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", checkPos + 24, 0)
					else
						questCheck:SetPoint("LEFT", questLogTitle, "LEFT", 210, 0)
					end
				end
			end
		end
	end
end

table.insert(C.defaultThemes, function()
	if not C["Skins"].QuestLog then
		return
	end

	-- Translations for quest level suffixes (need to be English so links work in addons such as Questie for non-English locales)
	L["D"] = "D" -- Dungeon quest
	L["R"] = "R" -- Raid quest
	L["P"] = "P" -- PvP quest
	L["+"] = "+" -- Elite or group quest

	SetupQuestLogFrame()
	SetupQuestLogButtons()
	SetupShowMapButton()

	hooksecurefunc("QuestLog_UpdateQuestDetails", UpdateQuestDetails)
	hooksecurefunc("QuestLog_Update", UpdateQuestLog)
end)
