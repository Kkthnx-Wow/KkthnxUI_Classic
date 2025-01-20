local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "PALADIN" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		-- Buffs
		-- Aegis [Season of Discovery]
		{ AuraID = 425585, UnitID = "player", Caster = "player" },
		-- Reckoning
		{ AuraID = 20178, UnitID = "player", Caster = "player" },
		-- Redoubt
		{ AuraID = 20128, UnitID = "player", Caster = "player" },
		-- The Art of War [Season of Discovery]
		{ AuraID = 53489, UnitID = "player", Caster = "player" },

		-- Item Sets
		-- Crusader's Wrath (Spell Power, Proc) [Lightforge Armor / Soulforge Armor]
		{ AuraID = 27499, UnitID = "player", Caster = "player" },

		-- Trinkets
		-- Class
		-- Blinding Light (Haste, Use) [Tome of Fiery Redemption]
		{ AuraID = 23733, UnitID = "player", Caster = "player" },
		-- Brilliant Light (Spell Critical Strike, Use) [Gri'lek's Charm of Valor]
		{ AuraID = 24498, UnitID = "player", Caster = "player" },

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

		-- Healing
		-- Chromatic Infusion (Healing Power, Use) [Draconic Infused Emblem]
		{ AuraID = 27675, UnitID = "player", Caster = "player" },
		-- Healing of the Ages (Healing Power, Use) [Hibernation Crystal]
		{ AuraID = 24998, UnitID = "player", Caster = "player" },
		-- Mar'li's Brain Boost (Mp5, Use) [Mar'li's Eye]
		{ AuraID = 24268, UnitID = "player", Caster = "player" },
		-- Persistent Shield (Absorb, Use) [Scarab Brooch]
		{ AuraID = 26467, UnitID = "player", Caster = "player" },
		-- The Eye of the Dead (Special, Use) [Eye of the Dead]
		{ AuraID = 28780, UnitID = "player", Caster = "player" },

		-- Rings
		-- Spell Blasting (Spell Power, Proc) [Wrath of Cenarius]
		{ AuraID = 25906, UnitID = "player", Caster = "player" },

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
		-- Avenger's Shield [Season of Discovery]
		{ AuraID = 407669 },
		-- Blessing of Freedom
		{ AuraID = 1044 },
		-- Blessing of Protection
		{ AuraID = 1022 },
		-- Blessing of Sacrifice
		{ AuraID = 6940 },
		-- Consecration
		{ AuraID = 26573 },
		-- Crusader Strike [Season of Discovery]
		{ AuraID = 407676 },
		-- Divine Favor
		{ AuraID = 20216 },
		-- Divine Intervention
		{ AuraID = 19752 },
		-- Divine Protection
		{ AuraID = 498 },
		-- Divine Sacrifice [Season of Discovery]
		{ AuraID = 407804 },
		-- Divine Shield
		{ AuraID = 642 },
		-- Divine Storm [Season of Discovery]
		{ AuraID = 407778 },
		-- Exorcism
		{ AuraID = 879 },
		-- Exorcism [Season of Discovery]
		-- {spellID = 415068, },
		-- Hammer of Justice
		{ AuraID = 853 },
		-- Hammer of the Righteous [Season of Discovery]
		{ AuraID = 407632 },
		-- Hammer of Wrath
		{ AuraID = 24275 },
		-- Hand of Reckoning [Season of Discovery]
		{ AuraID = 407631 },
		-- Holy Shield
		{ AuraID = 20925 },
		-- Holy Shock
		{ AuraID = 20473 },
		-- Holy Wrath
		{ AuraID = 2812 },
		-- Horn of Lordaeron [Season of Discovery]
		{ AuraID = 425600 },
		-- Judgement
		{ AuraID = 20271 },
		-- Lay on Hands
		{ AuraID = 633 },
		-- Rebuke [Season of Discovery]
		{ AuraID = 425609 },
		-- Repentance
		{ AuraID = 20066 },
		-- Turn Evil
		{ AuraID = 10326 },
		-- Turn Undead
		{ AuraID = 2878 },

		-- Racial
		-- Perception (Human)
		{ AuraID = 20600 },
		-- Stoneform (Dwarf)
		{ AuraID = 20594 },

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

Module:AddNewAuraWatch("PALADIN", list)
