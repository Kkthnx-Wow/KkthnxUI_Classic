local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "SHAMAN" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		-- Buffs
		-- Clearcasting (Elemental Focus)
		{ AuraID = 16246, UnitID = "player", Caster = "player" },
		-- Focused Casting (Eye of the Storm)
		{ AuraID = 29063, UnitID = "player", Caster = "player" },
		-- Maelstrom Weapon [Season of Discovery]
		{ AuraID = 409946, UnitID = "player", Caster = "player" },
		-- Power Surge [Season of Discovery]
		{ AuraID = 415105, UnitID = "player", Caster = "player" },
		-- Shield Mastery [Season of Discovery]
		{ AuraID = 408524, UnitID = "player", Caster = "player" },
		-- Tidal Waves [Season of Discovery]
		{ AuraID = 432041, UnitID = "player", Caster = "player" },

		-- Item Sets
		-- Lightning Shield (Mp5, Proc) [The Earthshatterer]
		-- {AuraID = 28820, UnitID = "player", Caster = "player"},
		-- Stormcaller's Wrath (Spell Power, Proc) [Stormcaller's Garb]
		{ AuraID = 26121, UnitID = "player", Caster = "player" },
		-- The Furious Storm (Spell Power, Proc) [The Elements / The Five Thunders]
		{ AuraID = 27775, UnitID = "player", Caster = "player" },

		-- Trinkets
		-- Class
		-- Energized Shield (Special, Use) [Wushoolay's Charm of Spirits]
		{ AuraID = 24499, UnitID = "player", Caster = "player" },
		-- Nature Aligned (Spell Power, Use) [Natural Alignment Crystal]
		{ AuraID = 23734, UnitID = "player", Caster = "player" },

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
		-- Stun (Special, Proc) [Bloodstorm War Totem / Corrupted Smashbringer] [Season of Discovery]
		{ AuraID = 446707, UnitID = "target", Caster = "player" },

		-- Enchants
		-- Holy Strength (Strength) [Enchant Weapon - Crusader]
		{ AuraID = 20007, UnitID = "player", Caster = "player" },
	},
	["Spell Cooldown"] = { -- 冷却计时组
		-- Self
		-- Ancestral Guidance [Season of Discovery]
		{ AuraID = 409324 },
		-- Chain Lightning
		{ AuraID = 421 },
		-- Decoy Totem [Season of Discovery]
		{ AuraID = 425874 },
		-- Earth Shock
		{ AuraID = 8042 },
		-- Earth Shock (Way of Earth) [Season of Discovery]
		-- {AuraID = 408681},
		-- Earthbind Totem
		{ AuraID = 2484 },
		-- Elemental Mastery
		{ AuraID = 16166 },
		-- Fire Nova [Season of Discovery]
		{ AuraID = 408341 },
		-- Fire Nova Totem
		{ AuraID = 1535 },
		-- Flame Shock
		{ AuraID = 8050 },
		-- Frost Shock
		{ AuraID = 8056 },
		-- Grounding Totem
		{ AuraID = 8177 },
		-- Healing Rain [Season of Discovery]
		{ AuraID = 415236 },
		-- Lava Burst [Season of Discovery]
		{ AuraID = 408490 },
		-- Lava Lash [Season of Discovery]
		{ AuraID = 408507 },
		-- Mana Tide Totem
		{ AuraID = 16190 },
		-- Molten Blast [Season of Discovery]
		{ AuraID = 425339 },
		-- Nature's Swiftness
		{ AuraID = 16188 },
		-- Reincarnation
		{ AuraID = 20608 },
		-- Riptide [Season of Discovery]
		{ AuraID = 408521 },
		-- Shamanistic Rage [Season of Discovery]
		{ AuraID = 425336 },
		-- Stoneclaw Totem
		{ AuraID = 5730 },
		-- Stormstrike
		{ AuraID = 17364 },

		-- Racial
		-- Berserking (Mana)
		{ AuraID = 20554 },
		-- Blood Fury
		{ AuraID = 23234 },
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

Module:AddNewAuraWatch("SHAMAN", list)
