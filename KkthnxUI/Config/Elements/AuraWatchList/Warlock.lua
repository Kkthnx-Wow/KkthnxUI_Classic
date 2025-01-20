local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "WARLOCK" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		-- Buffs
		-- Dance of the Wicked [Season of Discovery]
		{ AuraID = 412800, UnitID = "player", Caster = "player" },
		-- Demonic Knowledge [Season of Discovery]
		-- {spellID = 412735, UnitID ="player", Caster = "player"},
		-- Shadow and Flame [Season of Discovery]
		{ AuraID = 426311, UnitID = "player", Caster = "player" },
		-- Shadow Trance
		{ AuraID = 17941, UnitID = "player", Caster = "player" },

		-- Trinkets
		-- Class
		-- Blessing of the Black Book (Special, Use) [The Black Book]
		{ AuraID = 23720, UnitID = "pet", Caster = "player" },
		-- Massive Destruction (Spell Critical Strike, Use) [Hazza'rah's Charm of Destruction]
		{ AuraID = 24543, UnitID = "player", Caster = "player" },

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
	},
	["Spell Cooldown"] = { -- 冷却计时组
		-- Self
		-- Amplify Curse
		{ AuraID = 18288 },
		-- Chaos Bolt [Season of Discovery]
		{ AuraID = 403629 },
		-- Conflagrate
		{ AuraID = 17962 },
		-- Curse of Doom
		{ AuraID = 603 },
		-- Death Coil
		{ AuraID = 6789 },
		-- Demon Charge (Metamorphosis) [Season of Discovery]
		{ AuraID = 412788 },
		-- Demonic Grace (Metamorphosis) [Season of Discovery]
		{ AuraID = 425463 },
		-- Demonic Howl (Metamorphosis) [Season of Discovery]
		{ AuraID = 412789 },
		-- Drain Life [Season of Discovery]
		{ AuraID = 403677 },
		-- Fel Domination
		{ AuraID = 18708 },
		-- Haunt [Season of Discovery]
		{ AuraID = 403501 },
		-- Howl of Terror
		{ AuraID = 5484 },
		-- Inferno
		{ AuraID = 1122 },
		-- Menace (Metamorphosis) [Season of Discovery]
		{ AuraID = 403828 },
		-- Ritual of Doom
		{ AuraID = 18540 },
		-- Shadow Cleave (Metamorphosis) [Season of Discovery]
		{ AuraID = 403835 },
		-- Shadowflame [Season of Discovery]
		{ AuraID = 426320 },
		-- Shadow Ward
		{ AuraID = 6229 },
		-- Shadowburn
		{ AuraID = 17877 },
		-- Soul Fire
		{ AuraID = 6353 },
		-- Vengeance [Season of Discovery]
		{ AuraID = 426195 },

		-- Pets
		-- Rain of Fire (Doomguard)
		{ AuraID = 4629 },
		-- Spell Lock (Felhunter)
		{ AuraID = 19244 },
		-- Suffering (Voidwalker)
		{ AuraID = 17735 },

		-- Racial
		-- Blood Fury
		{ AuraID = 23234 },
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

Module:AddNewAuraWatch("WARLOCK", list)
