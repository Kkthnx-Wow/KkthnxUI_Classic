local K, C = unpack(select(2, ...))

local function Priority(priorityOverride)
	return {
		enable = true,
		priority = priorityOverride or 0,
		stackThreshold = 0
	}
end

-- Raid Debuffs
C.DebuffsTracking_PvE = {
	["type"] = "Whitelist",
	["spells"] = {
		-- Mythic+ Dungeons
		[209858] = Priority(), -- Necrotic
		[226512] = Priority(), -- Sanguine
		[240559] = Priority(), -- Grievous
		[240443] = Priority(), -- Bursting
		[196376] = Priority(), -- Grievous Tear
		-- 8.3 Affix
		[314531] = Priority(), -- Tear Flesh
		[314308] = Priority(), -- Spirit Breaker
		[314478] = Priority(), -- Cascading Terror
		[314483] = Priority(), -- Cascading Terror
		[314592] = Priority(), -- Mind Flay
		[314406] = Priority(), -- Crippling Pestilence
		[314411] = Priority(), -- Lingering Doubt
		[314565] = Priority(), -- Defiled Ground
		[314392] = Priority(), -- Vile Corruption

		-- BFA Dungeons
		-- Freehold
		[258323] = Priority(), -- Infected Wound
		[257775] = Priority(), -- Plague Step
		[257908] = Priority(), -- Oiled Blade
		[257436] = Priority(), -- Poisoning Strike
		[274389] = Priority(), -- Rat Traps
		[274555] = Priority(), -- Scabrous Bites
		[258875] = Priority(), -- Blackout Barrel
		[256363] = Priority(), -- Ripper Punch
		-- Shrine of the Storm
		[264560] = Priority(), -- Choking Brine
		[268233] = Priority(), -- Electrifying Shock
		[268322] = Priority(), -- Touch of the Drowned
		[268896] = Priority(), -- Mind Rend
		[268104] = Priority(), -- Explosive Void
		[267034] = Priority(), -- Whispers of Power
		[276268] = Priority(), -- Heaving Blow
		[264166] = Priority(), -- Undertow
		[264526] = Priority(), -- Grasp of the Depths
		[274633] = Priority(), -- Sundering Blow
		[268214] = Priority(), -- Carving Flesh
		[267818] = Priority(), -- Slicing Blast
		[268309] = Priority(), -- Unending Darkness
		[268317] = Priority(), -- Rip Mind
		[268391] = Priority(), -- Mental Assault
		[274720] = Priority(), -- Abyssal Strike
		-- Siege of Boralus
		[257168] = Priority(), -- Cursed Slash
		[272588] = Priority(), -- Rotting Wounds
		[272571] = Priority(), -- Choking Waters
		[274991] = Priority(), -- Putrid Waters
		[275835] = Priority(), -- Stinging Venom Coating
		[273930] = Priority(), -- Hindering Cut
		[257292] = Priority(), -- Heavy Slash
		[261428] = Priority(), -- Hangman's Noose
		[256897] = Priority(), -- Clamping Jaws
		[272874] = Priority(), -- Trample
		[273470] = Priority(), -- Gut Shot
		[272834] = Priority(), -- Viscous Slobber
		[257169] = Priority(), -- Terrifying Roar
		[272713] = Priority(), -- Crushing Slam
		-- Tol Dagor
		[258128] = Priority(), -- Debilitating Shout
		[265889] = Priority(), -- Torch Strike
		[257791] = Priority(), -- Howling Fear
		[258864] = Priority(), -- Suppression Fire
		[257028] = Priority(), -- Fuselighter
		[258917] = Priority(), -- Righteous Flames
		[257777] = Priority(), -- Crippling Shiv
		[258079] = Priority(), -- Massive Chomp
		[258058] = Priority(), -- Squeeze
		[260016] = Priority(), -- Itchy Bite
		[257119] = Priority(), -- Sand Trap
		[260067] = Priority(), -- Vicious Mauling
		[258313] = Priority(), -- Handcuff
		[259711] = Priority(), -- Lockdown
		[256198] = Priority(), -- Azerite Rounds: Incendiary
		[256101] = Priority(), -- Explosive Burst (mythic)
		[256105] = Priority(), -- Explosive Burst (mythic+)
		[256044] = Priority(), -- Deadeye
		[256474] = Priority(), -- Heartstopper Venom
		-- Waycrest Manor
		[260703] = Priority(), -- Unstable Runic Mark
		[263905] = Priority(), -- Marking Cleave
		[265880] = Priority(), -- Dread Mark
		[265882] = Priority(), -- Lingering Dread
		[264105] = Priority(), -- Runic Mark
		[264050] = Priority(), -- Infected Thorn
		[261440] = Priority(), -- Virulent Pathogen
		[263891] = Priority(), -- Grasping Thorns
		[264378] = Priority(), -- Fragment Soul
		[266035] = Priority(), -- Bone Splinter
		[266036] = Priority(), -- Drain Essence
		[260907] = Priority(), -- Soul Manipulation
		[260741] = Priority(), -- Jagged Nettles
		[264556] = Priority(), -- Tearing Strike
		[265760] = Priority(), -- Thorned Barrage
		[260551] = Priority(), -- Soul Thorns
		[263943] = Priority(), -- Etch
		[265881] = Priority(), -- Decaying Touch
		[261438] = Priority(), -- Wasting Strike
		[268202] = Priority(), -- Death Lens
		[278456] = Priority(), -- Infest
		[264153] = Priority(), -- Spit
		-- AtalDazar
		[252781] = Priority(), -- Unstable Hex
		[250096] = Priority(), -- Wracking Pain
		[250371] = Priority(), -- Lingering Nausea
		[253562] = Priority(), -- Wildfire
		[255582] = Priority(), -- Molten Gold
		[255041] = Priority(), -- Terrifying Screech
		[255371] = Priority(), -- Terrifying Visage
		[252687] = Priority(), -- Venomfang Strike
		[254959] = Priority(), -- Soulburn
		[255814] = Priority(), -- Rending Maul
		[255421] = Priority(), -- Devour
		[255434] = Priority(), -- Serrated Teeth
		[256577] = Priority(), -- Soulfeast
		-- Kings Rest
		[270492] = Priority(), -- Hex
		[267763] = Priority(), -- Wretched Discharge
		[276031] = Priority(), -- Pit of Despair
		[265773] = Priority(), -- Spit Gold
		[270920] = Priority(), -- Seduction
		[270865] = Priority(), -- Hidden Blade
		[271564] = Priority(), -- Embalming Fluid
		[270507] = Priority(), -- Poison Barrage
		[267273] = Priority(), -- Poison Nova
		[270003] = Priority(), -- Suppression Slam
		[270084] = Priority(), -- Axe Barrage
		[267618] = Priority(), -- Drain Fluids
		[267626] = Priority(), -- Dessication
		[270487] = Priority(), -- Severing Blade
		[266238] = Priority(), -- Shattered Defenses
		[266231] = Priority(), -- Severing Axe
		[266191] = Priority(), -- Whirling Axes
		[272388] = Priority(), -- Shadow Barrage
		[271640] = Priority(), -- Dark Revelation
		[268796] = Priority(), -- Impaling Spear
		[268419] = Priority(), -- Gale Slash
		[269932] = Priority(), -- Gust Slash
		-- Motherlode
		[263074] = Priority(), -- Festering Bite
		[280605] = Priority(), -- Brain Freeze
		[257337] = Priority(), -- Shocking Claw
		[270882] = Priority(), -- Blazing Azerite
		[268797] = Priority(), -- Transmute: Enemy to Goo
		[259856] = Priority(), -- Chemical Burn
		[269302] = Priority(), -- Toxic Blades
		[280604] = Priority(), -- Iced Spritzer
		[257371] = Priority(), -- Tear Gas
		[257544] = Priority(), -- Jagged Cut
		[268846] = Priority(), -- Echo Blade
		[262794] = Priority(), -- Energy Lash
		[262513] = Priority(), -- Azerite Heartseeker
		[260829] = Priority(), -- Homing Missle (travelling)
		[260838] = Priority(), -- Homing Missle (exploded)
		[263637] = Priority(), -- Clothesline
		-- Temple of Sethraliss
		[269686] = Priority(), -- Plague
		[268013] = Priority(), -- Flame Shock
		[268008] = Priority(), -- Snake Charm
		[273563] = Priority(), -- Neurotoxin
		[272657] = Priority(), -- Noxious Breath
		[267027] = Priority(), -- Cytotoxin
		[272699] = Priority(), -- Venomous Spit
		[263371] = Priority(), -- Conduction
		[272655] = Priority(), -- Scouring Sand
		[263914] = Priority(), -- Blinding Sand
		[263958] = Priority(), -- A Knot of Snakes
		[266923] = Priority(), -- Galvanize
		[268007] = Priority(), -- Heart Attack
		-- Underrot
		[265468] = Priority(), -- Withering Curse
		[278961] = Priority(), -- Decaying Mind
		[259714] = Priority(), -- Decaying Spores
		[272180] = Priority(), -- Death Bolt
		[272609] = Priority(), -- Maddening Gaze
		[269301] = Priority(), -- Putrid Blood
		[265533] = Priority(), -- Blood Maw
		[265019] = Priority(), -- Savage Cleave
		[265377] = Priority(), -- Hooked Snare
		[265625] = Priority(), -- Dark Omen
		[260685] = Priority(), -- Taint of G'huun
		[266107] = Priority(), -- Thirst for Blood
		[260455] = Priority(), -- Serrated Fangs
		-- Operation Mechagon
		[291928] = Priority(), -- Giga-Zap
		[292267] = Priority(), -- Giga-Zap
		[302274] = Priority(), -- Fulminating Zap
		[298669] = Priority(), -- Taze
		[295445] = Priority(), -- Wreck
		[294929] = Priority(), -- Blazing Chomp
		[297257] = Priority(), -- Electrical Charge
		[294855] = Priority(), -- Blossom Blast
		[291972] = Priority(), -- Explosive Leap
		[285443] = Priority(), -- 'Hidden' Flame Cannon
		[291974] = Priority(), -- Obnoxious Monologue
		[296150] = Priority(), -- Vent Blast
		[298602] = Priority(), -- Smoke Cloud
		[296560] = Priority(), -- Clinging Static
		[297283] = Priority(), -- Cave In
		[291914] = Priority(), -- Cutting Beam
		[302384] = Priority(), -- Static Discharge
		[294195] = Priority(), -- Arcing Zap
		[299572] = Priority(), -- Shrink
		[300659] = Priority(), -- Consuming Slime
		[300650] = Priority(), -- Suffocating Smog
		[301712] = Priority(), -- Pounce
		[299475] = Priority(), -- B.O.R.K
		[293670] = Priority(), -- Chain Blade

		-- Uldir
		-- MOTHER
		[268277] = Priority(), -- Purifying Flame
		[268253] = Priority(), -- Surgical Beam
		[268095] = Priority(), -- Cleansing Purge
		[267787] = Priority(), -- Sundering Scalpel
		[268198] = Priority(), -- Clinging Corruption
		[267821] = Priority(), -- Defense Grid
		-- Vectis
		[265127] = Priority(), -- Lingering Infection
		[265178] = Priority(), -- Mutagenic Pathogen
		[265206] = Priority(), -- Immunosuppression
		[265212] = Priority(), -- Gestate
		[265129] = Priority(), -- Omega Vector
		[267160] = Priority(), -- Omega Vector
		[267161] = Priority(), -- Omega Vector
		[267162] = Priority(), -- Omega Vector
		[267163] = Priority(), -- Omega Vector
		[267164] = Priority(), -- Omega Vector
		-- Mythrax
		[272536] = Priority(), -- Imminent Ruin
		[274693] = Priority(), -- Essence Shear
		[272407] = Priority(), -- Oblivion Sphere
		-- Fetid Devourer
		[262313] = Priority(), -- Malodorous Miasma
		[262292] = Priority(), -- Rotting Regurgitation
		[262314] = Priority(), -- Deadly Disease
		-- Taloc
		[270290] = Priority(), -- Blood Storm
		[275270] = Priority(), -- Fixate
		[271224] = Priority(), -- Plasma Discharge
		[271225] = Priority(), -- Plasma Discharge
		-- Zul
		[273365] = Priority(), -- Dark Revelation
		[273434] = Priority(), -- Pit of Despair
		[272018] = Priority(), -- Absorbed in Darkness
		[274358] = Priority(), -- Rupturing Blood
		-- Zekvoz
		[265237] = Priority(), -- Shatter
		[265264] = Priority(), -- Void Lash
		[265360] = Priority(), -- Roiling Deceit
		[265662] = Priority(), -- Corruptor's Pact
		[265646] = Priority(), -- Will of the Corruptor
		-- Ghuun
		[263436] = Priority(), -- Imperfect Physiology
		[263227] = Priority(), -- Putrid Blood
		[263372] = Priority(), -- Power Matrix
		[272506] = Priority(), -- Explosive Corruption
		[267409] = Priority(), -- Dark Bargain
		[267430] = Priority(), -- Torment
		[263235] = Priority(), -- Blood Feast
		[270287] = Priority(), -- Blighted Ground

		-- Siege of Zuldazar
		-- Rawani Kanae / Frida Ironbellows
		[283573] = Priority(), -- Sacred Blade
		[283617] = Priority(), -- Wave of Light
		[283651] = Priority(), -- Blinding Faith
		[284595] = Priority(), -- Penance
		[283582] = Priority(), -- Consecration
		-- Grong
		[285998] = Priority(), -- Ferocious Roar
		[283069] = Priority(), -- Megatomic Fire
		[285671] = Priority(), -- Crushed
		[285875] = Priority(), -- Rending Bite
		-- Jaina
		[285253] = Priority(), -- Ice Shard
		[287993] = Priority(), -- Chilling Touch
		[287365] = Priority(), -- Searing Pitch
		[288038] = Priority(), -- Marked Target
		[285254] = Priority(), -- Avalanche
		[287626] = Priority(), -- Grasp of Frost
		[287490] = Priority(), -- Frozen Solid
		[287199] = Priority(), -- Ring of Ice
		[288392] = Priority(), -- Vengeful Seas
		-- Stormwall Blockade
		[284369] = Priority(), -- Sea Storm
		[284410] = Priority(), -- Tempting Song
		[284405] = Priority(), -- Tempting Song
		[284121] = Priority(), -- Thunderous Boom
		[286680] = Priority(), -- Roiling Tides
		-- Opulence
		[286501] = Priority(), -- Creeping Blaze
		[283610] = Priority(), -- Crush
		[289383] = Priority(), -- Chaotic Displacement
		[285479] = Priority(), -- Flame Jet
		[283063] = Priority(), -- Flames of Punishment
		[283507] = Priority(), -- Volatile Charge
		-- King Rastakhan
		[284995] = Priority(), -- Zombie Dust
		[285349] = Priority(), -- Plague of Fire
		[285044] = Priority(), -- Toad Toxin
		[284831] = Priority(), -- Scorching Detonation
		[289858] = Priority(), -- Crushed
		[284662] = Priority(), -- Seal of Purification
		[284676] = Priority(), -- Seal of Purification
		[285178] = Priority(), -- Serpent's Breath
		[285010] = Priority(), -- Poison Toad Slime
		-- Jadefire Masters
		[282037] = Priority(), -- Rising Flames
		[284374] = Priority(), -- Magma Trap
		[285632] = Priority(), -- Stalking
		[288151] = Priority(), -- Tested
		[284089] = Priority(), -- Successful Defense
		[286988] = Priority(), -- Searing Embers
		-- Mekkatorque
		[288806] = Priority(), -- Gigavolt Blast
		[289023] = Priority(), -- Enormous
		[286646] = Priority(), -- Gigavolt Charge
		[288939] = Priority(), -- Gigavolt Radiation
		[284168] = Priority(), -- Shrunk
		[286516] = Priority(), -- Anti-Tampering Shock
		[286480] = Priority(), -- Anti-Tampering Shock
		[284214] = Priority(), -- Trample
		-- Conclave of the Chosen
		[284663] = Priority(), -- Bwonsamdi's Wrath
		[282444] = Priority(), -- Lacerating Claws
		[282592] = Priority(), -- Bleeding Wounds
		[282209] = Priority(), -- Mark of Prey
		[285879] = Priority(), -- Mind Wipe
		[282135] = Priority(), -- Crawling Hex
		[286060] = Priority(), -- Cry of the Fallen
		[282447] = Priority(), -- Kimbul's Wrath
		[282834] = Priority(), -- Kimbul's Wrath
		[286811] = Priority(), -- Akunda's Wrath
		[286838] = Priority(), -- Static Orb

		-- Crucible of Storms
		-- The Restless Cabal
		[282386] = Priority(), -- Aphotic Blast
		[282384] = Priority(), -- Shear Mind
		[282566] = Priority(), -- Promises of Power
		[282561] = Priority(), -- Dark Herald
		[282432] = Priority(), -- Crushing Doubt
		[282589] = Priority(), -- Mind Scramble
		[292826] = Priority(), -- Mind Scramble
		-- Fathuul the Feared
		[284851] = Priority(), -- Touch of the End
		[286459] = Priority(), -- Feedback: Void
		[286457] = Priority(), -- Feedback: Ocean
		[286458] = Priority(), -- Feedback: Storm
		[285367] = Priority(), -- Piercing Gaze of N'Zoth
		[284733] = Priority(), -- Embrace of the Void
		[284722] = Priority(), -- Umbral Shell
		[285345] = Priority(), -- Maddening Eyes of N'Zoth
		[285477] = Priority(), -- Obscurity
		[285652] = Priority(), -- Insatiable Torment

		-- Eternal Palace
		-- Lady Ashvane
		[296693] = Priority(), -- Waterlogged
		[296725] = Priority(), -- Barnacle Bash
		[296942] = Priority(), -- Arcing Azerite
		[296938] = Priority(), -- Arcing Azerite
		[296941] = Priority(), -- Arcing Azerite
		[296939] = Priority(), -- Arcing Azerite
		[296943] = Priority(), -- Arcing Azerite
		[296940] = Priority(), -- Arcing Azerite
		[296752] = Priority(), -- Cutting Coral
		[297333] = Priority(), -- Briny Bubble
		[297397] = Priority(), -- Briny Bubble
		-- Abyssal Commander Sivara
		[300701] = Priority(), -- Rimefrost
		[300705] = Priority(), -- Septic Taint
		[294847] = Priority(), -- Unstable Mixture
		[295850] = Priority(), -- Delirious
		[295421] = Priority(), -- Overflowing Venom
		[295348] = Priority(), -- Overflowing Chill
		[295807] = Priority(), -- Frozen
		[300883] = Priority(), -- Inversion Sickness
		[295705] = Priority(), -- Toxic Bolt
		[295704] = Priority(), -- Frost Bolt
		[294711] = Priority(), -- Frost Mark
		[294715] = Priority(), -- Toxic Brand
		-- The Queens Court
		[301830] = Priority(), -- Pashmar's Touch
		[296851] = Priority(), -- Fanatical Verdict
		[297836] = Priority(), -- Potent Spark
		[297586] = Priority(), -- Suffering
		[304410] = Priority(), -- Repeat Performance
		[299914] = Priority(), -- Frenetic Charge
		[303306] = Priority(), -- Sphere of Influence
		[300545] = Priority(), -- Mighty Rupture
		-- Radiance of Azshara
		[296566] = Priority(), -- Tide Fist
		[296737] = Priority(), -- Arcane Bomb
		[296746] = Priority(), -- Arcane Bomb
		[295920] = Priority(), -- Ancient Tempest
		[296462] = Priority(), -- Squall Trap
		-- Orgozoa
		[298156] = Priority(), -- Desensitizing Sting
		[298306] = Priority(), -- Incubation Fluid
		-- Blackwater Behemoth
		[292127] = Priority(), -- Darkest Depths
		[292138] = Priority(), -- Radiant Biomass
		[292167] = Priority(), -- Toxic Spine
		[301494] = Priority(), -- Piercing Barb
		-- Zaqul
		[295495] = Priority(), -- Mind Tether
		[295480] = Priority(), -- Mind Tether
		[295249] = Priority(), -- Delirium Realm
		[303819] = Priority(), -- Nightmare Pool
		[293509] = Priority(), -- Manifest Nightmares
		[295327] = Priority(), -- Shattered Psyche
		[294545] = Priority(), -- Portal of Madness
		[298192] = Priority(), -- Dark Beyond
		[292963] = Priority(), -- Dread
		[300133] = Priority(), -- Snapped
		-- Queen Azshara
		[298781] = Priority(), -- Arcane Orb
		[297907] = Priority(), -- Cursed Heart
		[302999] = Priority(), -- Arcane Vulnerability
		[302141] = Priority(), -- Beckon
		[299276] = Priority(), -- Sanction
		[303657] = Priority(), -- Arcane Burst
		[298756] = Priority(), -- Serrated Edge
		[301078] = Priority(), -- Charged Spear
		[298014] = Priority(), -- Cold Blast
		[298018] = Priority(), -- Frozen

		-- Nyalotha
		-- Wrathion
		[313255] = Priority(), -- Creeping Madness (Slow Effect)
		[306163] = Priority(), -- Incineration
		[306015] = Priority(), -- Searing Armor [tank]
		-- Maut
		[307805] = Priority(), -- Devour Magic
		[314337] = Priority(), -- Ancient Curse
		[306301] = Priority(), -- Forbidden Mana
		[314992] = Priority(), -- Darin Essence
		[307399] = Priority(), -- Shadow Claws [tank]
		-- Prophet Skitra
		[306387] = Priority(), -- Shadow Shock
		[313276] = Priority(), -- Shred Psyche
		-- Dark Inquisitor
		[306311] = Priority(), -- Soul Flay
		[312406] = Priority(), -- Void Woken
		[311551] = Priority(), -- Abyssal Strike [tank]
		-- Hivemind
		[313461] = Priority(), -- Corrosion
		[313672] = Priority(), -- Acid Pool
		[313460] = Priority(), -- Nullification
		-- Shadhar
		[307471] = Priority(), -- Crush [tank]
		[307472] = Priority(), -- Dissolve [tank]
		[307358] = Priority(), -- Debilitating Spit
		[306928] = Priority(), -- Umbral Breath
		[312530] = Priority(), -- Entropic Breath
		[306929] = Priority(), -- Bubbling Breath
		[318078] = Priority(), -- Fixated
		-- Drest
		[310406] = Priority(), -- Void Glare
		[310277] = Priority(), -- Volatile Seed [tank]
		[310309] = Priority(), -- Volatile Vulnerability
		[310358] = Priority(), -- Mutterings of Insanity
		[310552] = Priority(), -- Mind Flay
		[310478] = Priority(), -- Void Miasma
		-- Ilgy
		[309961] = Priority(), -- Eye of Nzoth [tank]
		[310322] = Priority(), -- Morass of Corruption
		[311401] = Priority(), -- Touch of the Corruptor
		[314396] = Priority(), -- Cursed Blood
		[275269] = Priority(), -- Fixate
		[312486] = Priority(), -- Recurring Nightmare
		-- Vexiona
		[307317] = Priority(), -- Encroaching Shadows
		[307359] = Priority(), -- Despair
		[315932] = Priority(), -- Brutal Smash
		[307218] = Priority(), -- Twilight Decimator
		[307284] = Priority(), -- Terrifying Presence
		[307421] = Priority(), -- Annihilation
		[307019] = Priority(), -- Void Corruption [tank]
		-- Raden
		[306819] = Priority(), -- Nullifying Strike [tank]
		[306279] = Priority(), -- Insanity Exposure
		[315258] = Priority(), -- Dread Inferno
		[306257] = Priority(), -- Unstable Vita
		[313227] = Priority(), -- Decaying Wound
		[310019] = Priority(), -- Charged Bonds
		[316065] = Priority(), -- Corrupted Existence
		-- Carapace
		[315954] = Priority(), -- Black Scar [tank]
		[306973] = Priority(), -- Madness
		[316848] = Priority(), -- Adaptive Membrane
		[307044] = Priority(), -- Nightmare Antibody
		[313364] = Priority(), -- Mental Decay
		[317627] = Priority(), -- Infinite Void
		-- Nzoth
		[318442] = Priority(), -- Paranoia
		[313400] = Priority(), -- Corrupted Mind
		[313793] = Priority(), -- Flames of Insanity
		[316771] = Priority(), -- Mindwrack
		[314889] = Priority(), -- Probe Mind
		[317112] = Priority(), -- Evoke Anguish
		[318976] = Priority(), -- Stupefying Glare
	},
}

