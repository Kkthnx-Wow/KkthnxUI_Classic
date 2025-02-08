local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

local GetLootRollItemInfo = GetLootRollItemInfo
local RollOnLoot = RollOnLoot

local function SetupAutoGreed(_, _, rollID)
	local _, _, _, quality, _, _, _, canDisenchant = GetLootRollItemInfo(rollID)
	if quality == 2 then -- Quality 2 is Green (Uncommon)
		if canDisenchant then
			RollOnLoot(rollID, 3) -- Disenchant
		else
			RollOnLoot(rollID, 2) -- Greed
		end
	end
end

function Module:CreateAutoGreed()
	if not C["Loot"].AutoGreed then
		return
	end

	-- Classic WoW has a max level of 60, so we use that directly
	if K.Level ~= 60 then
		return
	end

	K:RegisterEvent("START_LOOT_ROLL", SetupAutoGreed)
end
