local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local pvpAreas = {
	[123] = true, -- Wintergrasp
	[244] = true, -- Tol Barad (PvP)
	[588] = true, -- Ashran
	[622] = true, -- Stormshield
	[624] = true, -- Warspear
}

local function PLAYER_DEAD()
	if C_DeathInfo.GetSelfResurrectOptions() and #C_DeathInfo.GetSelfResurrectOptions() > 0 then
		return
	end

	local isInstance, instanceType = IsInInstance()
	local areaID = C_Map.GetBestMapForUnit("player")

	if (isInstance and instanceType == "pvp") or (areaID and pvpAreas[areaID]) then
		RepopMe()
	end
end

function Module:CreateAutoRelease()
	if C["Automation"].AutoRelease then
		K:RegisterEvent("PLAYER_DEAD", PLAYER_DEAD)
	else
		K:UnregisterEvent("PLAYER_DEAD", PLAYER_DEAD)
	end
end
