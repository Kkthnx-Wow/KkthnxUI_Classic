local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = table.insert

local function LoadSpellBookSkin()
	-- Spell Buttons
	for i = 1, _G.SPELLS_PER_PAGE do
		local button = _G["SpellButton"..i]
		local icon = _G["SpellButton"..i.."IconTexture"]

		for k = 1, button:GetNumRegions() do
			local region = select(k, button:GetRegions())
			if region:GetObjectType() == "Texture" then
				if region:GetTexture() ~= "Interface\\Buttons\\ActionBarFlyoutButton" then
					region:SetTexture(nil)
				end
			end
		end

		button:CreateBorder()
		button:CreateInnerShadow()
		icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	end
end

table_insert(Module.NewSkin["KkthnxUI"], LoadSpellBookSkin)