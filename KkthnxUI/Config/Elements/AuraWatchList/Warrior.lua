local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "WARRIOR" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		-- Buffs
		-- Blood Craze
		{ AuraID = 16488, UnitID = "player", Caster = "player" },
		-- Blood Surge [Season of Discovery]
		{ AuraID = 413399, UnitID = "player", Caster = "player" },
		-- Enrage
		{ AuraID = 12880, UnitID = "player", Caster = "player" },
		-- Enrage (Consumed By Rage) [Season of Discovery]
		{ AuraID = 425415, UnitID = "player", Caster = "player" },
		-- Taste for Blood [Season of Discovery]
		{ AuraID = 426969, UnitID = "player", Caster = "player" },

		-- Item Sets
		-- Cheat Death (Special, Proc) [Dreadnaught's Battlegear]
		{ AuraID = 28846, UnitID = "player", Caster = "player" },
		-- Parry (Parry, Proc) [Battlegear of Wrath]
		{ AuraID = 23547, UnitID = "player", Caster = "player" },
		-- Warrior's Wrath (Special, Proc) [Battlegear of Wrath]
		{ AuraID = 21887, UnitID = "player", Caster = "player" },

		-- Trinkets
		-- Class
		-- Gift of Life (Health, Use) [Lifegiving Gem]
		{ AuraID = 23725, UnitID = "player", Caster = "player" },

		-- Darkmoon Cards
		-- Aura of the Blue Dragon (Special, Proc) [Darkmoon Card: Blue Dragon]
		{ AuraID = 23684, UnitID = "player", Caster = "player" },
		-- Decay (Special, Proc) [Darkmoon Card: Decay] [Season of Discovery]
		{ AuraID = 446393, UnitID = "target", Caster = "player" },
		-- Overgrowth (Special, Proc) [Darkmoon Card: Overgrowth] [Season of Discovery]
		{ AuraID = 446394, UnitID = "player", Caster = "player" },
		-- Torment (Special, Proc) [Darkmoon Card: Torment] [Season of Discovery]
		{ AuraID = 446391, UnitID = "target", Caster = "player" },

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

		-- Tanking
		-- Brittle Armor (Special, Use) [Zandalarian Hero Badge]
		{ AuraID = 24575, UnitID = "player", Caster = "player" },
		-- Force of Will (Special, Proc) [Force of Will]
		{ AuraID = 15595, UnitID = "player", Caster = "player" },
		-- Glyph of Deflection (Block Value, Use) [Glyph of Deflection]
		{ AuraID = 28773, UnitID = "player", Caster = "player" },

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
		-- Parasomnia (Special, Proc) [Parasomnia] [Season of Discovery]
		{ AuraID = 446707, UnitID = "target", Caster = "player" },
		-- Strength of the Champion (Strength, Proc) [Arcanite Champion]
		{ AuraID = 16916, UnitID = "player", Caster = "player" },

		-- Enchants
		-- Holy Strength (Strength) [Enchant Weapon - Crusader]
		{ AuraID = 20007, UnitID = "player", Caster = "player" },
	},
	["Spell Cooldown"] = { -- 冷却计时组
		-- Self
		-- Berserker Rage
		{ AuraID = 18499 },
		-- Bloodrage
		{ AuraID = 2687 },
		-- Bloodthirst
		{ AuraID = 23881 },
		-- Challenging Shout
		{ AuraID = 1161 },
		-- Charge
		{ AuraID = 100 },
		-- Concussion Blow
		{ AuraID = 12809 },
		-- Death Wish
		{ AuraID = 12328 },
		-- Disarm
		{ AuraID = 676 },
		-- Enraged Regeneration [Season of Discovery]
		{ AuraID = 402913 },
		-- Heroic Strike
		{ AuraID = 78 },
		-- Intercept
		{ AuraID = 20252 },
		-- Intervene [Season of Discovery]
		{ AuraID = 403338 },
		-- Intimidating Shout
		{ AuraID = 5246 },
		-- Last Stand
		{ AuraID = 12975 },
		-- Mocking Blow
		{ AuraID = 694 },
		-- Mortal Strike
		{ AuraID = 12294 },
		-- Overpower
		{ AuraID = 7384 },
		-- Pummel
		{ AuraID = 6552 },
		-- Raging Blow [Season of Discovery]
		{ AuraID = 402911 },
		-- Rallying Cry [Season of Discovery]
		{ AuraID = 426490 },
		-- Recklessness
		{ AuraID = 1719 },
		-- Retaliation
		{ AuraID = 20230 },
		-- Revenge
		{ AuraID = 6572 },
		-- Shield Bash
		{ AuraID = 72 },
		-- Shield Block
		{ AuraID = 2565 },
		-- Shield Slam
		{ AuraID = 23922 },
		-- Shield Wall
		{ AuraID = 871 },
		-- Slam [Season of Discovery]
		{ AuraID = 1464 },
		-- Sweeping Strikes
		{ AuraID = 12292 },
		-- Taunt
		{ AuraID = 355 },
		-- Thunder Clap
		{ AuraID = 6343 },
		-- Victory Rush [Season of Discovery]
		{ AuraID = 402927 },
		-- Whirlwind
		{ AuraID = 1680 },

		-- Racial
		-- Berserking (Rage)
		{ AuraID = 26296 },
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
		-- War Stomp (Tauren)
		{ AuraID = 20549 },
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

Module:AddNewAuraWatch("WARRIOR", list)
