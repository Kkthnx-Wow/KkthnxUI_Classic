local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "WARRIOR" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 871, UnitID = "player" }, -- 盾墙
		{ AuraID = 1719, UnitID = "player" }, -- 战吼
		{ AuraID = 7384, UnitID = "player" }, -- 压制
		{ AuraID = 12975, UnitID = "player" }, -- 破釜沉舟
		{ AuraID = 12292, UnitID = "player" }, -- 浴血奋战
		{ AuraID = 23920, UnitID = "player" }, -- 法术反射
		{ AuraID = 18499, UnitID = "player" }, -- 狂暴之怒
	},
	["Focus Aura"] = { -- 焦点光环组
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
	},
}

Module:AddNewAuraWatch("WARRIOR", list)
