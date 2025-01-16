local K = KkthnxUI[1]
local Module = K:GetModule("Skins")

local strfind = strfind
local GetTradeSkillSelectionIndex, GetTradeSkillInfo, GetNumTradeSkills = GetTradeSkillSelectionIndex, GetTradeSkillInfo, GetNumTradeSkills
local GetCraftSelectionIndex, GetCraftInfo, GetNumCrafts = GetCraftSelectionIndex, GetCraftInfo, GetNumCrafts

local skinIndex = 0
function Module:TradeSkill_OnEvent(addon)
	if addon == "Blizzard_CraftUI" then
		Module:EnhancedCraft()
		skinIndex = skinIndex + 1
	elseif addon == "Blizzard_TradeSkillUI" then
		Module:EnhancedTradeSkill()
		skinIndex = skinIndex + 1
	end

	if skinIndex >= 2 then
		K:UnregisterEvent("ADDON_LOADED", Module.TradeSkill_OnEvent)
	end
end

local TEST_TradeSkills = false
function Module:TradeSkillSkin()
	if not TEST_TradeSkills then
		return
	end

	K:RegisterEvent("ADDON_LOADED", Module.TradeSkill_OnEvent)
end

local function createArrowButton(parent, anchor, direction)
	local button = CreateFrame("Button", nil, parent)
	button:SetPoint("LEFT", anchor, "RIGHT", 3, 0)
	K.ReskinArrow(button, direction, false)

	return button
end

local function removeInputText(self)
	self:SetText("")
end

local function editBoxClearFocus(self)
	self:ClearFocus()
end

function Module:CreateSearchWidget(parent, anchor)
	local searchBox = CreateFrame("EditBox", nil, parent, "SearchBoxTemplate")
	searchBox:SetSize(150, 20)
	searchBox:SetAutoFocus(false)
	searchBox:SetTextInsets(5, 5, 0, 0)
	searchBox:SetScript("OnEscapePressed", editBoxClearFocus)
	searchBox:SetScript("OnEnterPressed", editBoxClearFocus)
	searchBox:SetFrameLevel(6)
	searchBox:SetPoint("LEFT", 76, 1)
	searchBox:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -42, -20)
	searchBox:HookScript("OnEscapePressed", removeInputText)
	searchBox.title = "Tips"
	K.AddTooltip(searchBox, "ANCHOR_TOP", "|nType the recipe name you need and press ENTER to search.|n|nPress ESC to clear the input.", "info")

	local nextButton = createArrowButton(searchBox, searchBox, "down")
	local prevButton = createArrowButton(searchBox, nextButton, "up")

	return searchBox, nextButton, prevButton
end

local function updateScrollBarValue(scrollBar, maxSkills, selectSkill)
	local _, maxValue = scrollBar:GetMinMaxValues()
	if maxValue == 0 then
		return
	end
	local maxIndex = maxSkills - 22
	if maxIndex <= 0 then
		return
	end
	local selectIndex = selectSkill - 22
	if selectIndex < 0 then
		selectIndex = 0
	end

	scrollBar:SetValue(selectIndex / maxIndex * maxValue)
end

function Module:UpdateTradeSelection(i, maxSkills)
	TradeSkillFrame_SetSelection(i)
	TradeSkillFrame_Update()
	updateScrollBarValue(TradeSkillListScrollFrameScrollBar, maxSkills, GetTradeSkillSelectionIndex())
end

function Module:GetTradeSearchResult(text, from, to, step)
	for i = from, to, step do
		local skillName, skillType = GetTradeSkillInfo(i)
		if skillType ~= "header" and strfind(skillName, text) then
			Module:UpdateTradeSelection(i, GetNumTradeSkills())
			return true
		end
	end
end

function Module:UpdateCraftSelection(i, maxSkills)
	CraftFrame_SetSelection(i)
	CraftFrame_Update()
	updateScrollBarValue(CraftListScrollFrameScrollBar, maxSkills, GetCraftSelectionIndex())
end

function Module:GetCraftSearchResult(text, from, to, step)
	for i = from, to, step do
		local skillName, skillType = GetCraftInfo(i)
		if skillType ~= "header" and strfind(skillName, text) then
			Module:UpdateCraftSelection(i, GetNumCrafts())
			return true
		end
	end
end

