local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "HUNTER" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		{ AuraID = 3045, UnitID = "player" }, -- Rapid Fire
		{ AuraID = 6150, UnitID = "player" }, -- Quick Shots
		{ AuraID = 409507, UnitID = "player" }, -- Expose Weakness
		{ AuraID = 440531, UnitID = "player" }, -- Hit and Run
		{ AuraID = 19574, UnitID = "pet" }, -- Bestial Wrath
		{ AuraID = 19577, UnitID = "pet" }, -- Intimidation
	},
	["Spell Cooldown"] = { -- 冷却计时组
		{ SlotID = 13 }, -- 饰品1
		{ SlotID = 14 }, -- 饰品2
	},
}

Module:AddNewAuraWatch("HUNTER", list)
