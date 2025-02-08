local K, C = KkthnxUI[1], KkthnxUI[2]
-- local Module = K:GetModule("Blizzard")

do
	-- Fix blizz error
	MAIN_MENU_MICRO_ALERT_PRIORITY = MAIN_MENU_MICRO_ALERT_PRIORITY or {}
end

do
	-- Still exisits in 1.14.3.43154
	if not InspectTalentFrameSpentPoints then
		InspectTalentFrameSpentPoints = CreateFrame("Frame")
	end
end

do
	-- Fix blizz bug in addon list
	local _AddonTooltip_Update = AddonTooltip_Update
	function AddonTooltip_Update(owner)
		if not owner then
			return
		end
		if owner:GetID() < 1 then
			return
		end
		_AddonTooltip_Update(owner)
	end
end

do
	-- Fix MasterLooterFrame anchor issue
	hooksecurefunc(MasterLooterFrame, "Show", function(self)
		self:ClearAllPoints()
	end)
end

do
	local function SetShamanColor(colorTable, color)
		if colorTable then
			colorTable["SHAMAN"].r = color.r
			colorTable["SHAMAN"].g = color.g
			colorTable["SHAMAN"].b = color.b
			colorTable["SHAMAN"].colorStr = color.colorStr
		end
	end

	SetShamanColor(RAID_CLASS_COLORS, K.FixShamanColor)
	SetShamanColor(CUSTOM_CLASS_COLORS, K.FixShamanColor)
end

do
	local _G = _G
	local tinsert = tinsert
	local GetFileIDFromPath = GetFileIDFromPath
	local MAX_NUM_QUESTS = MAX_NUM_QUESTS

	local ACTIVE_QUEST_ICON_FILEID = GetFileIDFromPath("Interface\\GossipFrame\\ActiveQuestIcon")
	local AVAILABLE_QUEST_ICON_FILEID = GetFileIDFromPath("Interface\\GossipFrame\\AvailableQuestIcon")

	local titleLines = {}
	local questIconTextures = {}
	for i = 1, MAX_NUM_QUESTS do
		local titleLine = _G["QuestTitleButton" .. i]
		tinsert(titleLines, titleLine)
		tinsert(questIconTextures, _G[titleLine:GetName() .. "QuestIcon"])
	end

	QuestFrameGreetingPanel:HookScript("OnShow", function()
		for i, titleLine in ipairs(titleLines) do
			if titleLine:IsVisible() then
				local bulletPointTexture = questIconTextures[i]
				if titleLine.isActive == 1 then
					bulletPointTexture:SetTexture(ACTIVE_QUEST_ICON_FILEID)
				else
					bulletPointTexture:SetTexture(AVAILABLE_QUEST_ICON_FILEID)
				end
			end
		end
	end)
end

do
	local _G = _G
	local tinsert = tinsert
	local wipe = wipe
	local gsub = gsub
	local GetNumQuestLogEntries = GetNumQuestLogEntries
	local GetQuestLogTitle = GetQuestLogTitle
	local IsQuestComplete = IsQuestComplete
	local C_QuestLog = C_QuestLog
	local MAX_NUM_QUESTS = MAX_NUM_QUESTS
	local QuestFrameGreetingPanel = QuestFrameGreetingPanel

	local escapes = {
		["|c%x%x%x%x%x%x%x%x"] = "", -- color start
		["|r"] = "", -- color end
	}
	local function unescape(str)
		for k, v in pairs(escapes) do
			str = gsub(str, k, v)
		end
		return str
	end

	local completedActiveQuests = {}
	local function getCompletedQuestsInLog()
		wipe(completedActiveQuests)
		local numEntries = GetNumQuestLogEntries()
		local questLogTitleText, isComplete, questId, _
		for i = 1, numEntries, 1 do
			_, _, _, _, _, isComplete, _, questId = GetQuestLogTitle(i)
			if isComplete == 1 or IsQuestComplete(questId) then
				questLogTitleText = C_QuestLog.GetQuestInfo(questId)
				completedActiveQuests[questLogTitleText] = true
			end
		end
		return completedActiveQuests
	end

	local function setDesaturation(maxLines, lineMap, iconMap, activePred)
		local completedQuests = getCompletedQuestsInLog()
		for i = 1, maxLines do
			local line = lineMap[i]
			local icon = iconMap[i]
			icon:SetDesaturated(nil)
			if line:IsVisible() and activePred(line) then
				local questName = unescape(line:GetText())
				if not completedQuests[questName] then
					icon:SetDesaturated(1)
				end
			end
		end
	end

	local function getLineAndIconMaps(maxLines, titleIdent, iconIdent)
		local lines = {}
		local icons = {}
		for i = 1, maxLines do
			local titleLine = _G[titleIdent .. i]
			tinsert(lines, titleLine)
			tinsert(icons, _G[titleLine:GetName() .. iconIdent])
		end
		return lines, icons
	end

	local questFrameTitleLines, questFrameIconTextures = getLineAndIconMaps(MAX_NUM_QUESTS, "QuestTitleButton", "QuestIcon")
	QuestFrameGreetingPanel:HookScript("OnShow", function()
		setDesaturation(MAX_NUM_QUESTS, questFrameTitleLines, questFrameIconTextures, function(line)
			return line.isActive == 1
		end)
	end)

	local oldSetup = GossipActiveQuestButtonMixin.Setup
	function GossipActiveQuestButtonMixin:Setup(...)
		oldSetup(self, ...)
		if self.GetElementData ~= nil then
			local info = self.GetElementData().info
			if info ~= nil then
				if not info.isComplete and not IsQuestComplete(info.questID) then
					self.Icon:SetDesaturated(1)
				else
					self.Icon:SetDesaturated(nil)
				end
			end
		end
	end
end

do
	-- This ensures the 'scriptErrors' CVar is always disabled to prevent spam caused by Blizzard's bug with 'FCF_DockUpdate' in Classic Era.
	-- Even if a user or another addon attempts to enable 'scriptErrors', this script will immediately turn it back off.

	-- Create a frame to handle events
	local eventHandlerFrame = CreateFrame("Frame")

	-- Function to ensure 'scriptErrors' is always set to 0
	local function EnsureScriptErrorsDisabled()
		if GetCVar("scriptErrors") ~= "0" then
			SetCVar("scriptErrors", 0)
		end
	end

	-- Event handler function to manage specific events
	local function OnEvent(self, event, ...)
		if event == "PLAYER_ENTERING_WORLD" or event == "CVAR_UPDATE" then
			-- Ensure 'scriptErrors' is always disabled, introduces a small delay to allow the CVars to updateReason
			C_Timer.After(0.5, EnsureScriptErrorsDisabled)
		end
	end

	-- Register events to enforce the 'scriptErrors' setting
	eventHandlerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	eventHandlerFrame:RegisterEvent("CVAR_UPDATE")
	eventHandlerFrame:SetScript("OnEvent", OnEvent)

	-- Initial check to disable 'scriptErrors' during addon load
	EnsureScriptErrorsDisabled()
end

do
	-- Fix for CommunitiesGuildInfoFrame MOTD scrollframe
	-- This is a temporary fix until Blizzard fixes it
	hooksecurefunc("CommunitiesGuildInfoFrame_UpdateText", function(self, infoText)
		local motdScrollFrame = CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame
		if motdScrollFrame then
			if motdScrollFrame:GetHeight() ~= 180 then
				motdScrollFrame:SetHeight(180)
			end
		end
	end)
end
