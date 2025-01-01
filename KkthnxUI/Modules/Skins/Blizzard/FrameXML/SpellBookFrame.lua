local K, C = KkthnxUI[1], KkthnxUI[2]

tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	for i = 1, SPELLS_PER_PAGE do
		local bu = _G["SpellButton" .. i]
		local ic = _G["SpellButton" .. i .. "IconTexture"]

		bu:StripTextures("")
		bu:DisableDrawLayer("BACKGROUND")
		bu:StyleButton()

		ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)

		if not bu.__bg then
			bu.__bg = CreateFrame("Frame", nil, bu, "BackdropTemplate")
			bu.__bg:SetAllPoints(bu)
			bu.__bg:SetFrameLevel(bu:GetFrameLevel())
			bu.__bg:CreateBorder(nil, nil, nil, nil, nil, nil, K.MediaFolder .. "Skins\\UI-Spellbook-SpellBackground", nil, nil, nil, { 1, 1, 1 })
		end
	end

	hooksecurefunc("SpellButton_UpdateButton", function(self)
		if SpellBookFrame.bookType == BOOKTYPE_PROFESSION then
			return
		end

		local name = self:GetName()
		local ic = _G[name .. "IconTexture"]
		if ic.__bg then
			ic.__bg:SetShown(ic:IsShown())
		end
	end)
end)
