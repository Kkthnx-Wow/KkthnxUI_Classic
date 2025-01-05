local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

local ipairs = ipairs
local tinsert = tinsert
local hooksecurefunc = hooksecurefunc

local CreateFrame = CreateFrame
local GetCVarBool = GetCVarBool
local CalculateTotalNumberOfFreeBagSlots = CalculateTotalNumberOfFreeBagSlots
local NUM_BAG_FRAMES = NUM_BAG_FRAMES

local buttonList = {}
local bagBar
local bagPosition

-- Bag Bar Mouseover Handlers
function Module:BagBar_OnEnter()
	return C["Inventory"].BagBarMouseover and K.UIFrameFadeIn(bagBar, 0.2, bagBar:GetAlpha(), 1)
end

function Module:BagBar_OnLeave()
	return C["Inventory"].BagBarMouseover and K.UIFrameFadeOut(bagBar, 0.2, bagBar:GetAlpha(), 0)
end

-- Bag Bar Event Handler
function Module:BagBar_OnEvent(event)
	bagBar:UnregisterEvent(event)
end

-- Key Ring Tooltip Handlers
function Module:KeyRing_OnEnter()
	if not GameTooltip:IsForbidden() then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:AddLine(_G.KEYRING, 1, 1, 1)
		GameTooltip:Show()
	end

	Module:BagBar_OnEnter()
end

function Module:KeyRing_OnLeave()
	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end

	Module:BagBar_OnEnter()
end

-- Skin Bag Button
function Module:SkinBag(bag)
	local icon = bag.icon or _G[bag:GetName() .. "IconTexture"]
	bag.oldTex = icon:GetTexture()

	bag:StripTextures(true)
	bag:CreateBorder()
	bag:StyleButton(true)

	bag:GetNormalTexture():SetAlpha(0)
	bag:GetHighlightTexture():SetAlpha(0)

	icon.Show = nil
	icon:Show()

	icon:SetAllPoints()
	icon:SetTexture((not bag.oldTex or bag.oldTex == 1721259) and "Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\Backpack.tga" or bag.oldTex)
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
end

-- Set Size and Position of Bag Bar
function Module:SetSizeAndPositionBagBar()
	if not bagBar then
		return
	end

	local bagBarSize = C["Inventory"].BagBarSize
	local buttonSpacing = 6
	local growthDirection = C["Inventory"].GrowthDirection.Value
	local sortDirection = C["Inventory"].SortDirection.Value
	local justBackpack = C["Inventory"].JustBackpack

	if InCombatLockdown() then
		bagBar:RegisterEvent("PLAYER_REGEN_ENABLED")
	end

	bagBar:SetAlpha(C["Inventory"].BagBarMouseover and 0 or 1)

	_G.MainMenuBarBackpackButtonCount:SetFontObject(K.UIFontOutline)

	for i, button in ipairs(buttonList) do
		button:SetSize(bagBarSize, bagBarSize)
		button:ClearAllPoints()
		button:SetShown(not justBackpack or i == 1)

		local prevButton = buttonList[i - 1]
		if growthDirection == "HORIZONTAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:SetPoint("LEFT", bagBar, "LEFT", 0, 0)
			elseif prevButton then
				button:SetPoint("LEFT", prevButton, "RIGHT", buttonSpacing, 0)
			end
		elseif growthDirection == "VERTICAL" and sortDirection == "ASCENDING" then
			if i == 1 then
				button:SetPoint("TOP", bagBar, "TOP", 0, -0)
			elseif prevButton then
				button:SetPoint("TOP", prevButton, "BOTTOM", 0, -buttonSpacing)
			end
		elseif growthDirection == "HORIZONTAL" and sortDirection == "DESCENDING" then
			if i == 1 then
				button:SetPoint("RIGHT", bagBar, "RIGHT", -0, 0)
			elseif prevButton then
				button:SetPoint("RIGHT", prevButton, "LEFT", -buttonSpacing, 0)
			end
		else
			if i == 1 then
				button:SetPoint("BOTTOM", bagBar, "BOTTOM", 0, 0)
			elseif prevButton then
				button:SetPoint("BOTTOM", prevButton, "TOP", 0, buttonSpacing)
			end
		end
	end

	local btnSize = bagBarSize * (NUM_BAG_FRAMES + 1)
	local btnSpace = buttonSpacing * NUM_BAG_FRAMES

	if growthDirection == "HORIZONTAL" then
		bagBar:SetSize(btnSize + btnSpace, bagBarSize)
	else
		bagBar:SetSize(bagBarSize, btnSize + btnSpace)
	end

	bagBar.mover:SetSize(bagBar:GetSize())
	Module:UpdateMainButtonCount()