function Module:EnhancedTradeSkill()
	local TradeSkillFrame = _G.TradeSkillFrame
	if TradeSkillFrame:GetWidth() > 700 then
		return
	end

	TradeSkillFrame:StripTextures()
	TradeSkillFrame.TitleText = TradeSkillFrameTitleText
	TradeSkillFrame.scrollFrame = _G.TradeSkillDetailScrollFrame
	TradeSkillFrame.listScrollFrame = _G.TradeSkillListScrollFrame
	Module:EnlargeDefaultUIPanel("TradeSkillFrame", 1)

	_G.TRADE_SKILLS_DISPLAYED = 22
	for i = 2, _G.TRADE_SKILLS_DISPLAYED do
		local button = _G["TradeSkillSkill" .. i]
		if not button then
			button = CreateFrame("Button", "TradeSkillSkill" .. i, TradeSkillFrame, "TradeSkillSkillButtonTemplate")
			button:SetID(i)
			button:Hide()
		end
		button:SetPoint("TOPLEFT", _G["TradeSkillSkill" .. (i - 1)], "BOTTOMLEFT", 0, 1)
	end

	TradeSkillCancelButton:ClearAllPoints()
	TradeSkillCancelButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame, "BOTTOMRIGHT", -42, 54)
	TradeSkillCreateButton:ClearAllPoints()
	TradeSkillCreateButton:SetPoint("RIGHT", TradeSkillCancelButton, "LEFT", -1, 0)
	TradeSkillInvSlotDropdown:ClearAllPoints()
	TradeSkillInvSlotDropdown:SetPoint("TOPLEFT", TradeSkillFrame, "TOPLEFT", 510, -40)

	-- Reskin
	TradeSkillFrameCloseButton:ClearAllPoints()
	TradeSkillFrameCloseButton:SetPoint("TOPRIGHT", TradeSkillFrame, "TOPRIGHT", -30, -8)

	hooksecurefunc("TradeSkillFrame_Update", function()
		TradeSkillHighlightFrame:SetWidth(300)
	end)

	-- Search widgets
	local searchBox, nextButton, prevButton = Module:CreateSearchWidget(TradeSkillFrame, TradeSkillRankFrame)

	searchBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetTradeSearchResult(text, 1, GetNumTradeSkills(), 1) then
			UIErrorsFrame:AddMessage(K.InfoColor .. "Invalid content input.")
		end
	end)

	nextButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetTradeSearchResult(text, GetTradeSkillSelectionIndex() + 1, GetNumTradeSkills(), 1) then
			UIErrorsFrame:AddMessage(K.InfoColor .. "No more matched results.")
		end
	end)

	prevButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetTradeSearchResult(text, GetTradeSkillSelectionIndex() - 1, 1, -1) then
			UIErrorsFrame:AddMessage(K.InfoColor .. "No more matched results.")
		end
	end)
end

function Module:EnhancedCraft()
	local CraftFrame = _G.CraftFrame
	if CraftFrame:GetWidth() > 700 then
		return
	end

	CraftFrame:StripTextures()
	CraftFrame.TitleText = CraftFrameTitleText
	CraftFrame.scrollFrame = _G.CraftDetailScrollFrame
	CraftFrame.listScrollFrame = _G.CraftListScrollFrame
	Module:EnlargeDefaultUIPanel("CraftFrame", 1)

	_G.CraftDetailScrollFrameScrollBar:SetAlpha(0) -- seems useless

	_G.CRAFTS_DISPLAYED = 22
	for i = 2, _G.CRAFTS_DISPLAYED do
		local button = _G["Craft" .. i]
		if not button then
			button = CreateFrame("Button", "Craft" .. i, CraftFrame, "CraftButtonTemplate")
			button:SetID(i)
			button:Hide()
		end
		button:SetPoint("TOPLEFT", _G["Craft" .. (i - 1)], "BOTTOMLEFT", 0, 1)
	end

	CraftFramePointsLabel:ClearAllPoints()
	CraftFramePointsLabel:SetPoint("TOPLEFT", CraftFrame, "TOPLEFT", 100, -70)
	CraftFramePointsText:ClearAllPoints()
	CraftFramePointsText:SetPoint("LEFT", CraftFramePointsLabel, "RIGHT", 3, 0)

	CraftCancelButton:ClearAllPoints()
	CraftCancelButton:SetPoint("BOTTOMRIGHT", CraftFrame, "BOTTOMRIGHT", -42, 54)
	CraftCreateButton:ClearAllPoints()
	CraftCreateButton:SetPoint("RIGHT", CraftCancelButton, "LEFT", -1, 0)

	hooksecurefunc("CraftFrame_Update", function()
		CraftHighlightFrame:SetWidth(300)
	end)

	CraftFrameCloseButton:ClearAllPoints()
	CraftFrameCloseButton:SetPoint("TOPRIGHT", CraftFrame, "TOPRIGHT", -30, -8)

	-- Search widget
	local searchBox, nextButton, prevButton = Module:CreateSearchWidget(CraftFrame, CraftRankFrame)

	searchBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetCraftSearchResult(text, 1, GetNumCrafts(), 1) then
			UIErrorsFrame:AddMessage(K.InfoColor .. "Invalid content input.")
		end
	end)

	nextButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetCraftSearchResult(text, GetCraftSelectionIndex() + 1, GetNumCrafts(), 1) then
			UIErrorsFrame:AddMessage(K.InfoColor .. "No more matched results.")
		end
	end)

	prevButton:SetScript("OnClick", function()
		local text = searchBox:GetText()
		if not text or text == "" then
			return
		end

		if not Module:GetCraftSearchResult(text, GetCraftSelectionIndex() - 1, 1, -1) then
			UIErrorsFrame:AddMessage(K.InfoColor .. "No more matched results.")
		end
	end)
end
