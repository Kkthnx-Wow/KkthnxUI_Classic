local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "WARLOCK" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 28610, UnitID = "pet" }, -- 防护暗影结界
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
	},
}

Module:AddNewAuraWatch("WARLOCK", list)
