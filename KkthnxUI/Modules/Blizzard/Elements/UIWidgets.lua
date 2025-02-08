local K = KkthnxUI[1]
local Module = K:GetModule("Blizzard")

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local UIParent = UIParent

-- Reanchor UIWidgets
function Module:CreateUIWidgets()
	local frame1 = CreateFrame("Frame", "KKUI_WidgetMover", UIParent)
	frame1:SetSize(200, 25)
	K.Mover(frame1, "UIWidgetFrame", "UIWidgetFrame", { "TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -28 })

	hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "SetPoint", function(self, _, parent)
		if parent ~= frame1 then
			self:ClearAllPoints()
			self:SetPoint("CENTER", frame1)
		end
	end)
end
