local K, C = KkthnxUI[1], KkthnxUI[2]

local function Priority(priorityOverride)
	return {
		enable = true,
		priority = priorityOverride or 0,
		stackThreshold = 0,
	}
end

C.DebuffsTracking_PvE = {
	type = "WhitePriority",
	spells = {
		----------------------------------------------------------
		-------------------------- Misc --------------------------
		----------------------------------------------------------
		[15007] = Priority(6), -- Resurrection Sickness
		----------------------------------------------------------
		------------------------ Dungeons ------------------------
		----------------------------------------------------------
		-- Multiple Dungeons
		[744] = Priority(2), -- Poison
		[18267] = Priority(2), -- Curse of Weakness
		[20800] = Priority(2), -- Immolate
		[246] = Priority(2), -- Slow
		[6533] = Priority(2), -- Net
		[8399] = Priority(2), -- Sleep
		-- Blackrock Depths
		[13704] = Priority(2), -- Psychic Scream
		-- Deadmines
		[6304] = Priority(2), -- Rhahk'Zor Slam
		[12097] = Priority(2), -- Pierce Armor
		[7399] = Priority(2), -- Terrify
		[6713] = Priority(2), -- Disarm
		[5213] = Priority(2), -- Molten Metal
		[5208] = Priority(2), -- Poisoned Harpoon
		-- Maraudon
		[7964] = Priority(2), -- Smoke Bomb
		[21869] = Priority(2), -- Repulsive Gaze
		-- Razorfen Downs
		[12255] = Priority(2), -- Curse of Tuten'kash
		[12252] = Priority(2), -- Web Spray
		[7645] = Priority(2), -- Dominate Mind
		[12946] = Priority(2), -- Putrid Stench
		-- Razorfen Kraul
		[14515] = Priority(2), -- Dominate Mind
		-- Scarlet Monastry
		[9034] = Priority(2), -- Immolate
		[8814] = Priority(2), -- Flame Spike
		[8988] = Priority(2), -- Silence
		[9256] = Priority(2), -- Deep Sleep
		[8282] = Priority(2), -- Curse of Blood
		-- Shadowfang Keep
		[7068] = Priority(2), -- Veil of Shadow
		[7125] = Priority(2), -- Toxic Saliva
		[7621] = Priority(2), -- Arugal's Curse
		-- Stratholme
		[16798] = Priority(2), -- Enchanting Lullaby
		[12734] = Priority(2), -- Ground Smash
		[17293] = Priority(2), -- Burning Winds
		[17405] = Priority(2), -- Domination
		[16867] = Priority(2), -- Banshee Curse
		[6016] = Priority(2), -- Pierce Armor
		[16869] = Priority(2), -- Ice Tomb
		[17307] = Priority(2), -- Knockout
		-- Sunken Temple
		[12889] = Priority(2), -- Curse of Tongues
		[12888] = Priority(2), -- Cause Insanity
		[12479] = Priority(2), -- Hex of Jammal'an
		[12493] = Priority(2), -- Curse of Weakness
		[12890] = Priority(2), -- Deep Slumber
		[24375] = Priority(2), -- War Stomp
		-- Uldaman
		[3356] = Priority(2), -- Flame Lash
		[6524] = Priority(2), -- Ground Tremor
		-- Wailing Caverns
		[8040] = Priority(2), -- Druid's Slumber
		[8142] = Priority(2), -- Grasping Vines
		[7967] = Priority(2), -- Naralex's Nightmare
		[8150] = Priority(2), -- Thundercrack
		-- Zul'Farrak
		[11836] = Priority(2), -- Freeze Solid
		-- World Bosses
		[21056] = Priority(2), -- Mark of Kazzak
		[24814] = Priority(2), -- Seeping Fog
		----------------------------------------------------------
		-------------------------- PvP ---------------------------
		----------------------------------------------------------
		[43680] = Priority(6), -- Idle (Reported for AFK)
		----------------------------------------------------------
		----------------------------------------------------------
		--------------------- Onyxia's Lair ----------------------
		----------------------------------------------------------
		[18431] = Priority(2), -- Bellowing Roar
		----------------------------------------------------------
		---------------------- Molten Core -----------------------
		----------------------------------------------------------
		[19703] = Priority(5), -- Lucifron's Curse
		[19408] = Priority(2), -- Panic
		[19716] = Priority(3), -- Gehennas' Curse
		[20475] = Priority(6), -- Living Bomb
		[19695] = Priority(3), -- Inferno
		[19713] = Priority(5), -- Shazzrah's Curse
		[20277] = Priority(2), -- Fist of Ragnaros
		[19659] = Priority(2), -- Ignite Mana
		[19714] = Priority(2), -- Deaden Magic
		----------------------------------------------------------
		--------------------- Blackwing Lair ---------------------
		----------------------------------------------------------
		[23023] = Priority(2), -- Conflagration
		[18173] = Priority(2), -- Burning Adrenaline
		[24573] = Priority(2), -- Mortal Strike
		[23340] = Priority(2), -- Shadow of Ebonroc
		[23170] = Priority(2), -- Brood Affliction: Bronze
		[22687] = Priority(2), -- Veil of Shadow
		----------------------------------------------------------
		------------------------ Zul'Gurub -----------------------
		----------------------------------------------------------
		[23860] = Priority(2), -- Holy Fire
		[22884] = Priority(2), -- Psychic Scream
		[23918] = Priority(2), -- Sonic Burst
		[24111] = Priority(2), -- Corrosive Poison
		[21060] = Priority(2), -- Blind
		[24328] = Priority(2), -- Corrupted Blood
		[16856] = Priority(2), -- Mortal Strike
		[24664] = Priority(2), -- Sleep
		[17172] = Priority(2), -- Hex
		[24306] = Priority(2), -- Delusions of Jin'do
		[24099] = Priority(2), -- Poison Bolt Volley
		----------------------------------------------------------
		--------------------- Ahn'Qiraj Ruins --------------------
		----------------------------------------------------------
		[25646] = Priority(2), -- Mortal Wound
		[25471] = Priority(2), -- Attack Order
		[96] = Priority(2), -- Dismember
		[25725] = Priority(2), -- Paralyze
		[25189] = Priority(2), -- Enveloping Winds
		----------------------------------------------------------
		--------------------- Ahn'Qiraj Temple -------------------
		----------------------------------------------------------
		[785] = Priority(2), -- True Fulfillment
		[26580] = Priority(2), -- Fear
		[26050] = Priority(2), -- Acid Spit
		[26180] = Priority(2), -- Wyvern Sting
		[26053] = Priority(2), -- Noxious Poison
		[26613] = Priority(2), -- Unbalancing Strike
		[26029] = Priority(2), -- Dark Glare
		----------------------------------------------------------
		------------------------ Naxxramas -----------------------
		----------------------------------------------------------
		[28732] = Priority(2), -- Widow's Embrace
		[28622] = Priority(2), -- Web Wrap
		[28169] = Priority(2), -- Mutating Injection
		[29213] = Priority(2), -- Curse of the Plaguebringer
		[28835] = Priority(2), -- Mark of Zeliek
		[27808] = Priority(2), -- Frost Blast
		[28410] = Priority(2), -- Chains of Kel'Thuzad
		[27819] = Priority(2), -- Detonate Mana

		----------------------------------------------------------
		-------------------- Blackfathom Deeps -------------------
		----------------------------------------------------------
		-- Baron Aquanis
		[404806] = Priority(2), -- Depth Charge
		-- Ghamoo-ra
		[407095] = Priority(2), -- Crunch Armor
		-- Lady Saravess
		[407644] = Priority(2), -- Forked Lightning
		[407546] = Priority(2), -- Freezing Arrow
		-- Gelihast
		[411959] = Priority(2), -- Fear
		-- Twilight Lord Kelris
		[426495] = Priority(2), -- Shadowy Chains
		-- Aku'mai
		[427625] = Priority(2), -- Corrosion
		[428482] = Priority(2), -- Shadow Seep
		----------------------------------------------------------
		------------------------ Gnomeregan ----------------------
		----------------------------------------------------------
		-- Grubbis
		[434165] = Priority(2), -- Irradiated Cloud
		[436069] = Priority(2), -- Radiation?
		[436100] = Priority(2), -- Petrify
		[434724] = Priority(2), -- Radiation Sickness
		-- Viscous Fallout
		[434433] = Priority(2), -- Sludge
		[433546] = Priority(2), -- Radiation Burn
		-- Electrocutioner 6000
		[433251] = Priority(2), -- Static Arc
		[433359] = Priority(2), -- Magnetic Pulse
		-- Crowd Pummeler 9-60
		[431839] = Priority(2), -- Off Balanced
		[432308] = Priority(2), -- The Claw!
		-- Mechanical Menagerie
		[440014] = Priority(2), -- Sprocketfire
		-- Mekgineer Thermaplugg
		[438714] = Priority(2), -- Furnace Surge
		[438727] = Priority(2), -- Radiation Sickness
		[438732] = Priority(2), -- Toxic Ventilation
		[438735] = Priority(2), -- High Voltage!
		[438720] = Priority(2), -- Freezing
		----------------------------------------------------------
		---------------------- Sunken Temple ---------------------
		----------------------------------------------------------
		-- Atal'alarion
		[437617] = Priority(2), -- Demolishing Smash
		-- Festering Rotslime
		[438142] = Priority(3), -- Gunk
		-- Atal'ai Defenders
		[446354] = Priority(2), -- Shield Slam
		[446373] = Priority(2), -- Corrupted Slam
		-- Dreamscythe and Weaver
		[442622] = Priority(2), -- Acid Breath
		-- Jammal'an and Ogom
		[437868] = Priority(3), -- Agonizing Weakness
		[437847] = Priority(6), -- Mortal Lash
		-- Morphaz and Hazzas
		[445158] = Priority(2), -- Lucid Dreaming
		[445555] = Priority(3), -- On Fire!!
		-- Shade of Eranikus
		[437390] = Priority(6), -- Lethargic Poison
		[437324] = Priority(2), -- Deep Slumber
		-- Avatar of Hakkar
		[444255] = Priority(6), -- Corrupted Blood
		[444165] = Priority(5), -- Skeletal
	},
}

