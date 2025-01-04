local C = KkthnxUI[2]

C.SpellReminderBuffs = {
	MAGE = {
		{
			spells = { -- Arcane Intellect
				[1459] = true,
				[8096] = true, -- Scroll of Intellect
				[23028] = true, -- Arcane Brilliance
				[11396] = true, -- Greater Arcane Brilliance
			},
			depend = 1459,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { -- Armor Spells
				[168] = true, -- Frost Armor
				[7302] = true, -- Ice Armor
				[6117] = true, -- Mage Armor
				[428741] = true, -- Molten Armor
			},
			depend = 168,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	PRIEST = {
		{
			spells = { -- Power Word: Fortitude
				[1243] = true,
				[8099] = true, -- Scroll of Stamina
				[21562] = true, -- Prayer of Fortitude
			},
			depend = 1243,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { -- Inner Fire
				[588] = true,
			},
			depend = 588,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	DRUID = {
		{
			spells = { -- Mark of the Wild
				[1126] = true,
				[21849] = true, -- Gift of the Wild
			},
			depend = 1126,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { -- Thorns
				[467] = true,
			},
			depend = 467,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	WARRIOR = {
		{
			spells = { -- Battle Shout
				[6673] = true,
				[25289] = true,
			},
			depends = { 6673, 5242, 6192, 11549, 11550, 11551, 25289 },
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	HUNTER = {
		{
			spells = { -- Aspect of the Hawk
				[13165] = true,
			},
			depend = 13165,
			combat = true,
			instance = true,
			pvp = true,
		},
		{
			spells = { -- Trueshot Aura
				[20906] = true,
			},
			depend = 20906,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
	WARLOCK = {
		{
			spells = { -- Armor Spells
				[706] = true, -- Demon Armor
				[687] = true, -- Demon Skin
			},
			depend = 706,
			combat = true,
			instance = true,
			pvp = true,
		},
	},
}
