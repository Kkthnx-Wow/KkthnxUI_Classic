local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "DRUID" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		-- Buffs
		-- Clearcasting [Omen of Clarity]
		{ AuraID = 16870, UnitID = "player", Caster = "player" },
		-- Eclipse (Lunar) [Season of Discovery]
		{ AuraID = 408255, UnitID = "player", Caster = "player" },
		-- Eclipse (Solar) [Season of Discovery]
		{ AuraID = 408250, UnitID = "player", Caster = "player" },
		-- Fury of Stormrage [Season of Discovery]
		{ AuraID = 414800, UnitID = "player", Caster = "player" },
		-- Dreamstate [Season of Discovery]
		{ AuraID = 408261, UnitID = "player", Caster = "player" },

		-- Trinkets
		-- Class
		-- Metamorphosis Rune (Special, Use) [Rune of Metamorphosis]
		{ AuraID = 23724, UnitID = "player", Caster = "player" },
		-- Nimble Healing Touch (Special, Use) [Wushoolay's Charm of Nature]
		{ AuraID = 24542, UnitID = "player", Caster = "player" },

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

		-- Damage [Physical]
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
		-- Bloodbark Cleave (Special, Use) [Bloodbark Crusher / Ritualist's Hammer] [Season of Discovery]
		{ AuraID = 436482, UnitID = "player", Caster = "player" },
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
		-- Barkskin
		{ AuraID = 22812 },
		-- Bash
		{ AuraID = 5211 },
		-- Berserk [Season of Discovery]
		{ AuraID = 417141 },
		-- Challenging Roar
		{ AuraID = 5209 },
		-- Cower
		{ AuraID = 8998 },
		-- Dash
		{ AuraID = 1850 },
		-- Enrage
		{ AuraID = 5229 },
		-- Faerie Fire (Feral)
		{ AuraID = 16857 },
		-- Feral Charge
		{ AuraID = 16979 },
		-- Frenzied Regeneration
		{ AuraID = 22842 },
		-- Growl
		{ AuraID = 6795 },
		-- Hurricane
		{ AuraID = 16914 },
		-- Innervate
		{ AuraID = 29166 },
		-- Mangle (Bear) [Season of Discovery]
		{ AuraID = 407995 },
		-- Nature's Grasp
		{ AuraID = 16689 },
		-- Nature's Swiftness
		{ AuraID = 17116 },
		-- Prowl
		{ AuraID = 5215 },
		-- Rebirth
		{ AuraID = 20484 },
		-- Skull Bash [Season of Discovery]
		{ AuraID = 410176 },
		-- Starsurge [Season of Discovery]
		{ AuraID = 417157 },
		-- Survival Instincts [Season of Discovery]
		{ AuraID = 408024 },
		-- Swiftmend
		{ AuraID = 18562 },
		-- Tiger's Fury
		{ AuraID = 5217 },
		-- Tranquility
		{ AuraID = 740 },
		-- Wild Growth [Season of Discovery]
		{ AuraID = 408120 },

		-- Racial
		-- Shadowmeld (Night Elf)
		{ AuraID = 20580 },
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

Module:AddNewAuraWatch("DRUID", list)
