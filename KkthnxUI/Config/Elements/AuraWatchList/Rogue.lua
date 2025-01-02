local K, L = KkthnxUI[1], KkthnxUI[3]
local Module = K:GetModule("AurasTable")

if K.Class ~= "ROGUE" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 2983, UnitID = "player" }, -- 疾跑
		{ AuraID = 5171, UnitID = "player" }, -- 切割
		--{AuraID = 26669, UnitID = "player"},	-- 闪避
		--{AuraID = 26888, UnitID = "player"},	-- 消失
		{ AuraID = 13750, UnitID = "player" }, -- 冲动
		{ AuraID = 13877, UnitID = "player" }, -- 剑刃乱舞
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
		{ SpellID = 13750 }, -- 冲动
	},
}

Module:AddNewAuraWatch("ROGUE", list)