-- Dispell Debuffs
C.DebuffsTracking_PvP = {
	["type"] = "Whitelist",
	["spells"] = {
		-- Death Knight
		[204085] = Priority(5), -- Deathchill
		[233395] = Priority(5), -- Frozen Center
		-- Demon Hunter
		[217832] = Priority(5), -- Imprison
		[179057] = Priority(5), -- Chaos Nova
		[205630] = Priority(5), -- Illidan's Grasp
		[208618] = Priority(5), -- Illidan's Grasp (Afterward)
		-- Druid
		[102359] = Priority(5), -- Mass Entanglement
		[339] = Priority(5), -- Entangling Roots
		[2637] = Priority(5), -- Hibernate
		-- Hunter
		[3355] = Priority(5), -- Freezing Trap
		[203337] = Priority(5), -- Freezing Trap (Survival PvP)
		[209790] = Priority(5), -- Freezing Arrow
		[117526] = Priority(5), -- Binding Shot
		-- Mage
		[61721] = Priority(5), -- Rabbit (Poly)
		[61305] = Priority(5), -- Black Cat (Poly)
		[28272] = Priority(5), -- Pig (Poly)
		[28271] = Priority(5), -- Turtle (Poly)
		[126819] = Priority(5), -- Porcupine (Poly)
		[161354] = Priority(5), -- Monkey (Poly)
		[161353] = Priority(5), -- Polar bear (Poly)
		[61780] = Priority(5), -- Turkey (Poly)
		[161355] = Priority(5), -- Penguin (Poly)
		[161372] = Priority(5), -- Peacock (Poly)
		[277787] = Priority(5), -- Direhorn (Poly)
		[277792] = Priority(5), -- Bumblebee (Poly)
		[118] = Priority(5), -- Polymorph
		[82691] = Priority(5), -- Ring of Frost
		[31661] = Priority(5), -- Dragon's Breath
		[122] = Priority(5), -- Frost Nova
		[33395] = Priority(5), -- Freeze
		[157997] = Priority(5), -- Ice Nova
		[198121] = Priority(5), -- Forstbite
		-- Monk
		[198909] = Priority(5), -- Song of Chi-Ji
		[202274] = Priority(5), -- Incendiary Brew
		--[123407] = Priority(5), -- Spinning Fire Blossom
		-- Paladin
		[853] = Priority(5), -- Hammer of Justice
		[20066] = Priority(5), -- Repentance
		[105421] = Priority(5), -- Blinding Light
		[31935] = Priority(5), -- Avenger's Shield
		[217824] = Priority(5), -- Shield of Virtue
		[205290] = Priority(5), -- Wake of Ashes
		-- Priest
		[9484] = Priority(5), -- Shackle Undead
		[226943] = Priority(5), -- Mind Bomb
		[605] = Priority(5), -- Mind Control
		[8122] = Priority(5), -- Psychic Scream
		[15487] = Priority(5), -- Silence
		[64044] = Priority(5), -- Psychic Horror
		-- Rogue
		-- Nothing to track
		-- Shaman
		[51514] = Priority(5), -- Hex
		[211015] = Priority(5), -- Hex (Cockroach)
		[211010] = Priority(5), -- Hex (Snake)
		[211004] = Priority(5), -- Hex (Spider)
		[210873] = Priority(5), -- Hex (Compy)
		[196942] = Priority(5), -- Hex (Voodoo Totem)
		[269352] = Priority(5), -- Hex (Skeletal Hatchling)
		[277778] = Priority(5), -- Hex (Zandalari Tendonripper)
		[277784] = Priority(5), -- Hex (Wicker Mongrel)
		[118905] = Priority(5), -- Static Charge
		[204399] = Priority(5), -- Earthfury
		[64695] = Priority(5), -- Earthgrab
		-- Warlock
		[710] = Priority(5), -- Banish
		[6789] = Priority(5), -- Mortal Coil
		[118699] = Priority(5), -- Fear
		[6358] = Priority(5), -- Seduction (Succub)
		[30283] = Priority(5), -- Shadowfury
		[233582] = Priority(5), -- Entrenched in Flame
		-- Warrior
		-- Nothing to track
	},
}

