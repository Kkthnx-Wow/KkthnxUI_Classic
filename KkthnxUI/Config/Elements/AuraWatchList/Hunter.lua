local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "HUNTER" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		-- Buffs
		-- Cobra Strikes [Season of Discovery]
		{ AuraID = 425714, UnitID = "pet", Caster = "player" },
		-- Quick Shots
		{ AuraID = 6150, UnitID = "player", Caster = "player" },

		-- Trinkets
		-- Class
		-- Arcane Infused (Special, Use) [Arcane Infused Gem]
		{ AuraID = 23721, UnitID = "player", Caster = "player" },
		-- Devilsaur Fury (Attack Power, Use) [Devilsaur Eye]
		{ AuraID = 24352, UnitID = "player", Caster = "player" },

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
	},
	["Spell Cooldown"] = { -- 冷却计时组
		-- Self
		-- Arcane Shot
		{ AuraID = 3044 },
		-- Aimed Shot
		{ AuraID = 19434 },
		-- Bestial Wrath
		{ AuraID = 19574 },
		-- Carve [Season of Discovery]
		{ AuraID = 425711 },
		-- Chimera Shot [Season of Discovery]
		{ AuraID = 409433 },
		-- Concussive Shot
		{ AuraID = 5116 },
		-- Counterattack
		{ AuraID = 19306 },
		-- Deterrence
		{ AuraID = 19263 },
		-- Disengage
		{ AuraID = 781 },
		-- Distracting Shot
		{ AuraID = 20736 },
		-- Explosive Shot [Season of Discovery]
		{ AuraID = 409552 },
		-- Explosive Trap
		{ AuraID = 13813 },
		-- Feign Death
		{ AuraID = 5384 },
		-- Flanking Strike [Season of Discovery]
		{ AuraID = 415320 },
		-- Flare
		{ AuraID = 1543 },
		-- Freezing Trap
		{ AuraID = 1499 },
		-- Frost Trap
		{ AuraID = 13809 },
		-- Immolation Trap
		{ AuraID = 13795 },
		-- Intimidation
		{ AuraID = 19577 },
		-- Kill Command [Season of Discovery]
		{ AuraID = 409379 },
		-- Mongoose Bite
		{ AuraID = 1495 },
		-- Multi-Shot
		{ AuraID = 2643 },
		-- Rapid Fire
		{ AuraID = 3045 },
		-- Raptor Strike
		{ AuraID = 2973 },
		-- Readiness
		{ AuraID = 23989 },
		-- Scare Beast
		{ AuraID = 1513 },
		-- Scatter Shot
		{ AuraID = 19503 },
		-- Tranquilizing Shot
		{ AuraID = 19801 },
		-- Viper Sting
		{ AuraID = 3034 },
		-- Volley
		{ AuraID = 1510 },
		-- Wyvern Sting
		{ AuraID = 19386 },

		-- Pets
		-- Charge (Boar)
		{ AuraID = 7371 },
		-- Dash (Boar / Cat / Hyena / Raptor / Tallstrider / Wolf)
		{ AuraID = 23099 },
		-- Dive (Bat / Bird of Prey / Carrion Bird / Wind Serpent)
		{ AuraID = 23145 },
		-- Shell Shield (Turtle)
		{ AuraID = 26064 },
		-- Thunderstomp (Gorilla)
		{ AuraID = 26090 },

		-- Racial
		-- Berserking (Mana)
		{ AuraID = 20554 },
		-- Blood Fury
		{ AuraID = 23234 },
		-- Shadowmeld (Night Elf)
		{ AuraID = 20580 },
		-- Stoneform (Dwarf)
		{ AuraID = 20594 },
		-- War Stomp (Tauren)
		{ AuraID = 20549 },

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

Module:AddNewAuraWatch("HUNTER", list)
