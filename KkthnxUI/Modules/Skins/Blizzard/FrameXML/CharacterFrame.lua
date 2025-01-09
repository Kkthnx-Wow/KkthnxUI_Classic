-- Cache Global Variables
local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

local _G = _G
local next = next
local unpack = unpack
local hooksecurefunc = hooksecurefunc

local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityColor = C_Item.GetItemQualityColor

local function replaceBlueColor(bar, r, g, b)
	if r == 0 and g == 0 and b > 0.99 then
		bar:SetStatusBarColor(0, 0.6, 1, 0.5)
	end
end

local ResistanceCoords = {
	{ 0.21875, 0.8125, 0.25, 0.32421875 }, --Arcane
	{ 0.21875, 0.8125, 0.0234375, 0.09765625 }, --Fire
	{ 0.21875, 0.8125, 0.13671875, 0.2109375 }, --Nature
	{ 0.21875, 0.8125, 0.36328125, 0.4375 }, --Frost
	{ 0.21875, 0.8125, 0.4765625, 0.55078125 }, --Shadow
}

local function PaperDollItemSlotButtonUpdate(frame)
	if not frame.KKUI_Border or not frame.KKUI_Border.SetVertexColor then
		return
	end

	local id = frame:GetID()
	local rarity = id and GetInventoryItemQuality("player", id)
	if rarity and rarity > 1 then
		local r, g, b = GetItemQualityColor(rarity)
		frame.KKUI_Border:SetVertexColor(r, g, b)
	else
		frame.KKUI_Border:SetVertexColor(1, 1, 1)
	end
end

local function HandleResistanceFrame(frameName)
	for i = 1, 5 do
		local frame, icon, text = _G[frameName .. i], _G[frameName .. i]:GetRegions()
		frame:SetSize(24, 24)
		frame:CreateBorder()

		if not IsAddOnLoaded("CharacterStatsClassic") then
			if i == 1 then
				frame:ClearAllPoints()
				frame:SetPoint("TOP", frame:GetParent(), "TOP", 0, -4)
			else
				frame:ClearAllPoints()
				frame:SetPoint("TOP", _G[frameName .. i - 1], "BOTTOM", 0, -6)
			end
		end

		if icon then
			icon:SetAllPoints()
			icon:SetTexCoord(unpack(ResistanceCoords[i]))
			icon:SetDrawLayer("ARTWORK")
		end

		if text then
			text:SetDrawLayer("OVERLAY")
		end
	end
end

tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- Seasonal
	local runeButton = K.ClassicSOD and _G.RuneFrameControlButton
	if runeButton then
		runeButton:SetSize(30, 30)
		runeButton:StripTextures()
		runeButton:CreateBorder()
		runeButton:StyleButton()

		if runeButton:GetPoint() then
			local point, relativeTo, relativePoint, xOfs, yOfs = runeButton:GetPoint()
			if point and relativeTo and relativePoint and xOfs and yOfs then
				runeButton:ClearAllPoints()
				runeButton:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs + 1)
			end
		end

		if not runeButton.runeIcon then -- make then icon
			runeButton.runeIcon = runeButton:CreateTexture(nil, "ARTWORK")
			runeButton.runeIcon:SetTexture(134419) -- Interface\Icons\INV_Misc_Rune_06
			runeButton.runeIcon:SetTexCoord(unpack(K.TexCoords))
			runeButton.runeIcon:SetAllPoints(runeButton)
		end
	end

	_G.CharacterAttributesFrame:StripTextures()

	HandleResistanceFrame("MagicResFrame")

	for _, slot in next, { _G.PaperDollItemsFrame:GetChildren() } do
		if slot:IsObjectType("Button") and slot.Count then
			local name = slot:GetName()
			local icon = _G[name .. "IconTexture"]

			slot:StripTextures()
			slot:CreateBorder()
			slot:StyleButton()

			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			icon:SetAllPoints()

			-- if slot.subicon then
			-- 	slot.subicon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			-- end
		end
	end

	hooksecurefunc("PaperDollItemSlotButton_Update", PaperDollItemSlotButtonUpdate)

	CharacterModelFrame:ClearAllPoints()
	CharacterModelFrame:SetSize(231, 320)
	CharacterModelFrame:SetPoint("TOPLEFT", PaperDollFrame, "TOPLEFT", 66, -78)
	if not CharacterModelFrame.KKUI_Texture then
		-- Create the texture only once
		local texture = CharacterModelFrame:CreateTexture(nil, "ARTWORK")
		texture:SetPoint("TOPLEFT", 0, 0)
		texture:SetPoint("BOTTOMRIGHT", 0, -0) -- Stretch down by 20 pixels
		CharacterModelFrame.KKUI_Texture = texture
	end

	-- Set the texture properties
	CharacterModelFrame.KKUI_Texture:SetTexture("Interface\\Transmogrify\\TransmogBackground" .. K.Race:gsub("%s+", ""))
	CharacterModelFrame.KKUI_Texture:SetTexCoord(0.00195312, 0.576172, 0.00195312, 0.966797)
	CharacterModelFrame.KKUI_Texture:SetHorizTile(false)
	CharacterModelFrame.KKUI_Texture:SetVertTile(false)

	hooksecurefunc("PaperDollFrame_SetLevel", function()
		local classDisplayName, class = UnitClass("player")
		local raceDisplayName = UnitRace("player")
		local classColor = RAID_CLASS_COLORS[class]
		local classColorString = format("ff%.2x%.2x%.2x", classColor.r * 255, classColor.g * 255, classColor.b * 255)

		CharacterLevelText:SetFormattedText("Level %d %s |c%s%s|r", UnitLevel("player"), raceDisplayName, classColorString, classDisplayName)
	end)

	hooksecurefunc("PaperDollFrame_SetGuild", function()
		local guildName, title = GetGuildInfo("player")
		local infoColorString = "|cff4ebdbb"

		if guildName then
			CharacterGuildText:SetFormattedText(GUILD_TITLE_TEMPLATE, infoColorString .. title .. "|r", guildName)
		end
	end)

	-- Update the appearance of faction reputation bars
	local function UpdateFactionSkins()
		for i = 1, GetNumFactions() do
			local bar = _G["ReputationBar" .. i]

			if bar and not bar.styled then
				bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
				bar:GetStatusBarTexture():SetDrawLayer("BORDER")

				bar.styled = true
			end
		end
	end

	ReputationFrame:HookScript("OnShow", UpdateFactionSkins)
	ReputationFrame:HookScript("OnEvent", UpdateFactionSkins)

	-- Update the appearance of the skill detail status bar
	SkillDetailStatusBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	hooksecurefunc(SkillDetailStatusBar, "SetStatusBarColor", replaceBlueColor)
	SkillDetailStatusBar:GetStatusBarTexture():SetDrawLayer("BORDER")

	-- Update the appearance of individual skill rank frames
	for i = 1, 12 do
		local name = "SkillRankFrame" .. i
		local bar = _G[name]

		-- Apply custom texture and set the draw layer
		bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		hooksecurefunc(bar, "SetStatusBarColor", replaceBlueColor)
		bar:GetStatusBarTexture():SetDrawLayer("BORDER")
	end
end)
