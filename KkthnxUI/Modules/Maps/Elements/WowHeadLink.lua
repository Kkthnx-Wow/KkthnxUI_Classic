-- KkthnxUI Namespace
local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("WorldMap")

-- Get localized Wowhead URL
local wowheadLoc
if GameLocale == "deDE" then
	wowheadLoc = "de.classic.wowhead.com"
elseif GameLocale == "esMX" then
	wowheadLoc = "es.classic.wowhead.com"
elseif GameLocale == "esES" then
	wowheadLoc = "es.classic.wowhead.com"
elseif GameLocale == "frFR" then
	wowheadLoc = "fr.classic.wowhead.com"
elseif GameLocale == "itIT" then
	wowheadLoc = "it.classic.wowhead.com"
elseif GameLocale == "ptBR" then
	wowheadLoc = "pt.classic.wowhead.com"
elseif GameLocale == "ruRU" then
	wowheadLoc = "ru.classic.wowhead.com"
elseif GameLocale == "koKR" then
	wowheadLoc = "ko.classic.wowhead.com"
elseif GameLocale == "zhCN" then
	wowheadLoc = "cn.classic.wowhead.com"
elseif GameLocale == "zhTW" then
	wowheadLoc = "cn.classic.wowhead.com"
else
	wowheadLoc = "classic.wowhead.com"
end

-- Main Function
function Module:CreateWowHeadLinks()
	if not C["Misc"].ShowWowHeadLinks or IsAddOnLoaded("Leatrix_Plus") then
		return
	end

	-- Create editbox
	local mEB = CreateFrame("EditBox", nil, QuestLogFrame)
	mEB:ClearAllPoints()
	mEB:SetPoint("TOPLEFT", 70, 4)
	mEB:SetHeight(16)
	mEB:SetFontObject("GameFontNormal")
	mEB:SetBlinkSpeed(0)
	mEB:SetAutoFocus(false)
	mEB:EnableKeyboard(false)
	mEB:SetHitRectInsets(0, 90, 0, 0)
	mEB:SetScript("OnKeyDown", function() end)
	mEB:SetScript("OnMouseUp", function()
		if mEB:IsMouseOver() then
			mEB:HighlightText()
		else
			mEB:HighlightText(0, 0)
		end
	end)

	-- Set the background color
	mEB.t = mEB:CreateTexture(nil, "BACKGROUND")
	mEB.t:SetPoint(mEB:GetPoint())
	mEB.t:SetSize(mEB:GetSize())
	mEB.t:SetColorTexture(0.05, 0.05, 0.05, 1.0)

	-- Create hidden font string (used for setting width of editbox)
	mEB.z = mEB:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	mEB.z:Hide()

	-- Function to set editbox value
	local function SetQuestInBox(questListID)
		local questTitle, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(questListID)
		if questID and not isHeader then
			-- Hide editbox if quest ID is invalid
			if questID == 0 then
				mEB:Hide()
			else
				mEB:Show()
			end

			-- Set editbox text
			mEB:SetText("https://" .. wowheadLoc .. "/quest=" .. questID)

			-- Set hidden fontstring then resize editbox to match
			mEB.z:SetText(mEB:GetText())
			mEB:SetWidth(mEB.z:GetStringWidth() + 90)
			mEB.t:SetWidth(mEB.z:GetStringWidth())

			-- Get quest title for tooltip
			if questTitle then
				mEB.tiptext = questTitle .. "|n" .. L["Press To Copy"]
			else
				mEB.tiptext = ""
				if mEB:IsMouseOver() and GameTooltip:IsShown() then
					GameTooltip:Hide()
				end
			end
		end
	end

	-- Set URL when quest is selected (this works with Questie, old method used QuestLog_SetSelection)
	hooksecurefunc("SelectQuestLogEntry", function(questListID)
		SetQuestInBox(questListID)
	end)

	-- Create tooltip
	mEB:HookScript("OnEnter", function()
		mEB:HighlightText()
		mEB:SetFocus()
		GameTooltip:SetOwner(mEB, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:SetText(mEB.tiptext, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)

	mEB:HookScript("OnLeave", function()
		mEB:HighlightText(0, 0)
		mEB:ClearFocus()
		GameTooltip:Hide()
	end)
end
