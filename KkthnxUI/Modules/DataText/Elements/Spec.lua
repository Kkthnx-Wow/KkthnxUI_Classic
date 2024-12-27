local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("DataText")

local format, strsub = string.format, strsub
local TALENT, SHOW_SPEC_LEVEL, FEATURE_BECOMES_AVAILABLE_AT_LEVEL, NONE = TALENT, SHOW_SPEC_LEVEL, FEATURE_BECOMES_AVAILABLE_AT_LEVEL, NONE
local UnitLevel, ToggleTalentFrame, UnitCharacterPoints = UnitLevel, ToggleTalentFrame, UnitCharacterPoints
local talentString = "%s (%s)"
local unspendPoints = gsub(CHARACTER_POINTS1_COLON, HEADER_COLON, "")

local currentSpecIndex

local eventList = {
	"PLAYER_ENTERING_WORLD",
	"CHARACTER_POINTS_CHANGED",
	"SPELLS_CHANGED",
}

local function OnEvent()
	local text = ""
	for i = 1, 5 do
		local _, name, _, _, pointsSpent = GetTalentTabInfo(i)
		if not name then
			break
		end
		text = text .. "-" .. pointsSpent
	end
	if text == "" then
		text = NONE
	else
		text = strsub(text, 2)
	end
	local points = UnitCharacterPoints("player")
	if points > 0 then
		text = format(talentString, text, points)
	end
	SpecDataText.Text:SetText(TALENT .. ": " .. K.MyClassColor .. text)
end

local function OnEnter()
	if not currentSpecIndex or currentSpecIndex == 5 then
		return
	end

	GameTooltip:SetOwner(SpecDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(SpecDataText))
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0, 0.6, 1)
	GameTooltip:AddLine(" ")

	for i = 1, 5 do
		local _, name, _, _, pointsSpent = GetTalentTabInfo(i)
		if not name then
			break
		end
		GameTooltip:AddDoubleLine(name, pointsSpent, 1, 1, 1, 1, 0.8, 0)
	end
	local points = UnitCharacterPoints("player")
	if points > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(unspendPoints, points, 0.6, 0.8, 1, 1, 0.8, 0)
	end

	GameTooltip:AddDoubleLine(" ", K.LeftButton .. "Toggle TalentFrame" .. " ", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:Show()
end

local OnLeave = K.HideTooltip

local function OnMouseUp(self, btn)
	if UnitLevel("player") < SHOW_SPEC_LEVEL then
		UIErrorsFrame:AddMessage(K.InfoColor .. format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_SPEC_LEVEL))
	else
		--if InCombatLockdown() then UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_IN_COMBAT) return end -- fix by LibShowUIPanel
		ToggleTalentFrame()
	end
end

function Module:CreateSpecDataText()
	if not C["DataText"].Spec then
		return
	end

	SpecDataText = CreateFrame("Frame", nil, UIParent)

	SpecDataText.Text = K.CreateFontString(SpecDataText, 12)
	SpecDataText.Text:ClearAllPoints()
	SpecDataText.Text:SetPoint("LEFT", UIParent, "LEFT", 24, -210)

	SpecDataText.Texture = SpecDataText:CreateTexture(nil, "ARTWORK")
	SpecDataText.Texture:SetPoint("RIGHT", SpecDataText.Text, "LEFT", 0, 2)
	SpecDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\talents.blp")
	SpecDataText.Texture:SetSize(24, 24)
	SpecDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	SpecDataText:SetAllPoints(SpecDataText.Text)

	local function _OnEvent(...)
		OnEvent(...)
	end

	for _, event in pairs(eventList) do
		SpecDataText:RegisterEvent(event)
	end

	SpecDataText:SetScript("OnEvent", _OnEvent)
	SpecDataText:SetScript("OnEnter", OnEnter)
	SpecDataText:SetScript("OnLeave", OnLeave)
	SpecDataText:SetScript("OnMouseUp", OnMouseUp)
end
