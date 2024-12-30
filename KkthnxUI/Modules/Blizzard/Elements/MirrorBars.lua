local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- Sourced: NDui

local function reskinMirrorBar(bar)
	bar:SetSize(222, 22)
	bar:StripTextures(true)

	local statusbar = _G[bar:GetName() .. "StatusBar"]
	if statusbar then
		statusbar:SetAllPoints()
		statusbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	else
		bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	end

	local barText = _G[bar:GetName() .. "Text"]
	if barText then
		barText:ClearAllPoints()
		barText:SetFontObject(K.UIFont)
		barText:SetFont(barText:GetFont(), 12, nil)
		barText:SetPoint("BOTTOM", bar, "TOP", 0, 4)
	end

	if not bar.Spark then
		bar.Spark = bar:CreateTexture(nil, "OVERLAY")
		bar.Spark:SetSize(64, bar:GetHeight())
		bar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		bar.Spark:SetBlendMode("ADD")
		bar.Spark:SetPoint("CENTER", statusbar:GetStatusBarTexture(), "RIGHT", 0, 0)
	end

	bar:CreateBorder()
end

function Module:CreateMirrorBars()
	local previous
	for i = 1, 3 do
		local bar = _G["MirrorTimer" .. i]
		reskinMirrorBar(bar)

		if previous then
			bar:SetPoint("TOP", previous, "BOTTOM", 0, -5)
		end
		previous = bar
	end
end
