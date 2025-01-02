local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "MAGE" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 66, UnitID = "player" }, -- 隐形术
		--{AuraID = 27131, UnitID = "player"},	-- 法力护盾
		--{AuraID = 27128, UnitID = "player"},	-- 防护火焰结界
		--{AuraID = 32796, UnitID = "player"},	-- 防护冰霜结界
		--{AuraID = 45438, UnitID = "player"},	-- 寒冰屏障
		{ AuraID = 11129, UnitID = "player" }, -- 燃烧
		{ AuraID = 12042, UnitID = "player" }, -- 奥术强化
		{ AuraID = 12472, UnitID = "player" }, -- 冰冷血脉
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
	},
}

Module:AddNewAuraWatch("MAGE", list)
