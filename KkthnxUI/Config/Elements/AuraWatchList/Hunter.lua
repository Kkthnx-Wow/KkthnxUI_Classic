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
		-- Additional spells from Wago
		{ AuraID = 186257, UnitID = "player" }, -- 猎豹守护
		{ AuraID = 186265, UnitID = "player" }, -- 灵龟守护
		{ AuraID = 193526, UnitID = "player" }, -- 百发百中
	},
	["Focus Aura"] = { -- 焦点光环组
		-- Additional spells from Wago (if any focus-specific spells are listed)
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		-- Additional cooldowns from Wago
		{ SpellID = 109304, UnitID = "player" }, -- 意气风发
		{ SpellID = 186257, UnitID = "player" }, -- 猎豹守护
		{ SpellID = 193526, UnitID = "player" }, -- 百发百中
	},
}

Module:AddNewAuraWatch("HUNTER", list)
