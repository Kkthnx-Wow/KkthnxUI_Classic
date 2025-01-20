local K, L = KkthnxUI[1], KkthnxUI[3]
local Module = K:GetModule("AurasTable")

local list = {
	["Enchant Aura"] = { -- 附魔及饰品组
		-- 种族天赋
		{ AuraID = 26635, UnitID = "player" }, -- 狂暴 巨魔
		{ AuraID = 20572, UnitID = "player" }, -- 血性狂暴 兽人

		-- Potions: Classic
		-- Greater Stoneshield Potion
		{ AuraID = 17540, UnitID = "player", Caster = "player" },
		-- Mighty Rage Potion
		{ AuraID = 17528, UnitID = "player", Caster = "player" },
		-- Magic Resistance Potion
		{ AuraID = 11364, UnitID = "player", Caster = "player" },
		-- Greater Arcane Protection Potion
		{ AuraID = 17549, UnitID = "player", Caster = "player" },
		-- Greater Fire Protection Potion
		{ AuraID = 17543, UnitID = "player", Caster = "player" },
		-- Greater Frost Protection Potion
		{ AuraID = 17544, UnitID = "player", Caster = "player" },
		-- Greater Nature Protection Potion
		{ AuraID = 17546, UnitID = "player", Caster = "player" },
		-- Greater Shadow Protection Potion
		{ AuraID = 17548, UnitID = "player", Caster = "player" },
		-- Greater Holy Protection Potion
		{ AuraID = 17545, UnitID = "player", Caster = "player" },

		-- Potions: Miscellaneous
		-- Swiftness Potion
		{ AuraID = 2379, UnitID = "player", Caster = "player" },
		-- Lesser Invisibility Potion
		{ AuraID = 3680, UnitID = "player", Caster = "player" },
		-- Invisibility Potion
		{ AuraID = 11392, UnitID = "player", Caster = "player" },
		-- Free Action Potion
		{ AuraID = 6615, UnitID = "player", Caster = "player" },
		-- Living Action Potion
		{ AuraID = 24364, UnitID = "player", Caster = "player" },
		-- Swim Speed Potion
		{ AuraID = 7840, UnitID = "player", Caster = "player" },
		-- Restorative Potion
		{ AuraID = 11359, UnitID = "player", Caster = "player" },

		-- Miscellaneous
		-- Oil of Immolation
		{ AuraID = 11350, UnitID = "player", Caster = "player" },

		-- Professions
		-- Goblin Rocket Boots
		{ AuraID = 8892, UnitID = "player", Caster = "player" },
		-- Gnomish Rocket Boots
		{ AuraID = 13141, UnitID = "player", Caster = "player" },
		-- Parachute
		{ AuraID = 12438, UnitID = "player", Caster = "player" },

		-- Racial
		-- Berserking (Mana)
		{ AuraID = 20554, UnitID = "player", Caster = "player" },
		-- Berserking (Rage)
		{ AuraID = 26296, UnitID = "player", Caster = "player" },
		-- Berserking (Energy)
		{ AuraID = 26297, UnitID = "player", Caster = "player" },
		-- Blood Fury
		{ AuraID = 23234, UnitID = "player", Caster = "player" },
		-- Perception (Human)
		{ AuraID = 20600, UnitID = "player", Caster = "player" },
		-- Shadowmeld (Night Elf)
		{ AuraID = 20580, UnitID = "player", Caster = "player" },
		-- Stoneform (Dwarf)
		{ AuraID = 20594, UnitID = "player", Caster = "player" },
		-- Will of the Forsaken (Forsaken)
		{ AuraID = 7744, UnitID = "player", Caster = "player" },

		-- Zone Buffs
		-- Speed (Battlegrounds)
		{ AuraID = 23451, UnitID = "player", Caster = "all" },
		-- Alliance Battle Standard
		{ AuraID = 23034, UnitID = "player", Caster = "all" },
		-- Horde Battle Standard
		{ AuraID = 23035, UnitID = "player", Caster = "all" },
		-- Stormpike Battle Standard
		{ AuraID = 23539, UnitID = "player", Caster = "all" },
		-- Frostwolf Battle Standard
		{ AuraID = 23538, UnitID = "player", Caster = "all" },

		-- Damage Reduction
		-- Barkskin [Season of Discovery]
		{ AuraID = 22812, UnitID = "player", Caster = "all" },
		-- Blessing of Protection
		{ AuraID = 1022, UnitID = "player", Caster = "all" },
		-- Blessing of Sacrifice
		{ AuraID = 6940, UnitID = "player", Caster = "all" },
		-- Divine Sacrifice [Season of Discovery]
		{ AuraID = 407804, UnitID = "player", Caster = "all" },
		-- Lay on Hands (Armor Bonus)
		{ AuraID = 20233, UnitID = "player", Caster = "all" },
		-- Pain Suppression [Season of Discovery]
		{ AuraID = 402004, UnitID = "player", Caster = "all" },
		-- Power Word: Barrier [Season of Discovery]
		{ AuraID = 425205, UnitID = "player", Caster = "all" },
		-- Shamanistic Rage [Season of Discovery]
		{ AuraID = 433255, UnitID = "player", Caster = "all" },
		-- Rallying Cry [Season of Discovery]
		{ AuraID = 426490, UnitID = "player", Caster = "all" },

		-- Other
		-- Innervate
		{ AuraID = 29166, UnitID = "player", Caster = "all" },
		-- Mana Tide
		{ AuraID = 16191, UnitID = "player", Caster = "all" },
		-- Beacon of Light [Season of Discovery]
		{ AuraID = 407613, UnitID = "player", Caster = "all" },
		-- Sacred Shield [Season of Discovery]
		{ AuraID = 412019, UnitID = "player", Caster = "all" },
		-- Blessing of Freedom
		{ AuraID = 1044, UnitID = "player", Caster = "all" },
		-- Fear Ward
		{ AuraID = 6346, UnitID = "player", Caster = "all" },
		-- Grounding Totem Effect
		{ AuraID = 8178, UnitID = "player", Caster = "all" },
		-- Divine Intervention
		{ AuraID = 19752, UnitID = "player", Caster = "all" },
		-- Slow Fall
		{ AuraID = 130, UnitID = "player", Caster = "all" },
		-- Levitate
		{ AuraID = 1706, UnitID = "player", Caster = "all" },
		-- Power Infusion
		{ AuraID = 10060, UnitID = "player", Caster = "all" },
		-- Earth Shield [Season of Discovery]
		{ AuraID = 974, UnitID = "player", Caster = "all" },
		-- Spirit of the Alpha [Season of Discovery]
		{ AuraID = 408696, UnitID = "player", Caster = "all" },
		-- Soulstone Resurrection
		-- {AuraID = 20707, UnitID = "player", Caster = "all"},
		-- Intervene [Season of Discovery]
		{ AuraID = 403338, UnitID = "player", Caster = "all" },

		-- Trinket Effects
		-- Persistent Shield (Absorb, Use) [Scarab Brooch]
		{ AuraID = 26470, UnitID = "player", Caster = "all" },

		-- Season of Discovery
		-- Riptide Bubbles [Baron Aquanis]
		{ AuraID = 405688, UnitID = "player", Caster = "all" },
	},
	["Raid Buff"] = { -- 团队增益组
		{ AuraID = 1022, UnitID = "player" }, -- 保护祝福
		{ AuraID = 6940, UnitID = "player" }, -- 牺牲祝福
		{ AuraID = 1044, UnitID = "player" }, -- 自由祝福
		{ AuraID = 29166, UnitID = "player" }, -- 激活
		{ AuraID = 10060, UnitID = "player" }, -- 能量灌注
		{ AuraID = 13159, UnitID = "player" }, -- 豹群守护
	},
	["Raid Debuff"] = { -- 团队减益组
		--{AuraID = 209858, UnitID = "player"},	-- 死疽溃烂
	},
	["Warning"] = { -- 目标重要光环组
		--{AuraID = 226510, UnitID = "target"},	-- 血池回血
		-- PVP
		{ AuraID = 498, UnitID = "target" }, -- 圣佑术
		{ AuraID = 642, UnitID = "target" }, -- 圣盾术
		{ AuraID = 871, UnitID = "target" }, -- 盾墙
		{ AuraID = 5277, UnitID = "target" }, -- 闪避
		{ AuraID = 1044, UnitID = "target" }, -- 自由祝福
		{ AuraID = 6940, UnitID = "target" }, -- 牺牲祝福
		{ AuraID = 1022, UnitID = "target" }, -- 保护祝福
		{ AuraID = 19574, UnitID = "target" }, -- 狂野怒火
		{ AuraID = 23920, UnitID = "target" }, -- 法术反射
		--{AuraID = 33206, UnitID = "target"},	-- 痛苦压制

		-- Crowd Controls
		-- Druid
		-- Bash r1
		{ AuraID = 5211, UnitID = "player", Caster = "all" },
		-- Bash r2
		{ AuraID = 6798, UnitID = "player", Caster = "all" },
		-- Bash r3
		{ AuraID = 8983, UnitID = "player", Caster = "all" },
		-- Celestial Focus (Starfire Stun)
		{ AuraID = 16922, UnitID = "player", Caster = "all" },
		-- Hibernate
		{ AuraID = 2637, UnitID = "player", Caster = "all" },
		-- Pounce r1
		{ AuraID = 9005, UnitID = "player", Caster = "all" },
		-- Pounce r2
		{ AuraID = 9823, UnitID = "player", Caster = "all" },
		-- Pounce r3
		{ AuraID = 9827, UnitID = "player", Caster = "all" },

		-- Hunter
		-- Charge (Boar)
		{ AuraID = 25999, UnitID = "player", Caster = "all" },
		-- Chimera Shot - Scorpid [Season of Discovery]
		{ AuraID = 409495, UnitID = "player", Caster = "all" },
		-- Freezing Trap Effect
		{ AuraID = 3355, UnitID = "player", Caster = "all" },
		-- Improved Concussive Shot
		{ AuraID = 19410, UnitID = "player", Caster = "all" },
		-- Intimidation
		{ AuraID = 24394, UnitID = "player", Caster = "all" },
		-- Scatter Shot
		{ AuraID = 19503, UnitID = "player", Caster = "all" },

		-- Mage
		-- Impact
		{ AuraID = 12355, UnitID = "player", Caster = "all" },
		-- Polymorph r1
		{ AuraID = 118, UnitID = "player", Caster = "all" },
		-- Polymorph r2
		{ AuraID = 12824, UnitID = "player", Caster = "all" },
		-- Polymorph r3
		{ AuraID = 12825, UnitID = "player", Caster = "all" },
		-- Polymorph r4
		{ AuraID = 12826, UnitID = "player", Caster = "all" },
		-- Polymorph: Pig
		{ AuraID = 28272, UnitID = "player", Caster = "all" },
		-- Polymorph: Turtle
		{ AuraID = 28271, UnitID = "player", Caster = "all" },

		-- Paladin
		-- Hammer of Justice r1
		{ AuraID = 853, UnitID = "player", Caster = "all" },
		-- Hammer of Justice r2
		{ AuraID = 5588, UnitID = "player", Caster = "all" },
		-- Hammer of Justice r3
		{ AuraID = 5589, UnitID = "player", Caster = "all" },
		-- Hammer of Justice r4
		{ AuraID = 10308, UnitID = "player", Caster = "all" },
		-- Repentance
		{ AuraID = 20066, UnitID = "player", Caster = "all" },
		-- Seal of Justice (Stun)
		{ AuraID = 20170, UnitID = "player", Caster = "all" },
		-- Turn Undead r1
		{ AuraID = 2878, UnitID = "player", Caster = "all" },
		-- Turn Undead r2
		{ AuraID = 5627, UnitID = "player", Caster = "all" },
		-- Turn Undead r3
		{ AuraID = 10326, UnitID = "player", Caster = "all" },

		-- Priest
		-- Blackout
		{ AuraID = 15269, UnitID = "player", Caster = "all" },
		-- Mind Control r1
		{ AuraID = 605, UnitID = "player", Caster = "all" },
		-- Mind Control r2
		{ AuraID = 10911, UnitID = "player", Caster = "all" },
		-- Mind Control r3
		{ AuraID = 10912, UnitID = "player", Caster = "all" },
		-- Psychic Scream r1
		{ AuraID = 8122, UnitID = "player", Caster = "all" },
		-- Psychic Scream r2
		{ AuraID = 8124, UnitID = "player", Caster = "all" },
		-- Psychic Scream r3
		{ AuraID = 10888, UnitID = "player", Caster = "all" },
		-- Psychic Scream r4
		{ AuraID = 10890, UnitID = "player", Caster = "all" },
		-- Shackle Undead
		{ AuraID = 9484, UnitID = "player", Caster = "all" },

		-- Rogue
		-- Between the Eyes [Season of Discovery]
		{ AuraID = 400009, UnitID = "player", Caster = "all" },
		-- Blind
		{ AuraID = 2094, UnitID = "player", Caster = "all" },
		-- Cheap Shot
		{ AuraID = 1833, UnitID = "player", Caster = "all" },
		-- Gouge r1
		{ AuraID = 1776, UnitID = "player", Caster = "all" },
		-- Gouge r2
		{ AuraID = 1777, UnitID = "player", Caster = "all" },
		-- Gouge r3
		{ AuraID = 8629, UnitID = "player", Caster = "all" },
		-- Gouge r4
		{ AuraID = 11285, UnitID = "player", Caster = "all" },
		-- Gouge r5
		{ AuraID = 11286, UnitID = "player", Caster = "all" },
		-- Kidney Shot r1
		{ AuraID = 408, UnitID = "player", Caster = "all" },
		-- Kidney Shot r2
		{ AuraID = 8643, UnitID = "player", Caster = "all" },
		-- Riposte
		{ AuraID = 14251, UnitID = "player", Caster = "all" },
		-- Sap
		{ AuraID = 6770, UnitID = "player", Caster = "all" },

		-- Shaman

		-- Warlock
		-- Banish r1
		{ AuraID = 710, UnitID = "player", Caster = "all" },
		-- Banish r2
		{ AuraID = 18647, UnitID = "player", Caster = "all" },
		-- Death Coil r1
		{ AuraID = 6789, UnitID = "player", Caster = "all" },
		-- Death Coil r2
		{ AuraID = 17925, UnitID = "player", Caster = "all" },
		-- Death Coil r3
		{ AuraID = 17926, UnitID = "player", Caster = "all" },
		-- Fear r1
		{ AuraID = 5782, UnitID = "player", Caster = "all" },
		-- Fear r2
		{ AuraID = 6213, UnitID = "player", Caster = "all" },
		-- Fear r3
		{ AuraID = 6215, UnitID = "player", Caster = "all" },
		-- Howl of Terror
		{ AuraID = 5484, UnitID = "player", Caster = "all" },
		-- Pyroclasm
		{ AuraID = 18093, UnitID = "player", Caster = "all" },
		-- Seduction (Succubus)
		{ AuraID = 6358, UnitID = "player", Caster = "all" },

		-- Warrior
		-- Charge Stun
		{ AuraID = 7922, UnitID = "player", Caster = "all" },
		-- Concussion Blow
		{ AuraID = 12809, UnitID = "player", Caster = "all" },
		-- Disarm
		{ AuraID = 676, UnitID = "player", Caster = "all" },
		-- Intercept Stun r1
		{ AuraID = 20253, UnitID = "player", Caster = "all" },
		-- Intercept Stun r2
		{ AuraID = 20614, UnitID = "player", Caster = "all" },
		-- Intercept Stun r3
		{ AuraID = 20615, UnitID = "player", Caster = "all" },
		-- Intimidating Shout (Cower)
		{ AuraID = 20511, UnitID = "player", Caster = "all" },
		-- Intimidating Shout (Fear)
		{ AuraID = 5246, UnitID = "player", Caster = "all" },
		-- Revenge Stun
		{ AuraID = 12798, UnitID = "player", Caster = "all" },

		-- Mace Specialization
		-- Mace Stun Effect
		{ AuraID = 5530, UnitID = "player", Caster = "all" },

		-- Racial
		-- War Stomp
		{ AuraID = 20549, UnitID = "player", Caster = "all" },

		-- Silences
		-- Counterspell - Silenced
		{ AuraID = 18469, UnitID = "player", Caster = "all" },
		-- Silence
		{ AuraID = 15487, UnitID = "player", Caster = "all" },
		-- Kick - Silenced
		{ AuraID = 18425, UnitID = "player", Caster = "all" },
		-- Spell Lock (Felhunter)
		{ AuraID = 24259, UnitID = "player", Caster = "all" },
		-- Shield Bash - Silenced
		{ AuraID = 18498, UnitID = "player", Caster = "all" },
		-- Unstable Affliction (Silence) [Season of Discovery]
		{ AuraID = 427719, UnitID = "player", Caster = "all" },

		-- Roots
		-- Entangling Roots r1
		{ AuraID = 339, UnitID = "player", Caster = "all" },
		-- Entangling Roots r2
		{ AuraID = 1062, UnitID = "player", Caster = "all" },
		-- Entangling Roots r3
		{ AuraID = 5195, UnitID = "player", Caster = "all" },
		-- Entangling Roots r4
		{ AuraID = 5196, UnitID = "player", Caster = "all" },
		-- Entangling Roots r5
		{ AuraID = 9852, UnitID = "player", Caster = "all" },
		-- Entangling Roots r6
		{ AuraID = 9853, UnitID = "player", Caster = "all" },
		-- Entangling Roots r1 (Nature's Grasp)
		{ AuraID = 19975, UnitID = "player", Caster = "all" },
		-- Entangling Roots r2 (Nature's Grasp)
		{ AuraID = 19974, UnitID = "player", Caster = "all" },
		-- Entangling Roots r3 (Nature's Grasp)
		{ AuraID = 19973, UnitID = "player", Caster = "all" },
		-- Entangling Roots r4 (Nature's Grasp)
		{ AuraID = 19972, UnitID = "player", Caster = "all" },
		-- Entangling Roots r5 (Nature's Grasp)
		{ AuraID = 19971, UnitID = "player", Caster = "all" },
		-- Entangling Roots r6 (Nature's Grasp)
		{ AuraID = 19970, UnitID = "player", Caster = "all" },
		-- Feral Charge Effect
		{ AuraID = 19675, UnitID = "player", Caster = "all" },
		-- Counterattack
		{ AuraID = 19306, UnitID = "player", Caster = "all" },
		-- Entrapment
		{ AuraID = 19185, UnitID = "player", Caster = "all" },
		-- Improved Wing Clip
		{ AuraID = 19229, UnitID = "player", Caster = "all" },
		-- Frost Nova r1
		{ AuraID = 122, UnitID = "player", Caster = "all" },
		-- Frost Nova r2
		{ AuraID = 865, UnitID = "player", Caster = "all" },
		-- Frost Nova r3
		{ AuraID = 6131, UnitID = "player", Caster = "all" },
		-- Frost Nova r4
		{ AuraID = 10230, UnitID = "player", Caster = "all" },
		-- Frostbite
		{ AuraID = 12494, UnitID = "player", Caster = "all" },
		-- Improved Hamstring
		{ AuraID = 23694, UnitID = "player", Caster = "all" },

		-- Slows
		-- Concussive Shot
		{ AuraID = 5116, UnitID = "player", Caster = "all" },
		-- Frost Trap Aura
		{ AuraID = 13810, UnitID = "player", Caster = "all" },
		-- Wing Clip r1
		{ AuraID = 2974, UnitID = "player", Caster = "all" },
		-- Wing Clip r2
		{ AuraID = 14267, UnitID = "player", Caster = "all" },
		-- Wing Clip r3
		{ AuraID = 14268, UnitID = "player", Caster = "all" },
		-- Blast Wave r1
		{ AuraID = 11113, UnitID = "player", Caster = "all" },
		-- Blast Wave r2
		{ AuraID = 13018, UnitID = "player", Caster = "all" },
		-- Blast Wave r3
		{ AuraID = 13019, UnitID = "player", Caster = "all" },
		-- Blast Wave r4
		{ AuraID = 13020, UnitID = "player", Caster = "all" },
		-- Blast Wave r5
		{ AuraID = 13021, UnitID = "player", Caster = "all" },
		--[[
			-- Chilled r1 (Blizzard)
			{AuraID = 12484, UnitID = "player", Caster = "all"},
			-- Chilled r2 (Blizzard)
			{AuraID = 12485, UnitID = "player", Caster = "all"},
			-- Chilled r3 (Blizzard)
			{AuraID = 12486, UnitID = "player", Caster = "all"},
			--]]
		-- Chilled (Frost Armor)
		-- {AuraID = 6136, UnitID = "player", Caster = "all"},
		-- Chilled (Ice Armor)
		-- {AuraID = 7321, UnitID = "player", Caster = "all"},
		-- Cone of Cold r1
		{ AuraID = 120, UnitID = "player", Caster = "all" },
		-- Cone of Cold r2
		{ AuraID = 8492, UnitID = "player", Caster = "all" },
		-- Cone of Cold r3
		{ AuraID = 10159, UnitID = "player", Caster = "all" },
		-- Cone of Cold r4
		{ AuraID = 10160, UnitID = "player", Caster = "all" },
		-- Cone of Cold r5
		{ AuraID = 10161, UnitID = "player", Caster = "all" },
		-- Frostbolt r1
		{ AuraID = 116, UnitID = "player", Caster = "all" },
		-- Frostbolt r2
		{ AuraID = 205, UnitID = "player", Caster = "all" },
		-- Frostbolt r3
		{ AuraID = 837, UnitID = "player", Caster = "all" },
		-- Frostbolt r4
		{ AuraID = 7322, UnitID = "player", Caster = "all" },
		-- Frostbolt r5
		{ AuraID = 8406, UnitID = "player", Caster = "all" },
		-- Frostbolt r6
		{ AuraID = 8407, UnitID = "player", Caster = "all" },
		-- Frostbolt r7
		{ AuraID = 8408, UnitID = "player", Caster = "all" },
		-- Frostbolt r8
		{ AuraID = 10179, UnitID = "player", Caster = "all" },
		-- Frostbolt r9
		{ AuraID = 10180, UnitID = "player", Caster = "all" },
		-- Frostbolt r10
		{ AuraID = 10181, UnitID = "player", Caster = "all" },
		-- Frostbolt r11
		{ AuraID = 25304, UnitID = "player", Caster = "all" },
		-- Frostfire Bolt [Season of Discovery]
		{ AuraID = 401502, UnitID = "player", Caster = "all" },
		-- Spellfrost Bolt [Season of Discovery]
		{ AuraID = 412532, UnitID = "player", Caster = "all" },
		-- Avenger's Shield [Season of Discovery]
		{ AuraID = 407669, UnitID = "player", Caster = "all" },
		-- Mind Flay r1
		{ AuraID = 15407, UnitID = "player", Caster = "all" },
		-- Mind Flay r2
		{ AuraID = 17311, UnitID = "player", Caster = "all" },
		-- Mind Flay r3
		{ AuraID = 17312, UnitID = "player", Caster = "all" },
		-- Mind Flay r4
		{ AuraID = 17313, UnitID = "player", Caster = "all" },
		-- Mind Flay r5
		{ AuraID = 17314, UnitID = "player", Caster = "all" },
		-- Mind Flay r6
		{ AuraID = 18807, UnitID = "player", Caster = "all" },
		-- Crippling Poison r1
		{ AuraID = 3409, UnitID = "player", Caster = "all" },
		-- Crippling Poison r2
		{ AuraID = 11201, UnitID = "player", Caster = "all" },
		-- Earthbind
		{ AuraID = 3600, UnitID = "player", Caster = "all" },
		-- Frost Shock r1
		{ AuraID = 8056, UnitID = "player", Caster = "all" },
		-- Frost Shock r2
		{ AuraID = 8058, UnitID = "player", Caster = "all" },
		-- Frost Shock r3
		{ AuraID = 10472, UnitID = "player", Caster = "all" },
		-- Frost Shock r4
		{ AuraID = 10473, UnitID = "player", Caster = "all" },
		-- Frostbrand Attack
		{ AuraID = 8034, UnitID = "player", Caster = "all" },
		-- Aftermath
		{ AuraID = 18118, UnitID = "player", Caster = "all" },
		-- Cripple (Doomguard)
		{ AuraID = 20812, UnitID = "player", Caster = "all" },
		-- Curse of Exhaustion
		{ AuraID = 18223, UnitID = "player", Caster = "all" },
		-- Hamstring r1
		{ AuraID = 1715, UnitID = "player", Caster = "all" },
		-- Hamstring r2
		{ AuraID = 7372, UnitID = "player", Caster = "all" },
		-- Hamstring r3
		{ AuraID = 7373, UnitID = "player", Caster = "all" },
		-- Piercing Howl
		{ AuraID = 12323, UnitID = "player", Caster = "all" },

		-- Raids: Classic
	},
	["InternalCD"] = { -- 自定义内置冷却组
		--{IntID = 240447, Duration = 20},	-- 践踏
	},
}

Module:AddNewAuraWatch("ALL", list)
