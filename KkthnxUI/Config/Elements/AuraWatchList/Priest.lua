local K = KkthnxUI[1]
local Module = K:GetModule("AurasTable")

if K.Class ~= "PRIEST" then
	return
end

local list = {
	["Special Aura"] = { -- 玩家重要光环组
		-- Buffs
		-- Blessed Recovery
		{ AuraID = 27813, UnitID = "player", Caster = "player" },
		-- Focused Casting [Martyrdom]
		{ AuraID = 14743, UnitID = "player", Caster = "player" },
		-- Spirit Tap
		{ AuraID = 15271, UnitID = "player", Caster = "player" },
		-- Surge of Light [Season of Discovery]
		{ AuraID = 431666, UnitID = "player", Caster = "player" },

		-- Item Sets
		-- Divine Protection (Absorb, Proc) [Vestments of the Devout / Vestments of the Virtuous]
		{ AuraID = 27779, UnitID = "player", Caster = "player" },
		-- Epiphany (Mp5, Proc) [Vestments of Faith]
		{ AuraID = 28804, UnitID = "player", Caster = "player" },
		-- Reactive Fade (Special, Proc) [Vestments of Transcendence]
		{ AuraID = 21976, UnitID = "player", Caster = "player" },

		-- Trinkets
		-- Class
		-- Aegis of Preservation (Special, Use) [Aegis of Preservation]
		{ AuraID = 23780, UnitID = "player", Caster = "player" },
		-- Rapid Healing (Special, Use) [Hazza'rah's Charm of Healing]
		{ AuraID = 24546, UnitID = "player", Caster = "player" },

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
	},
	["Spell Cooldown"] = { -- 冷却计时组
		-- Self
		-- Circle of Healing [Season of Discovery]
		{ AuraID = 401946 },
		-- Desperate Prayer
		{ AuraID = 13908 },
		-- Devouring Plague
		{ AuraID = 2944 },
		-- Dispersion [Season of Discovery]
		{ AuraID = 425294 },
		-- Elune's Grace
		{ AuraID = 2651 },
		-- Eye of the Void [Season of Discovery]
		{ AuraID = 402789 },
		-- Fade
		{ AuraID = 586 },
		-- Fear Ward
		{ AuraID = 6346 },
		-- Feedback
		{ AuraID = 13896 },
		-- Homunculi [Season of Discovery]
		{ AuraID = 402799 },
		-- Inner Focus
		{ AuraID = 14751 },
		-- Lightwell
		{ AuraID = 724 },
		-- Mind Blast
		{ AuraID = 8092 },
		-- Penance [Season of Discovery]
		{ AuraID = 402174 },
		-- Power Infusion
		{ AuraID = 10060 },
		-- Power Word: Barrier [Season of Discovery]
		{ AuraID = 425207 },
		-- Power Word: Shield
		{ AuraID = 17 },
		-- Prayer of Mending [Season of Discovery]
		{ AuraID = 401859 },
		-- Psychic Scream
		{ AuraID = 8122 },
		-- Shadow Word: Death [Season of Discovery]
		{ AuraID = 401955 },
		-- Spirit of the Redeemer [Season of Discovery]
		{ AuraID = 425284 },
		-- Silence
		{ AuraID = 15487 },
		-- Starshards
		{ AuraID = 10797 },
		-- Vampiric Embrace
		{ AuraID = 15286 },
		-- Void Plague [Season of Discovery]
		{ AuraID = 425204 },
		-- Void Zone [Season of Discovery]
		{ AuraID = 431681 },

		-- Racial
		-- Berserking (Mana)
		{ AuraID = 20554 },
		-- Cannibalize (Forsaken)
		{ AuraID = 20577 },
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

Module:AddNewAuraWatch("PRIEST", list)
