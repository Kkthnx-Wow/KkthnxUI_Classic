local K, C = KkthnxUI[1], KkthnxUI[2]
-- local Module = K:GetModule("Blizzard")

-- Fix blizz error
MAIN_MENU_MICRO_ALERT_PRIORITY = MAIN_MENU_MICRO_ALERT_PRIORITY or {}

-- Still exisits in 1.14.3.43154
if not InspectTalentFrameSpentPoints then
	InspectTalentFrameSpentPoints = CreateFrame("Frame")
end

-- Fix blizz bug in addon list
local _AddonTooltip_Update = AddonTooltip_Update
function AddonTooltip_Update(owner)
	if not owner then
		return
	end
	if owner:GetID() < 1 then
		return
	end
	_AddonTooltip_Update(owner)
end

-- Fix MasterLooterFrame anchor issue
hooksecurefunc(MasterLooterFrame, "Show", function(self)
	self:ClearAllPoints()
end)
