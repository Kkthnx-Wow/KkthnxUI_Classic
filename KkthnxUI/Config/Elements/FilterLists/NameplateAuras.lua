local C = KkthnxUI[2]

C.NameplateWhiteList = {
	-- Buffs
	-- Druid
	[2893] = true, -- Abolish Poison
	[22812] = true, -- Barkskin
	[417141] = true, -- Berserk [Season of Discovery]
	[1850] = true, -- Dash
	-- [408261] = true,	-- Dreamstate [Season of Discovery]
	[417147] = true, -- Efflorescence [Season of Discovery]
	[5229] = true, -- Enrage
	[22842] = true, -- Frenzied Regeneration
	[414800] = true, -- Fury of Stormrage [Season of Discovery]
	[29166] = true, -- Innervate
	-- [24932] = true,	-- Leader of the Pack
	[408124] = true, -- Lifebloom [Season of Discovery]
	[414680] = true, -- Living Seed [Season of Discovery]
	-- [16886] = true,	-- Nature's Grace
	[16689] = true, -- Nature's Grasp
	[17116] = true, -- Nature's Swiftness
	-- [16870] = true,	-- Omen of Clarity (Clearcasting)
	-- [5215] = true,	-- Prowl
	[8936] = true, -- Regrowth
	[774] = true, -- Rejuvenation
	[407988] = true, -- Savage Roar [Season of Discovery]
	[408024] = true, -- Survival Instincts [Season of Discovery]
	[5217] = true, -- Tiger's Fury
	-- [5225] = true,	-- Track Humanoids
	[740] = true, -- Tranquility

	-- Hunter
	-- [13161] = true,	-- Aspect of the Beast
	[5118] = true, -- Aspect of the Cheetah
	-- [13165] = true,	-- Aspect of the Hawk
	-- [13163] = true,	-- Aspect of the Monkey
	[13159] = true, -- Aspect of the Pack
	-- [20043] = true,	-- Aspect of the Wild
	[19574] = true, -- Bestial Wrath
	[25077] = true, -- Cobra Reflexes (Pet)
	[425714] = true, -- Cobra Strikes (Pet) [Season of Discovery]
	[23099] = true, -- Dash (Pet)
	[19263] = true, -- Deterrence
	[23145] = true, -- Dive (Pet)
	[6197] = true, -- Eagle Eye
	[1002] = true, -- Eyes of the Beast
	-- [1539] = true,	-- Feed Pet Effect
	[5384] = true, -- Feign Death
	[415320] = true, -- Flanking Strike [Season of Discovery]
	[428726] = true, -- Focus Fire [Season of Discovery]
	[19615] = true, -- Frenzy Effect
	[24604] = true, -- Furious Howl (Wolf)
	[409418] = true, -- Kill Command (Pet) [Season of Discovery]
	[415414] = true, -- Lock and Load [Season of Discovery]
	[136] = true, -- Mend Pet
	-- [24450] = true,	-- Prowl (Cat)
	[6150] = true, -- Quick Shots
	[3045] = true, -- Rapid Fire
	[415407] = true, -- Rapid Killing [Season of Discovery]
	[415362] = true, -- Raptor Fury [Season of Discovery]
	[26064] = true, -- Shell Shield (Turtle)
	[415401] = true, -- Sniper Training [Season of Discovery]
	-- [19579] = true,	-- Spirit Bond
	-- [1515] = true,	-- Tame Beast
	-- [1494] = true,	-- Track Beasts
	-- [19878] = true,	-- Track Demons
	-- [19879] = true,	-- Track Dragonkin
	-- [19880] = true,	-- Track Elementals
	-- [19882] = true,	-- Track Giants
	-- [19885] = true,	-- Track Hidden
	-- [19883] = true,	-- Track Humanoids
	-- [19884] = true,	-- Track Undead
	-- [19506] = true,	-- Trueshot Aura

	-- Mage
	-- [400573] = true,	-- Arcane Blast [Season of Discovery]
	-- [12536] = true,	-- Arcane Concentration (Clearcasting)
	[12042] = true, -- Arcane Power
	[425124] = true, -- Arcane Surge [Season of Discovery]
	-- [428878] = true,	-- Balefire Bolt [Season of Discovery]
	[436516] = true, -- Chronostatic Preservation[Season of Discovery]
	[28682] = true, -- Combustion
	[412326] = true, -- Enlightenment [Season of Discovery]
	[400669] = true, -- Fingers of Frost [Season of Discovery]
	[543] = true, -- Fire Ward
	[6143] = true, -- Frost Ward
	[400624] = true, -- Hot Streak [Season of Discovery]
	[11426] = true, -- Ice Barrier
	[11958] = true, -- Ice Block
	[429125] = true, -- Icy Veins [Season of Discovery]
	[1463] = true, -- Mana Shield
	[412510] = true, -- Mass Regeneration [Season of Discovery]
	[400589] = true, -- Missile Barrage [Season of Discovery]
	[12043] = true, -- Presence of Mind
	[401460] = true, -- Rapid Regeneration [Season of Discovery]
	[401417] = true, -- Regeneration [Season of Discovery]
	[130] = true, -- Slow Fall
	[428885] = true, -- Temporal Anomaly [Season of Discovery]
	[400735] = true, -- Temporal Beacon [Season of Discovery]

	-- Paladin
	-- [425585] = true,	-- Aegis [Season of Discovery]
	[1044] = true, -- Blessing of Freedom
	[1022] = true, -- Blessing of Protection
	[6940] = true, -- Blessing of Sacrifice
	-- [19746] = true,	-- Concentration Aura
	-- [465] = true,	-- Devotion Aura
	[20216] = true, -- Divine Favor
	-- [19752] = true,	-- Divine Intervention
	[498] = true, -- Divine Protection
	[642] = true, -- Divine Shield
	-- [19891] = true,	-- Fire Resistance Aura
	-- [19888] = true,	-- Frost Resistance Aura
	[20925] = true, -- Holy Shield
	[425600] = true, -- Horn of Lordaeron [Season of Discovery]
	[6346] = true, -- Inspiration Exemplar [Season of Discovery]
	[20233] = true, -- Lay on Hands (Armor Bonus)
	-- [428909] = true,	-- Light's Grace [Season of Discovery]
	-- [20178] = true,	-- Reckoning
	-- [20128] = true,	-- Redoubt
	-- [7294] = true,	-- Retribution Aura
	-- [20218] = true,	-- Sanctity Aura
	[20375] = true, -- Seal of Command
	[20164] = true, -- Seal of Justice
	[20165] = true, -- Seal of Light
	[407798] = true, -- Seal of Martyrdom [Season of Discovery]
	[21084] = true, -- Seal of Righteousness
	[20166] = true, -- Seal of Wisdom
	[21082] = true, -- Seal of the Crusader
	-- [5502] = true,	-- Sense Undead
	-- [19876] = true,	-- Shadow Resistance Aura
	[426162] = true, -- Sheath of Light [Season of Discovery]
	[53489] = true, -- The Art of War [Season of Discovery]
	[20050] = true, -- Vengeance

	-- Priest
	[552] = true, -- Abolish Disease
	[27813] = true, -- Blessed Recovery
	[425294] = true, -- Dispersion [Season of Discovery]
	[431624] = true, -- Divine Aegis [Season of Discovery]
	[2651] = true, -- Elune's Grace
	-- [586] = true,		-- Fade
	[6346] = true, -- Fear Ward
	[13896] = true, -- Feedback
	[588] = true, -- Inner Fire
	[14751] = true, -- Inner Focus
	[14893] = true, -- Inspiration
	[1706] = true, -- Levitate
	[7001] = true, -- Lightwell Renew
	-- [14743] = true,	-- Martyrdom (Focused Casting)
	[431655] = true, -- Mind Spike [Season of Discovery]
	[402004] = true, -- Pain Suppression [Season of Discovery]
	[10060] = true, -- Power Infusion
	[425205] = true, -- Power Word: Barrier [Season of Discovery]
	[17] = true, -- Power Word: Shield
	[401859] = true, -- Prayer of Mending [Season of Discovery]
	[425284] = true, -- Spirit of the Redeemer [Season of Discovery]
	[139] = true, -- Renew
	-- [413247] = true,	-- Serendipity [Season of Discovery]
	-- [15473] = true,	-- Shadowform
	[18137] = true, -- Shadowguard
	[27827] = true, -- Spirit of Redemption
	[15271] = true, -- Spirit Tap
	[431666] = true, -- Surge of Ligh [Season of Discovery]
	[2652] = true, -- Touch of Weakness
	-- [15290] = true,	-- Vampiric Embrace

	-- Rogue
	[13750] = true, -- Adrenaline Rush
	[400012] = true, -- Blade Dance [Season of Discovery]
	[13877] = true, -- Blade Flurry
	[14177] = true, -- Cold Blood
	[5277] = true, -- Evasion
	[14278] = true, -- Ghostly Strike
	[424919] = true, -- Main Gauche [Season of Discovery]
	[425098] = true, -- Master of Subtlety [Season of Discovery]
	[400015] = true, -- Rolling with the Punches [Season of Discovery]
	[406722] = true, -- Shadowstep [Season of Discovery]
	[5171] = true, -- Slice and Dice
	[2983] = true, -- Sprint
	-- [1784] = true,	-- Stealth
	[14143] = true, -- Remorseless Attacks

	-- Shaman
	[425876] = true, -- Decoy Totem (Redirect) [Season of Discovery]
	-- [436391] = true,	-- Decoy Totem (Immunity) [Season of Discovery]
	[974] = true, -- Earth Shield [Season of Discovery]
	[30165] = true, -- Elemental Devastation
	-- [16246] = true,	-- Elemental Focus (Clearcasting)
	[16166] = true, -- Elemental Mastery
	-- [29063] = true,	-- Eye of the Storm (Focused Casting)
	[6196] = true, -- Far Sight
	-- [8185] = true,	-- Fire Resistance Totem
	[16257] = true, -- Flurry
	-- [8182] = true,	-- Frost Resistance Totem
	-- [2645] = true,	-- Ghost Wolf
	-- [8836] = true,	-- Grace of Air
	[8178] = true, -- Grounding Totem Effect
	-- [5672] = true,	-- Healing Stream
	[29203] = true, -- Healing Way
	[324] = true, -- Lightning Shield
	[409946] = true, -- Maelstrom Weapon [Season of Discovery]
	-- [5677] = true,	-- Mana Spring Totem
	[16191] = true, -- Mana Tide Totem
	-- [415144] = true,	-- Mental Dexterity [Season of Discovery]
	[16188] = true, -- Nature's Swiftness
	-- [10596] = true,	-- Nature Resistance Totem
	[415105] = true, -- Power Surge [Season of Discovery]
	[408521] = true, -- Riptide [Season of Discovery]
	-- [6495] = true,	-- Sentry Totem
	[425336] = true, -- Shamanistic Rage [Season of Discovery]
	-- [408525] = true,	-- Shield Mastery [Season of Discovery]
	-- [408696] = true,	-- Spirit of the Alpha [Season of Discovery]
	-- [8072] = true,	-- Stoneskin Totem
	-- [8076] = true,	-- Strength of Earth
	[432041] = true, -- Tidal Waves [Season of Discovery]
	-- [436365] = true,	-- Two-Handed Mastery [Season of Discovery]
	[30803] = true, -- Unleashed Rage
	[408510] = true, -- Water Shield [Season of Discovery]
	-- [15108] = true,	-- Windwall Totem
	-- [2895] = true,	-- Wrath of Air Totem

	-- Warlock
	[18288] = true, -- Amplify Curse
	[427713] = true, -- Backdraft [Season of Discovery]
	-- [6307] = true,	-- Blood Pact (Imp)
	[17767] = true, -- Consume Shadows (Voidwalker)
	[412800] = true, -- Dance of the Wicked [Season of Discovery]
	[425463] = true, -- Demonic Grace [Season of Discovery]
	-- [412735] = true,	-- Demonic Knowledge [Season of Discovery]
	-- [425467] = true,	-- Demonic Pact [Season of Discovery]
	[126] = true, -- Eye of Kilrogg
	[2947] = true, -- Fire Shield (Imp)
	[755] = true, -- Health Funnel
	[1949] = true, -- Hellfire
	[427726] = true, -- Immolation Aura [Seasonf of Discovery]
	-- [7870] = true,	-- Lesser Invisibility (Succubus)
	-- [23759] = true,	-- Master Demonologist (Imp - Reduced Threat)
	-- [23760] = true,	-- Master Demonologist (Voidwalker - Reduced Physical Taken)
	-- [23761] = true,	-- Master Demonologist (Succubus - Increased Damage)
	-- [23762] = true,	-- Master Demonologist (Felhunter - Increased Resistance)
	-- [19480] = true,	-- Paranoia (Felhunter)
	-- [4511] = true,	-- Phase Shift (Imp)
	[7812] = true, -- Sacrifice (Voidwalker)
	-- [5500] = true,	-- Sense Demons
	[426311] = true, -- Shadow and Flame [Season of Discovery]
	[17941] = true, -- Shadow Trance
	[6229] = true, -- Shadow Ward
	[25228] = true, -- Soul Link
	[20707] = true, -- Soulstone Resurrection
	[19478] = true, -- Tainted Blood (Felhunter)
	[426195] = true, -- Vengeance [Season of Discovery]

	-- Warrior
	[6673] = true, -- Battle Shout
	[18499] = true, -- Berserker Rage
	[29131] = true, -- Bloodrage
	[23885] = true, -- Bloodthirst
	[16488] = true, -- Blood Craze
	[413399] = true, -- Blood Surge [Season of Discovery]
	[403215] = true, -- Commanding Shout [Season of Discovery]
	[12328] = true, -- Death Wish
	[12880] = true, -- Enrage
	[425415] = true, -- Enrage (Consumed By Rage) [Season of Discovery]
	[427066] = true, -- Enrage (Wrecking Crew) [Season of Discovery]
	[402913] = true, -- Enraged Regeneration [Season of Discovery]
	[402906] = true, -- Flagellation [Season of Discovery]
	[12966] = true, -- Flurry
	[403338] = true, -- Intervene [Season of Discovery]
	[12975] = true, -- Last Stand
	[426942] = true, -- Rampage [Season of Discovery]
	[1719] = true, -- Recklessness
	[20230] = true, -- Retaliation
	[871] = true, -- Shield Wall
	[12292] = true, -- Sweeping Strikes

	-- Racial
	[20554] = true, -- Berserking (Mana)
	-- [26296] = true,	-- Berserking (Rage)
	-- [26297] = true,	-- Berserking (Energy)
	[23234] = true, -- Blood Fury
	-- [2481] = true,	-- Find Treasure
	[20600] = true, -- Perception
	-- [20580] = true,	-- Shadowmeld
	[20594] = true, -- Stoneform
	[7744] = true, -- Will of the Forsaken

	-- Debuffs
	[19577] = true,

	-- Druid
	[5211] = true, -- Bash
	[16922] = true, -- Celestial Focus (Starfire Stun)
	[5209] = true, -- Challenging Roar
	[99] = true, -- Demoralizing Roar
	[339] = true, -- Entangling Roots
	-- [19975] = true,	-- Entangling Roots (Nature's Grasp)
	[770] = true, -- Faerie Fire
	[16857] = true, -- Faerie Fire (Feral)
	[19675] = true, -- Feral Charge Effect
	[2637] = true, -- Hibernate
	-- [16914] = true,	-- Hurricane
	[5570] = true, -- Insect Swarm
	[414644] = true, -- Lacerate [Season of Discovery]
	[407995] = true, -- Mangle (Bear) [Season of Discovery]
	[407993] = true, -- Mangle (Cat) [Season of Discovery]
	[8921] = true, -- Moonfire
	[9005] = true, -- Pounce
	[9007] = true, -- Pounce Bleed
	[1822] = true, -- Rake
	[1079] = true, -- Rip
	[2908] = true, -- Soothe Animal
	[414684] = true, -- Sunfire [Season of Discovery]
	-- [414687] = true,	-- Sunfire (Bear) [Season of Discovery]
	-- [414689] = true,	-- Sunfire (Cat) [Season of Discovery]

	-- Hunter
	-- [1462] = true,	-- Beast Lore
	[3674] = true, -- Black Arrow
	[25999] = true, -- Charge (Boar)
	[409495] = true, -- Chimera Shot - Scorpid [Season of Discovery]
	[5116] = true, -- Concussive Shot
	[19306] = true, -- Counterattack
	[19185] = true, -- Entrapment
	[409552] = true, -- Explosive Shot [Season of Discovery]
	[13812] = true, -- Explosive Trap Effect
	[409507] = true, -- Expose Weakness [Season of Discovery]
	[1543] = true, -- Flare
	[3355] = true, -- Freezing Trap Effect
	[13810] = true, -- Frost Trap Aura
	[1130] = true, -- Hunter's Mark
	[13797] = true, -- Immolation Trap Effect
	[19410] = true, -- Improved Concussive Shot
	[19229] = true, -- Improved Wing Clip
	[24394] = true, -- Intimidation
	[444678] = true, -- Lava Breath [Season of Discovery]
	[1513] = true, -- Scare Beast
	[19503] = true, -- Scatter Shot
	[24640] = true, -- Scorpid Poison (Scorpid)
	[3043] = true, -- Scorpid Sting
	[24423] = true, -- Screech (Bat / Bird of Prey / Carrion Bird)
	[1978] = true, -- Serpent Sting
	[3034] = true, -- Viper Sting
	[2974] = true, -- Wing Clip
	[19386] = true, -- Wyvern Sting

	-- Mage
	[11113] = true, -- Blast Wave
	-- [10] = true,	-- Blizzard
	-- [12484] = true,	-- Chilled (Blizzard)
	[6136] = true, -- Chilled (Frost Armor)
	-- [7321] = true,	-- Chilled (Ice Armor)
	[120] = true, -- Cone of Cold
	[18469] = true, -- Counterspell - Silenced
	[428739] = true, -- Deep Freeze [Season of Discovery]
	[133] = true, -- Fireball
	[22959] = true, -- Fire Vulnerability (Improved Scorch)
	[2120] = true, -- Flamestrike
	[122] = true, -- Frost Nova
	[12494] = true, -- Frostbite
	[116] = true, -- Frostbolt
	[401502] = true, -- Frostfire Bolt [Season of Discovery]
	[12654] = true, -- Ignite
	[12355] = true, -- Impact
	[400613] = true, -- Living Bomb [Season of Discovery]
	-- [401558] = true,	-- Living Flame [Season of Discovery]
	[118] = true, -- Polymorph
	[11366] = true, -- Pyroblast
	[412532] = true, -- Spellfrost Bolt [Season of Discovery]
	[12579] = true, -- Winter's Chill

	-- Paladin
	[407669] = true, -- Avenger's Shield [Season of Discovery]
	[26573] = true, -- Consecration
	[853] = true, -- Hammer of Justice
	[407631] = true, -- Hand of Reckoning [Season of Discovery]
	[20184] = true, -- Judgement of Justice
	[20185] = true, -- Judgement of Light
	[20186] = true, -- Judgement of Wisdom
	[21183] = true, -- Judgement of the Crusader
	[20066] = true, -- Repentance
	[20170] = true, -- Seal of Justice (Stun)
	[2878] = true, -- Turn Undead
	[67] = true, -- Vindication

	-- Priest
	[15269] = true, -- Blackout
	[402808] = true, -- Cripple (Homunculi) [Season of Discovery]
	[402792] = true, -- Curse of the Elements (Eye of the Void) [Season of Discovery]
	[402791] = true, -- Curse of Shadow (Eye of the Void) [Season of Discovery]
	[402794] = true, -- Curse of Tongues (Eye of the Void) [Season of Discovery]
	[402818] = true, -- Degrade (Homunculi) [Season of Discovery]
	[402811] = true, -- Demoralize (Homunculi) [Season of Discovery]
	[2944] = true, -- Devouring Plague
	[9035] = true, -- Hex of Weakness
	[14914] = true, -- Holy Fire
	[605] = true, -- Mind Control
	[15407] = true, -- Mind Flay
	[413259] = true, -- Mind Sear [Season of Discovery]
	[453] = true, -- Mind Soothe
	[2096] = true, -- Mind Vision
	[8122] = true, -- Psychic Scream
	[9484] = true, -- Shackle Undead
	[15258] = true, -- Shadow Vulnerability (Shadow Weaving)
	[589] = true, -- Shadow Word: Pain
	[15487] = true, -- Silence
	[10797] = true, -- Starshards
	[2943] = true, -- Touch of Weakness
	[15286] = true, -- Vampiric Embrace
	[425204] = true, -- Void Plague [Season of Discovery]
	[431681] = true, -- Void Zone [Season of Discovery]

	-- Rogue
	[439473] = true, -- Atrophic Poison [Season of Discovery]
	[400009] = true, -- Between the Eyes [Season of Discovery]
	[2094] = true, -- Blind
	[1833] = true, -- Cheap Shot
	[3409] = true, -- Crippling Poison
	[2818] = true, -- Deadly Poison
	[8647] = true, -- Expose Armor
	[703] = true, -- Garrote
	[1776] = true, -- Gouge
	[16511] = true, -- Hemorrhage
	[18425] = true, -- Kick - Silenced
	[408] = true, -- Kidney Shot
	[5760] = true, -- Mind-numbing Poison
	[439472] = true, -- Numbing Poison [Season of Discovery]
	[398196] = true, -- Quick Draw [Season of Discovery]
	[14251] = true, -- Riposte
	[1943] = true, -- Rupture
	[424785] = true, -- Saber Lash [Season of Discovery]
	[6770] = true, -- Sap
	[439471] = true, -- Sebacious Poison [Season of Discovery]
	[415725] = true, -- Waylay [Season of Discovery]
	[13218] = true, -- Wound Poison

	-- Shaman
	[3600] = true, -- Earthbind
	[408681] = true, -- Earth Shock (Way of Earth) [Season of Discovery]
	[8050] = true, -- Flame Shock
	[8056] = true, -- Frost Shock
	[8034] = true, -- Frostbrand Attack
	[17364] = true, -- Stormstrike

	-- Warlock
	[18118] = true, -- Aftermath
	[710] = true, -- Banish
	[172] = true, -- Corruption
	[20812] = true, -- Cripple (Doomguard)
	[980] = true, -- Curse of Agony
	[603] = true, -- Curse of Doom
	[18223] = true, -- Curse of Exhaustion
	[1010] = true, -- Curse of Idiocy
	[704] = true, -- Curse of Recklessness
	[17862] = true, -- Curse of Shadow
	[1714] = true, -- Curse of Tongues
	[702] = true, -- Curse of Weakness
	[1490] = true, -- Curse of the Elements
	[6789] = true, -- Death Coil
	[412789] = true, -- Demonic Howl (Metamorphosis) [Season of Discovery]
	[689] = true, -- Drain Life
	[5138] = true, -- Drain Mana
	[1120] = true, -- Drain Soul
	[1098] = true, -- Enslave Demon
	[5782] = true, -- Fear
	[403501] = true, -- Haunt [Season of Discovery]
	[5484] = true, -- Howl of Terror
	[348] = true, -- Immolate
	[412758] = true, -- Incinerate [Season of Discovery]
	-- [403650] = true,	-- Lake of Fire [Season of Discovery]
	[403828] = true, -- Menace (Metamorphosis) [Season of Discovery]
	[18093] = true, -- Pyroclasm
	-- [5740] = true,	-- Rain of Fire
	[6358] = true, -- Seduction (Succubus)
	[426325] = true, -- Shadowflame [Season of Discovery]
	[17794] = true, -- Shadow Vulnerability (Improved Shadow Bolt)
	[18265] = true, -- Siphon Life
	[24259] = true, -- Spell Lock (Felhunter)
	[21949] = true, -- Rend (Doomguard)
	[19479] = true, -- Tainted Blood Effect (Felhunter)
	[427717] = true, -- Unstable Affliction [Season of Discovery]
	-- [427719] = true,	-- Unstable Affliction (Silence) [Season of Discovery]

	-- Warrior
	[1161] = true, -- Challenging Shout
	[7922] = true, -- Charge Stun
	[12809] = true, -- Concussion Blow
	[1160] = true, -- Demoralizing Shout
	[676] = true, -- Disarm
	[1715] = true, -- Hamstring
	[23694] = true, -- Improved Hamstring
	[20253] = true, -- Intercept Stun
	[20511] = true, -- Intimidating Shout (Cower)
	[5246] = true, -- Intimidating Shout (Fear)
	[694] = true, -- Mocking Blow
	[12294] = true, -- Mortal Strike
	[12323] = true, -- Piercing Howl
	[772] = true, -- Rend
	[12798] = true, -- Revenge Stun
	[18498] = true, -- Shield Bash - Silenced
	[7386] = true, -- Sunder Armor
	[6343] = true, -- Thunder Clap

	-- Mace Specialization
	[5530] = true, -- Mace Stun Effect (Rogue / Warrior)

	-- Racial
	[20549] = true, -- War Stomp
}

C.NameplateBlackList = {
	[15407] = true, -- 精神鞭笞
}

C.NameplateCustomUnits = {
	--[120651] = true, -- 爆炸物
	[5925] = true, -- Grounding Totem
	-- Raid
	-- Blackfathom Deeps [Season of Discovery]
	[207457] = true, -- Corrupted Lightning Shield Totem
	-- Zul'Gurub
	[15112] = true, -- Brain Wash Totem
	-- Naxxramas
	[16385] = true, -- Lightning Totem
}

C.NameplateShowPowerList = {
	--[155432] = true, -- 魔力使者
}

C.NameplateTargetNPCs = {}

C.NameplateTrashUnits = {}

C.MajorSpells = {
	--[27072] = true,	-- 寒冰箭
}
