local K, C = KkthnxUI[1], KkthnxUI[2]

local _G = _G
local next, unpack = next, unpack
local hooksecurefunc = hooksecurefunc

local GetItemQualityColor = C_Item.GetItemQualityColor
local GetInventoryItemQuality = GetInventoryItemQuality

local function Update_InspectPaperDollItemSlotButton(button)
	local unit = button.hasItem and _G.InspectFrame.unit
	local quality = unit and GetInventoryItemQuality(unit, button:GetID())
	if quality and quality > 1 then
		local r, g, b = GetItemQualityColor(quality)
		button.KKUI_Border:SetVertexColor(r, g, b)
		return
	end

	button.KKUI_Border:SetVertexColor(1, 1, 1)
end

local function UpdateInspectModelFrameTexture()
	local _, targetRace = UnitRace("target")
	if targetRace then
		if not InspectModelFrame.KKUI_Texture then
			-- Create the texture only once
			local texture = InspectModelFrame:CreateTexture(nil, "BACKGROUND")
			texture:SetPoint("TOPLEFT", 0, 0)
			texture:SetPoint("BOTTOMRIGHT", 0, -18) -- Stretch down by 20 pixels
			InspectModelFrame.KKUI_Texture = texture
		end

		-- Set the texture properties
		InspectModelFrame.KKUI_Texture:SetTexture("Interface\\Transmogrify\\TransmogBackground" .. targetRace:gsub("%s+", ""))
		InspectModelFrame.KKUI_Texture:SetTexCoord(0.00195312, 0.576172, 0.00195312, 0.966797)
		InspectModelFrame.KKUI_Texture:SetHorizTile(false)
		InspectModelFrame.KKUI_Texture:SetVertTile(false)
	end
end

C.themes["Blizzard_InspectUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	for _, slot in next, { _G.InspectPaperDollItemsFrame:GetChildren() } do
		local icon = _G[slot:GetName() .. "IconTexture"]
		local cooldown = _G[slot:GetName() .. "Cooldown"]

		slot:StripTextures()
		slot:CreateBorder()
		slot:SetFrameLevel(slot:GetFrameLevel() + 2)
		slot:StyleButton()

		icon:SetTexCoord(unpack(K.TexCoords))
		icon:SetAllPoints()
	end

	hooksecurefunc("InspectPaperDollItemSlotButton_Update", Update_InspectPaperDollItemSlotButton)
	UpdateInspectModelFrameTexture()
	K:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateInspectModelFrameTexture)
end
