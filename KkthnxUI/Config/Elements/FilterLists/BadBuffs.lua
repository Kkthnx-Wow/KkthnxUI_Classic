local K, C = KkthnxUI[1], KkthnxUI[2]

local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo

local function SpellName(id)
	local name = C_Spell_GetSpellInfo(id)
	if name then
		return name
	else
		K.Print("|cffff0000WARNING: [BadBuffsFilter] - spell ID [" .. tostring(id) .. "] no longer exists! Report this to Kkthnx.|r")
		return "Empty"
	end
end

C.CheckBadBuffs = {
	[SpellName(24732)] = true, -- Bat Costume
	[SpellName(24735)] = true, -- Ghost Costume
	[SpellName(24712)] = true, -- Leper Gnome Costume
	[SpellName(24710)] = true, -- Ninja Costume
	[SpellName(24709)] = true, -- Pirate Costume
	[SpellName(24723)] = true, -- Skeleton Costume
	[SpellName(24740)] = true, -- Wisp Costume
}
