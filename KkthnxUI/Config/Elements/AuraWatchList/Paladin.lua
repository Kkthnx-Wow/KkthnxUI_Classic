local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "PALADIN" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 498, UnitID = "player" }, -- 圣佑术
		{ AuraID = 642, UnitID = "player" }, -- 圣盾术
		--{AuraID = 27155, UnitID = "player"},	-- 正义圣印
		--{AuraID = 27160, UnitID = "player"},	-- 光明圣印
		--{AuraID = 27166, UnitID = "player"},	-- 智慧圣印
		--{AuraID = 31884, UnitID = "player"},	-- 复仇之怒
		--{AuraID = 31895, UnitID = "player"},	-- 公正圣印
		--{AuraID = 348704, UnitID = "player"},	-- 复仇圣印
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
	},
}

Module:AddNewAuraWatch("PALADIN", list)
