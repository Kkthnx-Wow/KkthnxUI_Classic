local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("WorldMap")

-- Localized Wowhead URL mapping
local wowheadLocales = {
	deDE = "de.classic.wowhead.com",
	esMX = "es.classic.wowhead.com",
	esES = "es.classic.wowhead.com",
	frFR = "fr.classic.wowhead.com",
	itIT = "it.classic.wowhead.com",
	ptBR = "pt.classic.wowhead.com",
	ruRU = "ru.classic.wowhead.com",
	koKR = "ko.classic.wowhead.com",
	zhCN = "cn.classic.wowhead.com",
	zhTW = "cn.classic.wowhead.com",
}

local wowheadURL = wowheadLocales[GetLocale()] or "classic.wowhead.com"

-- Function to create the Wowhead link editbox
local function CreateWowheadLinkEditBox(parentFrame)
	local editBox = CreateFrame("EditBox", nil, parentFrame)
	editBox:SetPoint("TOPLEFT", 70, 4)
	editBox:SetHeight(16)
	editBox:SetFontObject("GameFontNormal")
	editBox:SetAutoFocus(false)
	editBox:EnableKeyboard(false)
	editBox:SetHitRectInsets(0, 90, 0, 0)
	editBox:SetScript("OnKeyDown", function() end)
	editBox:SetScript("OnMouseUp", function()
		editBox:HighlightText()
	end)

	-- Background color
	local bg = editBox:CreateTexture(nil, "BACKGROUND")
	bg:SetPoint("TOPLEFT", editBox, "TOPLEFT")
	bg:SetPoint("BOTTOMLEFT", editBox, "BOTTOMLEFT")
	editBox.bg = bg
	bg:SetColorTexture(0.060, 0.060, 0.060, 0.9)

	-- Hidden font string for dynamic resizing
	local fontString = editBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	fontString:Hide()
	editBox.fontString = fontString

	return editBox
end

-- Update the editbox with the selected quest's Wowhead link
local function UpdateWowheadLink(editBox, questLogIndex)
	local questTitle, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(questLogIndex)

	if not questID or isHeader or questID == 0 then
		editBox:Hide()
		return
	end

	local linkText = " https://" .. wowheadURL .. "/quest=" .. questID
	editBox:SetText(linkText)
	editBox.fontString:SetText(linkText)

	-- Adjust width dynamically
	local textWidth = editBox.fontString:GetStringWidth()
	editBox:SetWidth(textWidth + 90)
	editBox.bg:SetSize(textWidth + 4, editBox:GetHeight()) -- Dynamically adjust background size
	editBox:Show()

	-- Tooltip text
	editBox.tipText = questTitle and (questTitle .. "|n" .. L["Press To Copy"]) or ""
end

-- Tooltip handling
local function SetupTooltip(editBox)
	editBox:HookScript("OnEnter", function()
		editBox:HighlightText()
		editBox:SetFocus()
		GameTooltip:SetOwner(editBox, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:SetText(editBox.tipText, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)

	editBox:HookScript("OnLeave", function()
		editBox:HighlightText(0, 0)
		editBox:ClearFocus()
		GameTooltip:Hide()
	end)
end

-- Main function to initialize the Wowhead link feature
function Module:CreateWowheadLinks()
	if not C["Misc"].ShowWowHeadLinks or IsAddOnLoaded("Leatrix_Plus") then
		return
	end

	local editBox = CreateWowheadLinkEditBox(QuestLogFrame)
	SetupTooltip(editBox)

	hooksecurefunc("SelectQuestLogEntry", function(questLogIndex)
		UpdateWowheadLink(editBox, questLogIndex)
	end)
end
