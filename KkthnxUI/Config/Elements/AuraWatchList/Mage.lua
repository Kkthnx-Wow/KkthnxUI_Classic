local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "MAGE" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		-- Buffs
		-- Clearcasting [Arcane Concentration]
		{ AuraID = 12536, UnitID = "player", Caster = "player" },
		-- Fingers of Frost [Season of Discovery]
		{ AuraID = 400669, UnitID = "player", Caster = "player" },
		-- Fireball! [Brain Freeze] [Season of Discovery]
		{ AuraID = 400730, UnitID = "player", Caster = "player" },
		-- Hot Streak [Season of Discovery]
		{ AuraID = 400624, UnitID = "player", Caster = "player" },
		-- Missile Barrage [Season of Discovery]
		{ AuraID = 400589, UnitID = "player", Caster = "player" },

		-- Item Sets
		-- Enigma's Answer (Spell Hit, Proc) [Enigma Vestments]
		{ AuraID = 26129, UnitID = "player", Caster = "player" },
		-- Fire Resistance (Fire Resistance, Proc) [Frostfire Regalia]
		{ AuraID = 28765, UnitID = "player", Caster = "player" },
		-- Frost Resistance (Frost Resistance, Proc) [Frostfire Regalia]
		{ AuraID = 28766, UnitID = "player", Caster = "player" },
		-- Nature Resistance (Nature Resistance, Proc) [Frostfire Regalia]
		{ AuraID = 28768, UnitID = "player", Caster = "player" },
		-- Shadow Resistance (Shadow Resistance, Proc) [Frostfire Regalia]
		{ AuraID = 28769, UnitID = "player", Caster = "player" },
		-- Arcane Resistance (Arcane Resistance, Proc) [Frostfire Regalia]
		{ AuraID = 28770, UnitID = "player", Caster = "player" },
		-- Netherwind Focus (Special, Proc) [Netherwind Regalia]
		{ AuraID = 22008, UnitID = "player", Caster = "player" },
		-- Not There (Special, Proc) [Frostfire Regalia]
		{ AuraID = 28762, UnitID = "player", Caster = "player" },

		-- Trinkets
		-- Class
		-- Arcane Potency (Spell Power, Use) [Hazza'rah's Charm of Magic]
		{ AuraID = 24544, UnitID = "player", Caster = "player" },
		-- Mind Quickening (Spell Haste, Use) [Mind Quickening Gem]
		{ AuraID = 23723, UnitID = "player", Caster = "player" },

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

		-- Damage [Magic]
		-- Ascendance (Spell Power, Use) [Talisman of Ascendance]
		{ AuraID = 28204, UnitID = "player", Caster = "player" },
		-- Ephemeral Power (Spell Power, Use) [Talisman of Ephemeral Power]
		{ AuraID = 23271, UnitID = "player", Caster = "player" },
		-- Essence of Sapphiron (Spell Power, Use) [The Restrained Essence of Sapphiron]
		{ AuraID = 28779, UnitID = "player", Caster = "player" },
		-- Obsidian Insight (Spell Power, Special, Use) [Eye of Moam]
		{ AuraID = 26166, UnitID = "player", Caster = "player" },
		-- Pagle's Broken Reel (Spell Hit, Use) [Nat Pagle's Broken Reel]
		{ AuraID = 24610, UnitID = "player", Caster = "player" },
		-- The Eye of Diminution (Special, Use) [Eye of Diminution]
		{ AuraID = 28862, UnitID = "player", Caster = "player" },
		-- Unstable Power (Spell Power, Use) [Zandalarian Hero Charm]
		{ AuraID = 24659, UnitID = "player", Caster = "player" },

		-- Rings
		-- Spell Blasting (Spell Power, Proc) [Wrath of Cenarius]
		{ AuraID = 25906, UnitID = "player", Caster = "player" },
	},
	["Spell Cooldown"] = { -- 冷却计时组
		-- Self
		-- Arcane Power
		{ AuraID = 12042 },
		-- Arcane Surge [Season of Discovery]
		{ AuraID = 425124 },
		-- Blast Wave
		{ AuraID = 11113 },
		-- Blink
		{ AuraID = 1953 },
		-- Cold Snap
		{ AuraID = 12472 },
		-- Combustion
		{ AuraID = 11129 },
		-- Cone of Cold
		{ AuraID = 120 },
		-- Counterspell
		{ AuraID = 2139 },
		-- Displacement [Season of Discovery]
		{ AuraID = 428861 },
		-- Fire Blast
		{ AuraID = 2136 },
		-- Fire Ward
		{ AuraID = 543 },
		-- Frost Nova
		{ AuraID = 122 },
		-- Frost Ward
		{ AuraID = 6143 },
		-- Frozen Orb [Season of Discovery]
		{ AuraID = 440802 },
		-- Ice Barrier
		{ AuraID = 11426 },
		-- Ice Block
		{ AuraID = 11958 },
		-- Icy Veins [Season of Discovery]
		{ AuraID = 429125 },
		-- Living Flame [Season of Discovery]
		{ AuraID = 401556 },
		-- Presence of Mind
		{ AuraID = 12043 },
		-- Rewind Time [Season of Discovery]
		{ AuraID = 401462 },
		-- Temporal Anomaly [Season of Discovery]
		{ AuraID = 428885 },

		-- Racial
		-- Berserking (Mana)
		{ AuraID = 20554 },
		-- Cannibalize (Forsaken)
		{ AuraID = 20577 },
		-- Escape Artist (Gnome)
		{ AuraID = 20589 },
		-- Perception (Human)
		{ AuraID = 20600 },
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

Module:AddNewAuraWatch("MAGE", list)
