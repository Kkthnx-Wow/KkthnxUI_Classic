local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")
local TT = K:GetModule("Tooltip")

-- Basic Lua functions
local pairs = pairs
local select = select
local next = next

-- Unit and item information functions
local UnitGUID = UnitGUID
local GetItemInfo = C_Item.GetItemInfo
local GetInventoryItemLink = GetInventoryItemLink
local GetTradePlayerItemLink = GetTradePlayerItemLink
local GetTradeTargetItemLink = GetTradeTargetItemLink

local inspectSlots = {
	"Head",
	"Neck",
	"Shoulder",
	"Shirt",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"Finger0",
	"Finger1",
	"Trinket0",
	"Trinket1",
	"Back",
	"MainHand",
	"SecondaryHand",
	"Ranged",
}

function Module:GetSlotAnchor(index)
	if not index then
		return
	end

	if index <= 5 or index == 9 or index == 15 then
		return "BOTTOMLEFT", 40, 20
	elseif index == 16 then
		return "BOTTOMRIGHT", -40, 2
	elseif index == 17 then
		return "BOTTOMLEFT", 40, 2
	else
		return "BOTTOMRIGHT", -40, 20
	end
end

function Module:CreateItemTexture(slot, relF, x, y)
	local icon = slot:CreateTexture()
	icon:SetPoint(relF, x, y)
	icon:SetSize(14, 14)
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	icon.bg = CreateFrame("Frame", nil, slot)
	icon.bg:SetAllPoints(icon)
	icon.bg:SetFrameLevel(3)
	icon.bg:CreateBorder()
	icon.bg:Hide()

	return icon
end

