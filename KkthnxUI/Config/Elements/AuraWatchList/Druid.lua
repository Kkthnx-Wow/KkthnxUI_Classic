local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "DRUID" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 5229, UnitID = "player" }, -- 激怒
		{ AuraID = 9846, UnitID = "player" }, -- 猛虎之怒
		{ AuraID = 22842, UnitID = "player" }, -- 狂暴回复
		{ AuraID = 22812, UnitID = "player" }, -- 树皮术
		{ AuraID = 16870, UnitID = "player" }, -- 节能施法
		--{AuraID = 26980, UnitID = "player"},	-- 愈合
		--{AuraID = 26982, UnitID = "player"},	-- 回春术
		--{AuraID = 33763, UnitID = "player"},	-- 生命绽放
		--{AuraID = 33357, UnitID = "player"},	-- 急奔
	},
	["Focus Aura"] = { -- 焦点光环组
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
	},
}

Module:AddNewAuraWatch("DRUID", list)
