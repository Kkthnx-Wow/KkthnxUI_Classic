local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

function Module:ReskinSimulationcraft()
	if not IsAddOnLoaded("Simulationcraft") then
		return
	end

	local Simulationcraft = LibStub("AceAddon-3.0"):GetAddon("Simulationcraft")
	hooksecurefunc(Simulationcraft, 'GetMainFrame', function()
		if not SimcFrame.isSkinned then
			SimcFrame:StripTextures()
			SimcFrame:CreateBorder()
			SimcFrameButton:SkinButton()
			SimcScrollFrameScrollBar:SkinScrollBar()
			SimcFrame.isSkinned = true
		end
	end)
end