function Module:CreateItemString(frame, strType)
	if frame.fontCreated then
		return
	end

	for index, slot in pairs(inspectSlots) do
		--if index ~= 4 then	-- need color border for some shirts
		local slotFrame = _G[strType .. slot .. "Slot"]
		slotFrame.iLvlText = K.CreateFontString(slotFrame, 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
		slotFrame.iLvlText:ClearAllPoints()
		slotFrame.iLvlText:SetPoint("BOTTOMLEFT", slotFrame, 1, 1)

		local relF, x, y = Module:GetSlotAnchor(index)
		for i = 1, 5 do
			local offset = (i - 1) * 20 + 5
			local iconX = x > 0 and x + offset or x - offset
			local iconY = index > 15 and 20 or 2
			slotFrame["textureIcon" .. i] = Module:CreateItemTexture(slotFrame, relF, iconX, iconY)
		end
	end

	frame.fontCreated = true
end

local pending = {}

local gemSlotBlackList = {
	[16] = true,
	[17] = true,
	[18] = true, -- ignore weapons, until I find a better way
}
function Module:ItemLevel_UpdateGemInfo(link, unit, index, slotFrame)
	if C["Misc"].GemEnchantInfo and not gemSlotBlackList[index] then
		local info = K.GetItemLevel(link, unit, index, true)
		if info then
			local gemStep = 1
			for i = 1, 5 do
				local texture = slotFrame["textureIcon" .. i]
				local bg = texture.bg
				local gem = info.gems and info.gems[gemStep]
				if gem then
					texture:SetTexture(gem)
					-- bg:SetBackdropBorderColor(0, 0, 0)
					-- bg:Show()

					gemStep = gemStep + 1
				end
			end
		end
	end
end

function Module:RefreshButtonInfo()
	local unit = InspectFrame and InspectFrame.unit
	if unit then
		for index, slotFrame in pairs(pending) do
			local link = GetInventoryItemLink(unit, index)
			if link then
				local quality, level = select(3, GetItemInfo(link))
				if quality then
					local color = K.QualityColors[quality]
					--Module:ItemBorderSetColor(slotFrame, color.r, color.g, color.b)
					if C["Misc"].ItemLevel and level and level > 1 and quality > 1 then
						slotFrame.iLvlText:SetText(level)
						slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
					end
					--	M:ItemLevel_UpdateGemInfo(link, unit, index, slotFrame)
					Module:UpdateInspectILvl()

					pending[index] = nil
				end
			end
		end

		if not next(pending) then
			self:Hide()
			return
		end
	else
		wipe(pending)
		self:Hide()
	end
end

function Module:ItemLevel_SetupLevel(frame, strType, unit)
	if not UnitExists(unit) then
		return
	end

	Module:CreateItemString(frame, strType)

	for index, slot in pairs(inspectSlots) do
		--if index ~= 4 then
		local slotFrame = _G[strType .. slot .. "Slot"]
		slotFrame.iLvlText:SetText("")
		for i = 1, 5 do
			local texture = slotFrame["textureIcon" .. i]
			texture:SetTexture(nil)
			texture.bg:Hide()
		end
		-- Module:ItemBorderSetColor(slotFrame, 0, 0, 0)

		local itemTexture = GetInventoryItemTexture(unit, index)
		if itemTexture then
			local link = GetInventoryItemLink(unit, index)
			if link then
				local quality, level = select(3, GetItemInfo(link))
				if quality then
					local color = K.QualityColors[quality]
					-- M:ItemBorderSetColor(slotFrame, color.r, color.g, color.b)
					if C["Misc"].ItemLevel and level and level > 1 and quality > 1 then
						slotFrame.iLvlText:SetText(level)
						slotFrame.iLvlText:SetTextColor(color.r, color.g, color.b)
					end

					--	Module:ItemLevel_UpdateGemInfo(link, unit, index, slotFrame)
				else
					pending[index] = slotFrame
					--Module.QualityUpdater:Show()
				end
			else
				pending[index] = slotFrame
				--Module.QualityUpdater:Show()
			end
		end
		--end
	end
end

function Module:ItemLevel_UpdatePlayer()
	Module:ItemLevel_SetupLevel(CharacterFrame, "Character", "player")
end

function Module:UpdateInspectILvl()
	if not Module.InspectILvl then
		return
	end

	Module:UpdateUnitILvl(InspectFrame.unit, Module.InspectILvl)
	Module.InspectILvl:SetFormattedText("iLvl %s", Module.InspectILvl:GetText())
end

local anchored
local function AnchorInspectRotate()
	if anchored then
		return
	end
	InspectModelFrameRotateRightButton:ClearAllPoints()
	InspectModelFrameRotateRightButton:SetPoint("BOTTOMLEFT", InspectFrameTab1, "TOPLEFT", 0, 2)

	Module.InspectILvl = K.CreateFontString(InspectPaperDollFrame, 15)
	Module.InspectILvl:ClearAllPoints()
	Module.InspectILvl:SetPoint("TOP", InspectLevelText, "BOTTOM", 0, -4)

	anchored = true
end

function Module:ItemLevel_UpdateInspect(...)
	local guid = ...
	if InspectFrame and InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		AnchorInspectRotate()
		Module:ItemLevel_SetupLevel(InspectFrame, "Inspect", InspectFrame.unit)
		Module:UpdateInspectILvl()
	end
end

local function GetItemQualityAndLevel(link)
	local _, _, quality, level, _, _, _, _, _, _, _, classID = GetItemInfo(link)
	if quality and quality > 1 and level > 1 and K.iLvlClassIDs[classID] then
		return quality, level
	end
end

function Module:ItemLevel_UpdateMerchant(link)
	if not self.iLvl then
		self.iLvl = K.CreateFontString(_G[self:GetName() .. "ItemButton"], 12, "", "OUTLINE", false, "BOTTOMLEFT", 2, 2)
	end
	self.iLvl:SetText("")
	if link then
		local quality, level = GetItemQualityAndLevel(link)
		if quality and level then
			local color = K.QualityColors[quality]
			self.iLvl:SetText(level)
			self.iLvl:SetTextColor(color.r, color.g, color.b)
		end
	end
end

function Module.ItemLevel_UpdateTradePlayer(index)
	local button = _G["TradePlayerItem" .. index]
	local link = GetTradePlayerItemLink(index)
	Module.ItemLevel_UpdateMerchant(button, link)
end

function Module.ItemLevel_UpdateTradeTarget(index)
	local button = _G["TradeRecipientItem" .. index]
	local link = GetTradeTargetItemLink(index)
	Module.ItemLevel_UpdateMerchant(button, link)
end

function Module:CreateSlotItemLevel()
	if not C["Misc"].ItemLevel then
		return
	end

	-- iLvl on CharacterFrame
	CharacterFrame:HookScript("OnShow", Module.ItemLevel_UpdatePlayer)
	K:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", Module.ItemLevel_UpdatePlayer)
	CharacterModelFrameRotateRightButton:ClearAllPoints()
	CharacterModelFrameRotateRightButton:SetPoint("BOTTOMLEFT", CharacterFrameTab1, "TOPLEFT", 0, 2)

	-- iLvl on InspectFrame
	K:RegisterEvent("INSPECT_READY", Module.ItemLevel_UpdateInspect)

	-- -- Update item quality
	-- Module.QualityUpdater = CreateFrame("Frame")
	-- Module.QualityUpdater:Hide()
	-- Module.QualityUpdater:SetScript("OnUpdate", Module.RefreshButtonInfo)

	-- iLvl on MerchantFrame
	hooksecurefunc("MerchantFrameItem_UpdateQuality", Module.ItemLevel_UpdateMerchant)

	-- iLvl on TradeFrame
	hooksecurefunc("TradeFrame_UpdatePlayerItem", Module.ItemLevel_UpdateTradePlayer)
	hooksecurefunc("TradeFrame_UpdateTargetItem", Module.ItemLevel_UpdateTradeTarget)
end

Module:RegisterMisc("GearInfo", Module.CreateSlotItemLevel)