C.DebuffsTracking_PvP = {
	["type"] = "WhitePriority",
	["spells"] = {
		-- Evoker
		[355689] = Priority(2), -- Landslide
		[370898] = Priority(1), -- Permeating Chill
		[360806] = Priority(3), -- Sleep Walk
		-- Death Knight
		[47476] = Priority(2), -- Strangulate
		[108194] = Priority(4), -- Asphyxiate UH
		[221562] = Priority(4), -- Asphyxiate Blood
		[207171] = Priority(4), -- Winter is Coming
		[206961] = Priority(3), -- Tremble Before Me
		[207167] = Priority(4), -- Blinding Sleet
		[212540] = Priority(1), -- Flesh Hook (Pet)
		[91807] = Priority(1), -- Shambling Rush (Pet)
		[204085] = Priority(1), -- Deathchill
		[233395] = Priority(1), -- Frozen Center
		[212332] = Priority(4), -- Smash (Pet)
		[212337] = Priority(4), -- Powerful Smash (Pet)
		[91800] = Priority(4), -- Gnaw (Pet)
		[91797] = Priority(4), -- Monstrous Blow (Pet)
		[210141] = Priority(3), -- Zombie Explosion
		-- Demon Hunter
		[207685] = Priority(4), -- Sigil of Misery
		[217832] = Priority(3), -- Imprison
		[221527] = Priority(5), -- Imprison (Banished version)
		[204490] = Priority(2), -- Sigil of Silence
		[179057] = Priority(3), -- Chaos Nova
		[211881] = Priority(4), -- Fel Eruption
		[205630] = Priority(3), -- Illidan's Grasp
		[208618] = Priority(3), -- Illidan's Grasp (Afterward)
		[213491] = Priority(4), -- Demonic Trample 1
		[208645] = Priority(4), -- Demonic Trample 2
		-- Druid
		[81261] = Priority(2), -- Solar Beam
		[5211] = Priority(4), -- Mighty Bash
		[163505] = Priority(4), -- Rake
		[203123] = Priority(4), -- Maim
		[202244] = Priority(4), -- Overrun
		[99] = Priority(4), -- Incapacitating Roar
		[33786] = Priority(5), -- Cyclone
		[45334] = Priority(1), -- Immobilized
		[102359] = Priority(1), -- Mass Entanglement
		[339] = Priority(1), -- Entangling Roots
		[2637] = Priority(1), -- Hibernate
		[102793] = Priority(1), -- Ursol's Vortex
		-- Hunter
		[202933] = Priority(2), -- Spider Sting 1
		[233022] = Priority(2), -- Spider Sting 2
		[213691] = Priority(4), -- Scatter Shot
		[19386] = Priority(3), -- Wyvern Sting
		[3355] = Priority(3), -- Freezing Trap
		[203337] = Priority(5), -- Freezing Trap (PvP Talent)
		[209790] = Priority(3), -- Freezing Arrow
		[24394] = Priority(4), -- Intimidation
		[117526] = Priority(4), -- Binding Shot
		[190927] = Priority(1), -- Harpoon
		[201158] = Priority(1), -- Super Sticky Tar
		[162480] = Priority(1), -- Steel Trap
		[212638] = Priority(1), -- Tracker's Net
		[200108] = Priority(1), -- Ranger's Net
		-- Mage
		[61721] = Priority(3), -- Rabbit
		[61305] = Priority(3), -- Black Cat
		[28272] = Priority(3), -- Pig
		[28271] = Priority(3), -- Turtle
		[126819] = Priority(3), -- Porcupine
		[161354] = Priority(3), -- Monkey
		[161353] = Priority(3), -- Polar Bear
		[61780] = Priority(3), -- Turkey
		[161355] = Priority(3), -- Penguin
		[161372] = Priority(3), -- Peacock
		[277787] = Priority(3), -- Direhorn
		[277792] = Priority(3), -- Bumblebee
		[118] = Priority(3), -- Polymorph
		[82691] = Priority(3), -- Ring of Frost
		[31661] = Priority(3), -- Dragon's Breath
		[122] = Priority(1), -- Frost Nova
		[33395] = Priority(1), -- Freeze
		[157997] = Priority(1), -- Ice Nova
		[228600] = Priority(1), -- Glacial Spike
		[198121] = Priority(1), -- Frostbite
		-- Monk
		[119381] = Priority(4), -- Leg Sweep
		[202346] = Priority(4), -- Double Barrel
		[115078] = Priority(4), -- Paralysis
		[198909] = Priority(3), -- Song of Chi-Ji
		[202274] = Priority(3), -- Incendiary Brew
		[233759] = Priority(2), -- Grapple Weapon
		[123407] = Priority(1), -- Spinning Fire Blossom
		[116706] = Priority(1), -- Disable
		[232055] = Priority(4), -- Fists of Fury
		-- Paladin
		[853] = Priority(3), -- Hammer of Justice
		[20066] = Priority(3), -- Repentance
		[105421] = Priority(3), -- Blinding Light
		[31935] = Priority(2), -- Avenger's Shield
		[217824] = Priority(2), -- Shield of Virtue
		[205290] = Priority(3), -- Wake of Ashes
		-- Priest
		[9484] = Priority(3), -- Shackle Undead
		[200196] = Priority(4), -- Holy Word: Chastise
		[200200] = Priority(4), -- Holy Word: Chastise
		[226943] = Priority(3), -- Mind Bomb
		[605] = Priority(5), -- Mind Control
		[8122] = Priority(3), -- Psychic Scream
		[15487] = Priority(2), -- Silence
		[64044] = Priority(1), -- Psychic Horror
		[453] = Priority(5), -- Mind Soothe
		-- Rogue
		[2094] = Priority(4), -- Blind
		[6770] = Priority(4), -- Sap
		[1776] = Priority(4), -- Gouge
		[1330] = Priority(2), -- Garrote - Silence
		[207777] = Priority(2), -- Dismantle
		[408] = Priority(4), -- Kidney Shot
		[1833] = Priority(4), -- Cheap Shot
		[207736] = Priority(5), -- Shadowy Duel (Smoke effect)
		[212182] = Priority(5), -- Smoke Bomb
		-- Shaman
		[51514] = Priority(3), -- Hex
		[211015] = Priority(3), -- Hex (Cockroach)
		[211010] = Priority(3), -- Hex (Snake)
		[211004] = Priority(3), -- Hex (Spider)
		[210873] = Priority(3), -- Hex (Compy)
		[196942] = Priority(3), -- Hex (Voodoo Totem)
		[269352] = Priority(3), -- Hex (Skeletal Hatchling)
		[277778] = Priority(3), -- Hex (Zandalari Tendonripper)
		[277784] = Priority(3), -- Hex (Wicker Mongrel)
		[118905] = Priority(3), -- Static Charge
		[77505] = Priority(4), -- Earthquake (Knocking down)
		[118345] = Priority(4), -- Pulverize (Pet)
		[204399] = Priority(3), -- Earthfury
		[204437] = Priority(3), -- Lightning Lasso
		[157375] = Priority(4), -- Gale Force
		[64695] = Priority(1), -- Earthgrab
		-- Warlock
		[710] = Priority(5), -- Banish
		[6789] = Priority(3), -- Mortal Coil
		[118699] = Priority(3), -- Fear
		[6358] = Priority(3), -- Seduction (Succub)
		[171017] = Priority(4), -- Meteor Strike (Infernal)
		[22703] = Priority(4), -- Infernal Awakening (Infernal CD)
		[30283] = Priority(3), -- Shadowfury
		[89766] = Priority(4), -- Axe Toss
		[233582] = Priority(1), -- Entrenched in Flame
		-- Warrior
		[5246] = Priority(4), -- Intimidating Shout
		[132169] = Priority(4), -- Storm Bolt
		[132168] = Priority(4), -- Shockwave
		[199085] = Priority(4), -- Warpath
		[199042] = Priority(1), -- Thunderstruck
		[236077] = Priority(2), -- Disarm
		[105771] = Priority(2), -- Charge
		-- Racial
		[20549] = Priority(4), -- War Stomp
		[107079] = Priority(4), -- Quaking Palm
	},
}