-- PvP CrowdControl
C.DebuffsTracking_CrowdControl = {
	["type"] = "Whitelist",
	["spells"] = {
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
		[213491] = Priority(4), -- Demonic Trample (it's this one or the other)
		[208645] = Priority(4), -- Demonic Trample
		-- Druid
		[81261] = Priority(2), -- Solar Beam
		[5211] = Priority(4), -- Mighty Bash
		[163505] = Priority(4), -- Rake
		[203123] = Priority(4), -- Maim
		[202244] = Priority(4), -- Overrun
		[99] = Priority(4), -- Incapacitating Roar
		[33786] = Priority(5), -- Cyclone
		[209753] = Priority(5), -- Cyclone Balance
		[45334] = Priority(1), -- Immobilized
		[102359] = Priority(1), -- Mass Entanglement
		[339] = Priority(1), -- Entangling Roots
		[2637] = Priority(1), -- Hibernate
		[102793] = Priority(1), -- Ursol's Vortex
		-- Hunter
		[202933] = Priority(2), -- Spider Sting (it's this one or the other)
		[233022] = Priority(2), -- Spider Sting
		[213691] = Priority(4), -- Scatter Shot
		[19386] = Priority(3), -- Wyvern Sting
		[3355] = Priority(3), -- Freezing Trap
		[203337] = Priority(5), -- Freezing Trap (Survival PvPT)
		[209790] = Priority(3), -- Freezing Arrow
		[24394] = Priority(4), -- Intimidation
		[117526] = Priority(4), -- Binding Shot
		[190927] = Priority(1), -- Harpoon
		[201158] = Priority(1), -- Super Sticky Tar
		[162480] = Priority(1), -- Steel Trap
		[212638] = Priority(1), -- Tracker's Net
		[200108] = Priority(1), -- Ranger's Net
		-- Mage
		[61721] = Priority(3), -- Rabbit (Poly)
		[61305] = Priority(3), -- Black Cat (Poly)
		[28272] = Priority(3), -- Pig (Poly)
		[28271] = Priority(3), -- Turtle (Poly)
		[126819] = Priority(3), -- Porcupine (Poly)
		[161354] = Priority(3), -- Monkey (Poly)
		[161353] = Priority(3), -- Polar bear (Poly)
		[61780] = Priority(3), -- Turkey (Poly)
		[161355] = Priority(3), -- Penguin (Poly)
		[161372] = Priority(3), -- Peacock (Poly)
		[277787] = Priority(3), -- Direhorn (Poly)
		[277792] = Priority(3), -- Bumblebee (Poly)
		[118] = Priority(3), -- Polymorph
		[82691] = Priority(3), -- Ring of Frost
		[31661] = Priority(3), -- Dragon's Breath
		[122] = Priority(1), -- Frost Nova
		[33395] = Priority(1), -- Freeze
		[157997] = Priority(1), -- Ice Nova
		[228600] = Priority(1), -- Glacial Spike
		[198121] = Priority(1), -- Forstbite
		-- Monk
		[119381] = Priority(4), -- Leg Sweep
		[202346] = Priority(4), -- Double Barrel
		[115078] = Priority(4), -- Paralysis
		[198909] = Priority(3), -- Song of Chi-Ji
		[202274] = Priority(3), -- Incendiary Brew
		[233759] = Priority(2), -- Grapple Weapon
		[123407] = Priority(1), -- Spinning Fire Blossom
		[116706] = Priority(1), -- Disable
		[232055] = Priority(4), -- Fists of Fury (it's this one or the other)
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
		-- Rogue
		[2094] = Priority(4), -- Blind
		[6770] = Priority(4), -- Sap
		[1776] = Priority(4), -- Gouge
		[1330] = Priority(2), -- Garrote - Silence
		[207777] = Priority(2), -- Dismantle
		[199804] = Priority(4), -- Between the Eyes
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
		[7922] = Priority(4), -- Warbringer
		[132169] = Priority(4), -- Storm Bolt
		[132168] = Priority(4), -- Shockwave
		[199085] = Priority(4), -- Warpath
		[105771] = Priority(1), -- Charge
		[199042] = Priority(1), -- Thunderstruck
		[236077] = Priority(2), -- Disarm
		-- Racial
		[20549] = Priority(4), -- War Stomp
		[107079] = Priority(4), -- Quaking Palm
	},
}

-- Buffs that really we dont need to see
C.DebuffsTracking_Blacklist = {
	type = "Blacklist",
	spells = {
		[36900]  = Priority(), -- Soul Split: Evil!
		[36901]  = Priority(), -- Soul Split: Good
		[36893]  = Priority(), -- Transporter Malfunction
		[97821]  = Priority(), -- Void-Touched
		[36032]  = Priority(), -- Arcane Charge
		[8733]   = Priority(), -- Blessing of Blackfathom
		[25771]  = Priority(), -- Forbearance (pally: divine shield, hand of protection, and lay on hands)
		[57724]  = Priority(), -- Sated (lust debuff)
		[57723]  = Priority(), -- Exhaustion (heroism debuff)
		[80354]  = Priority(), -- Temporal Displacement (timewarp debuff)
		[95809]  = Priority(), -- Insanity debuff (hunter pet heroism: ancient hysteria)
		[58539]  = Priority(), -- Watcher's Corpse
		[26013]  = Priority(), -- Deserter
		[71041]  = Priority(), -- Dungeon Deserter
		[41425]  = Priority(), -- Hypothermia
		[55711]  = Priority(), -- Weakened Heart
		[8326]   = Priority(), -- Ghost
		[23445]  = Priority(), -- Evil Twin
		[24755]  = Priority(), -- Tricked or Treated
		[25163]  = Priority(), -- Oozeling's Disgusting Aura
		[124275] = Priority(), -- Stagger
		[124274] = Priority(), -- Stagger
		[124273] = Priority(), -- Stagger
		[117870] = Priority(), -- Touch of The Titans
		[123981] = Priority(), -- Perdition
		[15007]  = Priority(), -- Ress Sickness
		[113942] = Priority(), -- Demonic: Gateway
		[89140]  = Priority(), -- Demonic Rebirth: Cooldown
		[287825] = Priority(), -- Lethargy debuff (fight or flight)
		[206662] = Priority(), -- Experience Eliminated (in range)
		[306600] = Priority(), -- Experience Eliminated (oor - 5m)
	},
}

C.ChannelingTicks = {
	--First Aid
	[23567] = 8, --Warsong Gulch Runecloth Bandage
	[23696] = 8, --Alterac Heavy Runecloth Bandage
	[24414] = 8, --Arathi Basin Runecloth Bandage
	[18610] = 8, --Heavy Runecloth Bandage
	[18608] = 8, --Runecloth Bandage
	[10839] = 8, --Heavy Mageweave Bandage
	[10838] = 8, --Mageweave Bandage
	[7927] = 8, --Heavy Silk Bandage
	[7926] = 8, --Silk Bandage
	[3268] = 7, --Heavy Wool Bandage
	[3267] = 7, --Wool Bandage
	[1159] = 6, --Heavy Linen Bandage
	[746] = 6, --Linen Bandage
	-- Warlock
	[1120] = 5, -- Drain Soul(Rank 1)
	[8288] = 5, -- Drain Soul(Rank 2)
	[8289] = 5, -- Drain Soul(Rank 3)
	[11675] = 5, -- Drain Soul(Rank 4)
	[27217] = 5, -- Drain Soul(Rank 5)
	[755] = 10, -- Health Funnel(Rank 1)
	[3698] = 10, -- Health Funnel(Rank 2)
	[3699] = 10, -- Health Funnel(Rank 3)
	[3700] = 10, -- Health Funnel(Rank 4)
	[11693] = 10, -- Health Funnel(Rank 5)
	[11694] = 10, -- Health Funnel(Rank 6)
	[11695] = 10, -- Health Funnel(Rank 7)
	[27259] = 10, -- Health Funnel(Rank 8)
	[689] = 5, -- Drain Life(Rank 1)
	[699] = 5, -- Drain Life(Rank 2)
	[709] = 5, -- Drain Life(Rank 3)
	[7651] = 5, -- Drain Life(Rank 4)
	[11699] = 5, -- Drain Life(Rank 5)
	[11700] = 5, -- Drain Life(Rank 6)
	[27219] = 5, -- Drain Life(Rank 7)
	[27220] = 5, -- Drain Life(Rank 8)
	[5740] =  4, --Rain of Fire(Rank 1)
	[6219] =  4, --Rain of Fire(Rank 2)
	[11677] =  4, --Rain of Fire(Rank 3)
	[11678] =  4, --Rain of Fire(Rank 4)
	[27212] =  4, --Rain of Fire(Rank 5)
	[1949] = 15, --Hellfire(Rank 1)
	[11683] = 15, --Hellfire(Rank 2)
	[11684] = 15, --Hellfire(Rank 3)
	[27213] = 15, --Hellfire(Rank 4)
	[5138] = 5, --Drain Mana(Rank 1)
	[6226] = 5, --Drain Mana(Rank 2)
	[11703] = 5, --Drain Mana(Rank 3)
	[11704] = 5, --Drain Mana(Rank 4)
	[27221] = 5, --Drain Mana(Rank 5)
	[30908] = 5, --Drain Mana(Rank 6)
	-- Priest
	[15407] = 3, -- Mind Flay(Rank 1)
	[17311] = 3, -- Mind Flay(Rank 2)
	[17312] = 3, -- Mind Flay(Rank 3)
	[17313] = 3, -- Mind Flay(Rank 4)
	[17314] = 3, -- Mind Flay(Rank 5)
	[18807] = 3, -- Mind Flay(Rank 6)
	[25387] = 3, -- Mind Flay(Rank 7)
	-- Mage
	[10] = 8, --Blizzard(Rank 1)
	[6141] = 8, --Blizzard(Rank 2)
	[8427] = 8, --Blizzard(Rank 3)
	[10185] = 8, --Blizzard(Rank 4)
	[10186] = 8, --Blizzard(Rank 5)
	[10187] = 8, --Blizzard(Rank 6)
	[27085] = 8, --Blizzard(Rank 7)
	[5143] = 3, -- Arcane Missiles(Rank 1)
	[5144] = 4, -- Arcane Missiles(Rank 2)
	[5145] = 5, -- Arcane Missiles(Rank 3)
	[8416] = 5, -- Arcane Missiles(Rank 4)
	[8417] = 5, -- Arcane Missiles(Rank 5)
	[10211] = 5, -- Arcane Missiles(Rank 6)
	[10212] = 5, -- Arcane Missiles(Rank 7)
	[25345] = 5, -- Arcane Missiles(Rank 8)
	[27075] = 5, -- Arcane Missiles(Rank 9)
	[38699] = 5, -- Arcane Missiles(Rank 10)
	[12051] = 4, -- Evocation
	--Druid
	[740] = 5, -- Tranquility(Rank 1)
	[8918] = 5, --Tranquility(Rank 2)
	[9862] = 5, --Tranquility(Rank 3)
	[9863] = 5, --Tranquility(Rank 4)
	[26983] = 5, --Tranquility(Rank 5)
	[16914] = 10, --Hurricane(Rank 1)
	[17401] = 10, --Hurricane(Rank 2)
	[17402] = 10, --Hurricane(Rank 3)
	[27012] = 10, --Hurricane(Rank 4)
	--Hunter
	[1510] = 6, --Volley(Rank 1)
	[14294] = 6, --Volley(Rank 2)
	[14295] = 6, --Volley(Rank 3)
	[27022] = 6, --Volley(Rank 4)
}

if K.Class == "PRIEST" then
	local penanceID = 47758
	local function updateTicks()
		local numTicks = 3
		if IsPlayerSpell(193134) then numTicks = 4 end
		C.ChannelingTicks[penanceID] = numTicks
	end
	K:RegisterEvent("PLAYER_LOGIN", updateTicks)
	K:RegisterEvent("PLAYER_TALENT_UPDATE", updateTicks)
end