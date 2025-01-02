local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "SHAMAN" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		--{AuraID = 974, UnitID = "player"},		-- 大地之盾
		{ AuraID = 16166, UnitID = "player" }, -- 元素掌控
		--{AuraID = 30823, UnitID = "player"},	-- 萨满之怒
		{ AuraID = 16188, UnitID = "player", Flash = true }, -- 自然迅捷
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ SpellID = 20608 }, -- 复生
	},
}

Module:AddNewAuraWatch("SHAMAN", list)
