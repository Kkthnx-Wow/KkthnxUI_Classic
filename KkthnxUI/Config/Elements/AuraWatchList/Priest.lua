local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "PRIEST" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 6346, UnitID = "player" }, -- 防恐结界
		{ AuraID = 10060, UnitID = "player" }, -- 能量灌注
		{ AuraID = 27827, UnitID = "player" }, -- 救赎之魂
		--{AuraID = 25218, UnitID = "player"},	-- 真言术：盾
		--{AuraID = 25222, UnitID = "player"},	-- 恢复
		--{AuraID = 25429, UnitID = "player"},	-- 渐隐术
		--{AuraID = 41635, UnitID = "player"},	-- 愈合祷言
	},
	["Focus Aura"] = { -- 焦点光环组
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
	},
}

Module:AddNewAuraWatch("PRIEST", list)
