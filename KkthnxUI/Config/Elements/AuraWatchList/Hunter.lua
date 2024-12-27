local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "HUNTER" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 3045, UnitID = "player" }, -- 急速射击
		{ AuraID = 6150, UnitID = "player" }, -- 快速射击
		{ AuraID = 19574, UnitID = "pet" }, -- 狂野怒火
		{ AuraID = 19577, UnitID = "pet" }, -- 胁迫
	},
	["Focus Aura"] = { -- 焦点光环组
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
	},
}

Module:AddNewAuraWatch("HUNTER", list)
