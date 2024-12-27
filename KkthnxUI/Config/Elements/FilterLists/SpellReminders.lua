local C = KkthnxUI[2]

C.SpellReminderBuffs = {
	ITEMS = {
		{
			itemID = 190384, -- 9.0 Permanent Attribute Rune
			spells = {
				[393438] = true, -- Dragon Empowerment Rune itemID 201325
				[367405] = true, -- Permanent Rune buff
			},
			instance = true,
			disable = true, -- Disabled until a new rune comes out
		},
		{
			itemID = 194307, -- Nest Guardian's Promise
			spells = {
				[394457] = true,
			},
			equip = true,
			instance = true,
			inGroup = true,
		},
		--[=[
		{   itemID = 178742, -- Bottled Toxin Trinket
			spells = {
				[345545] = true,
			},
			equip = true,
			instance = true,
			combat = true,
		},
		{   itemID = 190958, -- Ultimate Arcanum
			spells = {
				[368512] = true,
			},
			equip = true,
			instance = true,
			inGroup = true,
		},
		]=]
	},
	MAGE = {
		{
			spells = { -- Arcane Familiar
				[210126] = true,
			},
			depend = 205022,
			spec = 1,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { -- Arcane Intellect
				[1459] = true,
			},
			depend = 1459,
			instance = true,
		},
	},
	PRIEST = {
		{
			spells = { -- Power Word: Fortitude
				[21562] = true,
			},
			depend = 21562,
			instance = true,
		},
	},
	WARRIOR = {
		{
			spells = { -- Battle Shout
				[6673] = true,
			},
			depend = 6673,
			instance = true,
		},
	},
	SHAMAN = {
		{
			spells = {
				[192106] = true, -- Lightning Shield
				[974] = true, -- Earth Shield
				[52127] = true, -- Water Shield
			},
			depend = 192106,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = {
				[33757] = true, -- Windfury Weapon
			},
			depend = 33757,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 1,
			spec = 2,
		},
		{
			spells = {
				[318038] = true, -- Flametongue Weapon
			},
			depend = 318038,
			combat = true,
			instance = true,
			pvp = true,
			weaponIndex = 2,
			spec = 2,
		},
	},
	ROGUE = {
		{
			spells = { -- Damage Poisons
				[2823] = true, -- Deadly Poison
				[8679] = true, -- Wound Poison
				[315584] = true, -- Instant Poison
				[381664] = true, -- Enhanced Poison
			},
			texture = 132273,
			depend = 315584,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { -- Utility Poisons
				[3408] = true, -- Crippling Poison
				[5761] = true, -- Numbing Poison
				[381637] = true, -- Withering Poison
			},
			depend = 3408,
			pvp = true,
		},
	},
	EVOKER = {
		{
			spells = { -- Blessing of the Bronze Dragonflight
				[381748] = true,
			},
			depend = 364342,
			instance = true,
		},
	},
	DRUID = {
		{
			spells = { -- Mark of the Wild
				[1126] = true,
			},
			depend = 1126,
			instance = true,
		},
	},
}
