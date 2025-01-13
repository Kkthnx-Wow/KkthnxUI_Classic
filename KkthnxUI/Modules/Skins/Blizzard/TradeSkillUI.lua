local K, C = KkthnxUI[1], KkthnxUI[2]

C.themes["Blizzard_CraftUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	CraftRankFrame:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	CraftRankFrame.SetStatusBarColor = K.Noop
	CraftRankFrame:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0.1, 0.3, 0.9, 1), CreateColor(0.2, 0.4, 1, 1))
	CraftRankFrame:GetStatusBarTexture():SetDrawLayer("BORDER")
end

C.themes["Blizzard_TradeSkillUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	TradeSkillRankFrame:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	TradeSkillRankFrame.SetStatusBarColor = K.Noop
	TradeSkillRankFrame:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0.1, 0.3, 0.9, 1), CreateColor(0.2, 0.4, 1, 1))
	TradeSkillRankFrame:GetStatusBarTexture():SetDrawLayer("BORDER")
end