end

-- Update Main Button Count
function Module:UpdateMainButtonCount()
	local mainCount = buttonList[1].Count
	mainCount:SetShown(GetCVarBool("displayFreeBagSlots"))
	mainCount:SetText(CalculateTotalNumberOfFreeBagSlots())
end

-- Update Bag Button Textures
function Module:BagButton_UpdateTextures()
	local pushed = self:GetPushedTexture()
	pushed:SetTexture("Interface\\Buttons\\CheckButtonHilight")
	pushed:SetBlendMode("ADD")
	pushed:SetAllPoints()

	if self.SlotHighlightTexture then
		self.SlotHighlightTexture:SetTexture(self:IsObjectType("CheckButton") and "Interface\\Buttons\\CheckButtonHilight" or "Interface\\Buttons\\ButtonHilight-Square")
		self.SlotHighlightTexture:SetBlendMode("ADD")
		self.SlotHighlightTexture:SetAllPoints()
	end
end

-- Create Inventory Bar
function Module:CreateInventoryBar()
	if not C["ActionBar"].Enable then
		return
	end

	if not C["Inventory"].BagBar then
		return
	end

	bagBar = CreateFrame("Frame", "KKUI_BagBar", K.PetBattleFrameHider)
	if C["ActionBar"].MicroMenu then
		bagPosition = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 40 }
	else
		bagPosition = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 }
	end
	bagBar:SetScript("OnEnter", Module.BagBar_OnEnter)
	bagBar:SetScript("OnLeave", Module.BagBar_OnLeave)
	bagBar:SetScript("OnEvent", Module.BagBar_OnEvent)
	bagBar:EnableMouse(true)

	local backpackButton = MainMenuBarBackpackButton
	backpackButton:SetParent(bagBar)
	backpackButton:ClearAllPoints()
	backpackButton.Count:ClearAllPoints()
	backpackButton.Count:SetPoint("BOTTOMRIGHT", backpackButton, "BOTTOMRIGHT", -1, 4)
	backpackButton.Count:SetFontObject(K.UIFontOutline)
	backpackButton:HookScript("OnEnter", Module.BagBar_OnEnter)
	backpackButton:HookScript("OnLeave", Module.BagBar_OnLeave)

	tinsert(buttonList, backpackButton)
	Module:SkinBag(backpackButton)
	Module.BagButton_UpdateTextures(backpackButton)

	for i = 0, NUM_BAG_FRAMES - 1 do
		local b = _G["CharacterBag" .. i .. "Slot"]
		b:HookScript("OnEnter", Module.BagBar_OnEnter)
		b:HookScript("OnLeave", Module.BagBar_OnLeave)
		b:SetParent(bagBar)
		Module:SkinBag(b)

		tinsert(buttonList, b)
	end

	K.Mover(bagBar, "BagBar", "BagBar", bagPosition)
	if not bagBar.mover then
		bagBar.mover = K.Mover(bagBar, "BagBar", "BagBar", bagPosition)
	else
		bagBar.mover:SetSize(bagBar:GetSize())
	end
	bagBar:SetPoint("BOTTOMLEFT", bagBar.mover)
	K:RegisterEvent("BAG_SLOT_FLAGS_UPDATED", Module.SetSizeAndPositionBagBar)
	K:RegisterEvent("BAG_UPDATE_DELAYED", Module.UpdateMainButtonCount)
	Module:SetSizeAndPositionBagBar()
end
