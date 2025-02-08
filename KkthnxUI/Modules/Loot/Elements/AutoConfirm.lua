local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- Function to handle auto confirming of loot dialogs
function Module:CONFIRM_LOOT_ROLL(_, rollID, rollType)
	ConfirmLootRoll(rollID, rollType)
	StaticPopup_Hide("CONFIRM_LOOT_ROLL", rollID)
end

function Module:LOOT_BIND_CONFIRM(_, lootSlot)
	ConfirmLootSlot(lootSlot)
	StaticPopup_Hide("LOOT_BIND")
end

function Module:CONFIRM_DISENCHANT_ROLL(_, rollID, rollType)
	ConfirmLootRoll(rollID, rollType)
	StaticPopup_Hide("CONFIRM_LOOT_ROLL", rollID)
end

-- Function to create the auto confirm feature
function Module:CreateAutoConfirm()
	if not C["Loot"].AutoConfirmLoot then
		return
	end

	K:RegisterEvent("CONFIRM_DISENCHANT_ROLL", Module.CONFIRM_DISENCHANT_ROLL)
	K:RegisterEvent("CONFIRM_LOOT_ROLL", Module.CONFIRM_LOOT_ROLL)
	K:RegisterEvent("LOOT_BIND_CONFIRM", Module.LOOT_BIND_CONFIRM)
end
