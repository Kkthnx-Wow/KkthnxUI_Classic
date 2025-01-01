local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

-- Cache global functions and variables
local _G = _G
local ipairs = ipairs
local format = string.format
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local PickupInventoryItem = PickupInventoryItem
local ClearCursor = ClearCursor
local StaticPopup_Visible = StaticPopup_Visible
local GameTooltip = GameTooltip
local C_Engraving = C_Engraving
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local NOT_COLLECTED = NOT_COLLECTED

-- Misc
local SlotIDToName = {
	[INVSLOT_HEAD] = HEADSLOT,
	[INVSLOT_SHOULDER] = SHOULDERSLOT,
	[INVSLOT_CHEST] = CHESTSLOT,
	[INVSLOT_WAIST] = WAISTSLOT,
	[INVSLOT_LEGS] = LEGSSLOT,
	[INVSLOT_FEET] = FEETSLOT,
	[INVSLOT_WRIST] = WRISTSLOT,
	[INVSLOT_HAND] = HANDSSLOT,
	[INVSLOT_FINGER1] = FINGER0SLOT_UNIQUE,
	[INVSLOT_FINGER2] = FINGER1SLOT_UNIQUE,
	[INVSLOT_BACK] = BACKSLOT,
}

local textureTemplate = "|T%s%s|t"
local emptyString = ""
local function GetTextureString(texture, data)
	return textureTemplate:format(texture, data or emptyString)
end

local function HandleRuneSpellButtonClick(self, button)
	if InCombatLockdown() then
		print(ERR_NOT_IN_COMBAT)
		return
	end

	if button == "RightButton" then
		C_Engraving.CastRune(self.skillLineAbilityID)
	elseif not C_Engraving.IsRuneEquipped(self.skillLineAbilityID) then
		C_Engraving.CastRune(self.skillLineAbilityID)
		local rune = C_Engraving.GetCurrentRuneCast()
		if rune and rune.equipmentSlot then
			local slotID = rune.equipmentSlot == 16 and 15 or rune.equipmentSlot
			PickupInventoryItem(slotID)
			ClearCursor()
			local _, dialog = StaticPopup_Visible("REPLACE_ENCHANT")
			if dialog then
				dialog.button1:Click()
			end
		end
	end
end

function Module:UpdateEngravingUI()
	local EngravingFrame = _G.EngravingFrame
	if not (EngravingFrame and EngravingFrame:IsVisible()) then
		return
	end

	local buttons = EngravingFrame.scrollFrame.buttons
	for _, button in ipairs(buttons) do
		if not button.__equippedTex then
			button.__equippedTex = button:CreateTexture(nil, "OVERLAY", nil, 4)
			button.__equippedTex:SetAtlas("UI-CharacterCreate-LargeButton-Yellow-Highlight")
			button.__equippedTex:SetAllPoints()
		end

		if button:IsShown() and button.skillLineAbilityID then
			button.__equippedTex:SetShown(C_Engraving.IsRuneEquipped(button.skillLineAbilityID))
		end
	end
end

function Module:OnEquipmentChanged(slotID)
	if C_Engraving.IsEquipmentSlotEngravable(slotID) then
		self:UpdateEngravingUI()
	end
end

local KnownRunes = {}

function Module:UpdateKnownRunes()
	C_Engraving.RefreshRunesList()
	local categories = C_Engraving.GetRuneCategories(false, true)
	for _, category in ipairs(categories) do
		local runes = C_Engraving.GetRunesForCategory(category, true)
		for _, info in ipairs(runes) do
			KnownRunes[info.skillLineAbilityID] = true
		end
	end
end

local function ShowUncollectedRunesTooltip(self)
	local exclusiveFilter = C_Engraving.GetExclusiveCategoryFilter()
	local known, max = C_Engraving.GetNumRunesKnown(exclusiveFilter)
	if known < max then
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -4)
		GameTooltip:AddLine(exclusiveFilter and format("%s %s", SlotIDToName[exclusiveFilter], NOT_COLLECTED) or NOT_COLLECTED)

		local categories = exclusiveFilter and { exclusiveFilter } or C_Engraving.GetRuneCategories(false, false)
		for _, category in ipairs(categories) do
			local runes = C_Engraving.GetRunesForCategory(category, false)
			for _, info in ipairs(runes) do
				if not KnownRunes[info.skillLineAbilityID] then
					GameTooltip:AddLine(format("%s %s", GetTextureString(info.iconTexture, ":18:18:0:-2:64:64:5:59:5:59"), info.name), 0.6, 0.8, 1)
				end
			end
		end

		GameTooltip:Show()
	end
end

function Module:AddUncollectedRunesTooltip()
	local parent = _G.EngravingFrame and _G.EngravingFrame.collected
	if not parent then
		return
	end

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetPoint("TOPLEFT")
	frame:SetPoint("BOTTOMLEFT")
	frame:SetWidth(100)
	frame:SetScript("OnEnter", ShowUncollectedRunesTooltip)
	frame:SetScript("OnLeave", K.HideTooltip)
end

function Module:AddRunesHelpInfo()
	local EngravingFrame = _G.EngravingFrame
	if not EngravingFrame and EngravingFrame.Border then
		return
	end

	local helpInfo = CreateFrame("Button", nil, EngravingFrame)
	helpInfo:SetPoint("TOPRIGHT", EngravingFrame.Border, 20, -5)
	helpInfo:SetSize(40, 40)
	helpInfo.Icon = helpInfo:CreateTexture(nil, "ARTWORK")
	helpInfo.Icon:SetAllPoints()
	helpInfo.Icon:SetTexture(616343)
	helpInfo:SetHighlightTexture(616343)
	helpInfo.title = "Engraving Tip"
	K.AddTooltip(helpInfo, "ANCHOR_RIGHT", "|nLeft-click a rune to automatically engrave it to the slot.|n|nRight-click to cast the rune.", "info")
end

C.themes["Blizzard_EngravingUI"] = function()
	if not K.ClassicSOD then
		return
	end

	if not K.IsEngravingEnabled then
		return
	end

	EngravingFrameSpell_OnClick = HandleRuneSpellButtonClick
	hooksecurefunc("EngravingFrame_UpdateRuneList", Module.UpdateEngravingUI)
	K:RegisterEvent("RUNE_UPDATED", Module.UpdateEngravingUI)
	K:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", Module.OnEquipmentChanged)

	-- Uncollected Runes
	Module:UpdateKnownRunes()
	K:RegisterEvent("NEW_RECIPE_LEARNED", Module.UpdateKnownRunes)
	Module:AddUncollectedRunesTooltip()
	Module:AddRunesHelpInfo()
end
