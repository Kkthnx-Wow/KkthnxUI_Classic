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
	local function UpdateGreetingFrame()
		local i = 1
		local title = _G["QuestTitleButton" .. i]
		while title and title:IsVisible() do
			local text = title:GetFontString()
			local textString = gsub(title:GetText(), "|c[Ff][Ff]%x%x%x%x%x%x(.+)|r", "%1")
			title:SetText(textString)

			local icon = _G["QuestTitleButton" .. i .. "QuestIcon"]
			if title.isActive == 1 then
				icon:SetTexture(132048)
				icon:SetDesaturation(1)
			else
				icon:SetTexture(132049)
				icon:SetDesaturation(0)
			end

			local numEntries = GetNumQuestLogEntries()
			for y = 1, numEntries do
				local titleText, _, _, _, _, isComplete, _, questId = GetQuestLogTitle(y)
				if not titleText then
					break
				elseif strmatch(titleText, textString) and (isComplete == 1 or IsQuestComplete(questId)) then
					icon:SetDesaturation(0)
					break
				end
			end

			i = i + 1
			title = _G["QuestTitleButton" .. i]
		end
	end

	_G.QuestFrameGreetingPanel:HookScript("OnUpdate", UpdateGreetingFrame)
	hooksecurefunc("QuestFrameGreetingPanel_OnShow", UpdateGreetingFrame)
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
