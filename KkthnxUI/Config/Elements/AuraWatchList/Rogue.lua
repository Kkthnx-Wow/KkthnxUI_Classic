local K, L = KkthnxUI[1], KkthnxUI[3]
local Module = K:GetModule("AurasTable")

if K.Class ~= "ROGUE" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		-- Buffs
		-- Remorseless Attacks
		{ AuraID = 14143, UnitID = "player", Caster = "player" },

		-- Item Sets
		-- Bloodfang (HoT, Proc) [Bloodfang Armor]
		{ AuraID = 23580, UnitID = "player", Caster = "player" },
		-- Revealed Flaw (Special, Proc) [Bonescythe Armor]
		{ AuraID = 28815, UnitID = "player", Caster = "player" },

		-- Trinkets
		-- Class
		-- Venomous Totem (Special, Use) [Venomous Totem]
		{ AuraID = 23726, UnitID = "player", Caster = "player" },

		-- PvP Trinkets
		-- Aura of Protection (Absorb, Use) [Arena Grand Master]
		{ AuraID = 23506, UnitID = "player", Caster = "player" },
		-- Damage Absorb (Absorb, Use) [Arathi Basin Trinket]
		{ AuraID = 25750, UnitID = "player", Caster = "player" },

		-- Universal
		-- Arcane Shroud (Threat Reduction, Use) [Fetish of the Sand Reaver]
		{ AuraID = 26400, UnitID = "player", Caster = "player" },
		-- Chitinous Spikes (Special, Use) [Fetish of Chitinous Spikes]
		{ AuraID = 26168, UnitID = "player", Caster = "player" },
		-- Heart of the Scale (Special, Use) [Heart of the Scale]
		{ AuraID = 17275, UnitID = "player", Caster = "player" },
		-- Loatheb's Reflection (Magic Resistance, Use) [Loatheb's Reflection]
		{ AuraID = 28778, UnitID = "player", Caster = "player" },
		-- Mercurial Shield (Magic Resistance, Use) [Petrified Scarab]
		{ AuraID = 26464, UnitID = "player", Caster = "player" },
		-- The Burrower's Shell (Absorb, Use) [The Burrower's Shell]
		{ AuraID = 29506, UnitID = "player", Caster = "player" },
		-- The Lion Horn of Stormwind (Special, Proc) [The Lion Horn of Stormwind]
		{ AuraID = 18946, UnitID = "player", Caster = "player" },

		-- Damage [Physical]
		-- Earthstrike (Attack Power, Use) [Earthstrike]
		{ AuraID = 25891, UnitID = "player", Caster = "player" },
		-- Insight of the Qiraji (Armor Penetration, Use) [Badge of the Swarmguard]
		{ AuraID = 26481, UnitID = "player", Caster = "player" },
		-- Jom Gabbar (Attack Power, Use) [Jom Gabbar]
		{ AuraID = 29604, UnitID = "player", Caster = "player" },
		-- Kiss of the Spider (Physical Haste, Use) [Kiss of the Spider]
		{ AuraID = 28866, UnitID = "player", Caster = "player" },
		-- Restless Strength (Special, Use) [Zandalarian Hero Medallion]
		{ AuraID = 24662, UnitID = "player", Caster = "player" },
		-- Slayer's Crest (Attack Power, Use) [Slayer's Crest]
		{ AuraID = 28777, UnitID = "player", Caster = "player" },

		-- Weapons
		-- Haste (Physical Haste, Proc) [Manual Crowd Pummeler]
		{ AuraID = 13494, UnitID = "player", Caster = "player" },
		-- Haste (Physical Haste, Proc) [Empyrean Demolisher]
		{ AuraID = 21165, UnitID = "player", Caster = "player" },

		-- Enchants
		-- Holy Strength (Strength) [Enchant Weapon - Crusader]
		{ AuraID = 20007, UnitID = "player", Caster = "player" },
	},
	["Spell Cooldown"] = { -- 冷却计时组
		-- Self
		-- Adrenaline Rush
		{ AuraID = 13750 },
		-- Between the Eyes [Season of Discovery]
		{ AuraID = 400009 },
		-- Blade Flurry
		{ AuraID = 13877 },
		-- Blind
		{ AuraID = 2094 },
		-- Cold Blood
		{ AuraID = 14177 },
		-- Distract
		{ AuraID = 1725 },
		-- Evasion
		{ AuraID = 5277 },
		-- Feint
		{ AuraID = 1966 },
		-- Ghostly Strike
		{ AuraID = 14278 },
		-- Gouge
		{ AuraID = 1776 },
		-- Kick
		{ AuraID = 1766 },
		-- Kidney Shot
		{ AuraID = 408 },
		-- Main Gauche [Season of Discovery]
		{ AuraID = 424919 },
		-- Poisoned Knife [Season of Discovery]
		{ AuraID = 425012 },
		-- Premeditation
		{ AuraID = 14183 },
		-- Preparation
		{ AuraID = 14185 },
		-- Riposte
		{ AuraID = 14251 },
		-- Shadowstep [Season of Discovery]
		{ AuraID = 400029 },
		-- Sprint
		{ AuraID = 2983 },
		-- Stealth
		{ AuraID = 1784 },
		-- Tease [Season of Discovery]
		{ AuraID = 410412 },
		-- Vanish
		{ AuraID = 1856 },

		-- Racial
		-- Berserking (Energy)
		{ AuraID = 26297 },
		-- Blood Fury
		{ AuraID = 23234 },
		-- Cannibalize (Forsaken)
		{ AuraID = 20577 },
		-- Escape Artist (Gnome)
		{ AuraID = 20589 },
		-- Perception (Human)
		{ AuraID = 20600 },
		-- Shadowmeld (Night Elf)
		{ AuraID = 20580 },
		-- Stoneform (Dwarf)
		{ AuraID = 20594 },
		-- Will of the Forsaken (Forsaken)
		{ AuraID = 7744 },

		-- Items
		-- Back
		{ SlotID = 15 },
		-- Belt
		{ SlotID = 6 },
		-- Gloves
		{ SlotID = 10 },
		-- Neck
		{ SlotID = 2 },
		-- Rings
		{ SlotID = 11 },
		{ SlotID = 12 },
		-- Trinkets
		{ SlotID = 13 },
		{ SlotID = 14 },
	},
}

Module:AddNewAuraWatch("ROGUE", list)
