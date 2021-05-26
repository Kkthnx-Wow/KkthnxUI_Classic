local _, C = unpack(select(2, ...))

local _G = _G

local GUILD = _G.GUILD
local NONE = _G.NONE
local PLAYER = _G.PLAYER

-- Actionbar
C["ActionBar"] = {
	["Cooldowns"] = true,
	["Count"] = true,
	["CustomBar"] = false,
	["CustomBarButtonSize"] = 34,
	["CustomBarNumButtons"] = 12,
	["CustomBarNumPerRow"] = 12,
	["DecimalCD"] = true,
	["DefaultButtonSize"] = 34,
	["Enable"] = true,
	["FadeBottomBar3"] = false,
	["FadeCustomBar"] = false,
	["FadeMicroBar"] = false,
	["FadePetBar"] = false,
	["FadeRightBar"] = false,
	["FadeRightBar2"] = false,
	["FadeStanceBar"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["MicroBar"] = true,
	["OverrideWA"] = false,
	["PetBar"] = true,
	["RightButtonSize"] = 34,
	["StanceBar"] = true,
	["StancePetSize"] = 30,
	["Layout"] = {
		["Options"] = {
			["Mainbar 2x3x4"] = "3x4 Boxed arrangement",
			["Mainbar 3x12"] = "Default Style",
			["Mainbar 4x12"] = "Four Stacked",
		},
		["Value"] = "Default Style"
	},
}

-- Announcements
C["Announcements"] = {
	["HealthAlert"] = false,
	["ItemAlert"] = false,
	["KillingBlow"] = false,
	["PullCountdown"] = true,
	["PvPEmote"] = false,
	["ResetInstance"] = true,
	["SaySapped"] = false,
	["Interrupt"] = false,
	["OwnInterrupt"] = true,
	["AlertInInstance"] = true,
	["BrokenSpell"] = false,

	-- ["Daily"] = false,
	-- ["IncludeDetails"] = true,
	-- ["Level"] = false,
	-- ["LevelHideOnMax"] = true,
	-- ["Paused"] = false,
	-- ["QuestNotifier"] = false,
	-- ["SuggestedGroup"] = true,
	-- ["Tag"] = true,
	-- ["Weekly"] = false,
}

-- Automation
C["Automation"] = {
	["AutoBlockStrangerInvites"] = false,
	["AutoCollapse"] = false,
	["AutoDeclineDuels"] = false,
	["AutoDisenchant"] = false,
	["AutoInvite"] = false,
	["AutoOpenItems"] = false,
	["AutoQuest"] = false,
	["AutoRelease"] = false,
	["AutoResurrect"] = false,
	["AutoResurrectThank"] = false,
	["AutoReward"] = false,
	["AutoSkipCinematic"] = false,
	["AutoSummon"] = false,
	["AutoTabBinder"] = false,
	["NoBadBuffs"] = false,
	["WhisperInvite"] = "inv+",
}

C["Inventory"] = {
	["AutoDeposit"] = false,
	["AutoSell"] = true,
	["BagBar"] = true,
	["BagBarMouseover"] = false,
	["BagsItemLevel"] = false,
	["BagsWidth"] = 12,
	["BankWidth"] = 14,
	["DeleteButton"] = true,
	["Enable"] = true,
	["FilterAmmo"] = false,
	["FilterCollection"] = true,
	["FilterConsumable"] = true,
	["FilterEquipment"] = true,
	["FilterFavourite"] = true,
	["FilterGoods"] = false,
	["FilterJunk"] = true,
	["FilterLegendary"] = true,
	["FilterQuest"] = true,
	["GatherEmpty"] = false,
	["IconSize"] = 34,
	["ItemFilter"] = true,
	["ShowNewItem"] = true,
	["SpecialBagsColor"] = false,
	["UpgradeIcon"] = true,
	["BagSortMode"] = {
		["Options"] = {
			["Forward"] = 0,
			["Backward"] = 1,
			[DISABLE] = 2,
		},
		["Value"] = 1
	},
	["AutoRepair"] = {
		["Options"] = {
			[NONE] = 0,
			[GUILD] = 1,
			[PLAYER] = 2,
		},
		["Value"] = 2
	},
}

-- Buffs & Debuffs
C["Auras"] = {
	["BuffSize"] = 30,
	["BuffsPerRow"] = 16,
	["DebuffSize"] = 34,
	["DebuffsPerRow"] = 16,
	["Enable"] = true,
	["Reminder"] = false,
	["ReverseBuffs"] = false,
	["ReverseDebuffs"] = false,
	["TotemSize"] = 32,
	["Totems"] = true,
	["VerticalTotems"] = true,
}

-- Chat
C["Chat"] = {
	["AllowFriends"] = true,
	["Background"] = true,
	["BlockAddonAlert"] = false,
	["BlockStranger"] = false,
	["ChatFilterList"] = "%*",
	["ChatFilterWhiteList"] = "",
	["ChatItemLevel"] = true,
	["ChatMenu"] = true,
	["Emojis"] = false,
	["Enable"] = true,
	["EnableFilter"] = true,
	["Fading"] = true,
	["FadingTimeVisible"] = 100,
	["FilterMatches"] = 1,
	["Freedom"] = true,
	["Height"] = 150,
	["Lock"] = true,
	["LogMax"] = 0,
	["LootIcons"] = false,
	["OldChatNames"] = false,
	["Sticky"] = false,
	["WhisperColor"] = true,
	["Width"] = 392,
	["TimestampFormat"] = {
		["Options"] = {
			["Disable"] = 1,
			["03:27 PM"] = 2,
			["03:27:32 PM"] = 3,
			["15:27"] = 4,
			["15:27:32"] = 5,
		},
		["Value"] = 1
	},
}

-- DataBars
C["DataBars"] = {
	["Enable"] = true,
	["ExperienceColor"] = {0, 0.4, 1, .8},
	["Height"] = 14,
	["HonorColor"] = {240/255, 114/255, 65/255},
	["MouseOver"] = false,
	["RestedColor"] = {1, 0, 1, 0.2},
	["TrackHonor"] = false,
	["Width"] = 180,
	["Text"] = {
		["Options"] = {
			["NONE"] = 0,
			["PERCENT"] = 1,
			["CURMAX"] = 2,
			["CURPERC"] = 3,
			["CUR"] = 4,
			["REM"] = 5,
			["CURREM"] = 6,
			["CURPERCREM"] = 7,
		},
		["Value"] = 1
	},
}

-- Datatext
C["DataText"] = {
	["Coords"] = false,
	["Friends"] = false,
	["Gold"] = false,
	["Guild"] = false,
	["GuildSortBy"] = 1,
	["GuildSortOrder"] = true,
	["HideText"] = true,
	["Latency"] = true,
	["Location"] = true,
	["System"] = true,
	["Time"] = true,
}

C["AuraWatch"] = {
	["Enable"] = true,
	["ClickThrough"] = false,
	["IconScale"] = 1,
	["DeprecatedAuras"] = false,
	["QuakeRing"] = false,
	["InternalCD"] = {},
	["AuraList"] = {
		["Switcher"] = {},
		["IgnoreSpells"] = {},
	},
}

-- General
C["General"] = {
	["AutoScale"] = true,
	["ColorTextures"] = false,
	["MissingTalentAlert"] = true,
	["MoveBlizzardFrames"] = false,
	["NoErrorFrame"] = false,
	["NoTutorialButtons"] = false,
	["TexturesColor"] = {1, 1, 1},
	["UIScale"] = 0.71111,
	["UseGlobal"] = false,
	["VersionCheck"] = true,
	["Welcome"] = true,
	["BorderStyle"] = {
		["Options"] = {
			["KkthnxUI"] = "KkthnxUI",
			["AzeriteUI"] = "AzeriteUI",
		},
		["Value"] = "KkthnxUI"
	},
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Standard: b/m/k"] = 1,
			["Asian: y/w"] = 2,
			["Full Digits"] = 3,
		},
		["Value"] = 1
	},
	["Profiles"] = {
		["Options"] = {},
	},
}

-- Loot
C["Loot"] = {
	["AutoConfirm"] = false,
	["AutoGreed"] = false,
	["Enable"] = true,
	["FastLoot"] = false,
	["GroupLoot"] = true,
}

-- Minimap
C["Minimap"] = {
	["Enable"] = true,
	["ShowRecycleBin"] = true,
	["Size"] = 180,
	["RecycleBinPosition"] = {
		["Options"] = {
			["BottomLeft"] = 1,
			["BottomRight"] = 2,
			["TopLeft"] = 3,
			["TopRight"] = 4,
		},
		["Value"] = "BottomLeft"
	},
	["LocationText"] = {
		["Options"] = {
			["Always Display"] = "SHOW",
			["Hide"] = "Hide",
			["Minimap Mouseover"] = "MOUSEOVER",
		},
		["Value"] = "MOUSEOVER"
	},
	["BlipTexture"] = {
		["Options"] = {
			["Blizzard"] = "Interface\\MiniMap\\ObjectIconsAtlas",
			["Charmed"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Blip-Charmed",
			["Nandini"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Blip-Nandini-New",
		},
		["Value"] = "Interface\\MiniMap\\ObjectIconsAtlas"
	},
}

-- Miscellaneous
C["Misc"] = {
	["AFKCamera"] = false,
	["AutoBubbles"] = false,
	["ColorPicker"] = false,
	["EasyMarking"] = false,
	["EnhancedFriends"] = false,
	["GemEnchantInfo"] = false,
	["HideBossEmote"] = false,
	["ItemLevel"] = false,
	["MouseTrail"] = false,
	["MouseTrailColor"] = {1, 1, 1, 0.6},
	["MuteSounds"] = false,
	["ShowWowHeadLinks"] = false,
	["SlotDurability"] = false,
	["TradeTabs"] = false,
	["ShowMarkerBar"] = {
		["Options"] = {
			["Grids"] = 1,
			["Horizontal"] = 2,
			["Vertical"] = 3,
			[DISABLE] = 4,
		},
		["Value"] = 4
	},
}

C["Nameplate"] = {
	["AuraSize"] = 26,
	["ClassAuras"] = true,
	["ClassIcon"] = false,
	["ColoredTarget"] = true,
	["CustomColor"] = {0, 0.8, 0.3},
	["CustomUnitColor"] = true,
	["CustomUnitList"] = "",
	["Distance"] = 42,
	["Enable"] = true,
	["ExecuteRatio"] = 0,
	["FriendlyCC"] = false,
	["FullHealth"] = false,
	["HealthTextSize"] = 13,
	["HostileCC"] = true,
	["InsecureColor"] = {1, 0, 0},
	["InsideView"] = true,
	["MaxAuras"] = 5,
	["MinAlpha"] = 1,
	["MinScale"] = 1,
	["NameOnly"] = true,
	["NameTextSize"] = 13,
	["NameplateClassPower"] = true,
	["OffTankColor"] = {0.2, 0.7, 0.5},
	["PPGCDTicker"] = true,
	["PPHeight"] = 5,
	["PPHideOOC"] = true,
	["PPIconSize"] = 32,
	["PPOnFire"] = false,
	["PPPHeight"] = 6,
	["PPPowerText"] = true,
	["PPWidth"] = 175,
	["PlateHeight"] = 13,
	["PlateWidth"] = 184,
	["PowerUnitList"] = "",
	["QuestIndicator"] = true,
	["SecureColor"] = {1, 0, 1},
	["ShowPlayerPlate"] = false,
	["Smooth"] = false,
	["TankMode"] = false,
	["TargetColor"] = {0, 0.6, 1},
	["TargetIndicatorColor"] = {1, 1, 0},
	["TransColor"] = {1, 0.8, 0},
	["VerticalSpacing"] = 0.7,
	["AuraFilter"] = {
		["Options"] = {
			["White & Black List"] = 1,
			["List & Player"] = 2,
			["List & Player & CCs"] = 3,
		},
		["Value"] = 3
	},
	["TargetIndicator"] = {
		["Options"] = {
			["Disable"] = 1,
			["Top Arrow"] = 2,
			["Right Arrow"] = 3,
			["Border Glow"] = 4,
			["Top Arrow + Glow"] = 5,
			["Right Arrow + Glow"] = 6,
		},
		["Value"] = 4
	},
	["TargetIndicatorTexture"] = {
		["Options"] = {
			["Blue Arrow 2".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow2:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\BlueArrow2]],
			["Blue Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\BlueArrow]],
			["Neon Blue Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonBlueArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonBlueArrow]],
			["Neon Green Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonGreenArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonGreenArrow]],
			["Neon Pink Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPinkArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonPinkArrow]],
			["Neon Red Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonRedArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonRedArrow]],
			["Purple Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\PurpleArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\PurpleArrow]],
			["Red Arrow 2".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow2.tga:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedArrow2]],
			["Red Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedArrow]],
			["Red Chevron Arrow".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedChevronArrow]],
			["Red Chevron Arrow2".."|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow2:0|t"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\RedChevronArrow2]],
		},
		["Value"] = [[Interface\AddOns\KkthnxUI\Media\Nameplates\NeonBlueArrow]]
	},
}

C["PulseCooldown"] = {
	["AnimScale"] = 1.5,
	["Enable"] = false,
	["HoldTime"] = 0.5,
	["Size"] = 75,
	["Sound"] = false,
	["Threshold"] = 3,
}

-- Skins
C["Skins"] = {
	["Bartender4"] = false,
	["BigWigs"] = false,
	["BlizzardFrames"] = true,
	["ChatBubbleAlpha"] = 0.9,
	["ChatBubbles"] = true,
	["ChocolateBar"] = false,
	["DeadlyBossMods"] = false,
	["Details"] = false,
	["Dominos"] = false,
	["Hekili"] = false,
	["RareScanner"] = false,
	["Skada"] = false,
	["Spy"] = false,
	["TalkingHeadBackdrop"] = true,
	["TellMeWhen"] = false,
	["TinyInspect"] = false,
	["TitanPanel"] = false,
	["WeakAuras"] = false,
}

-- Tooltip
C["Tooltip"] = {
	["ClassColor"] = false,
	["CombatHide"] = false,
	["Cursor"] = false,
	["FactionIcon"] = false,
	["HideJunkGuild"] = true,
	["HideRank"] = true,
	["HideRealm"] = true,
	["HideTitle"] = true,
	["Icons"] = true,
	["ShowIDs"] = false,
	["TargetBy"] = true,
}

-- Fonts
C["UIFonts"] = {
	["ActionBarsFonts"] = "KkthnxUI Outline",
	["AuraFonts"] = "KkthnxUI Outline",
	["ChatFonts"] = "KkthnxUI",
	["DataBarsFonts"] = "KkthnxUI",
	["DataTextFonts"] = "KkthnxUI",
	["FilgerFonts"] = "KkthnxUI Outline",
	["GeneralFonts"] = "KkthnxUI",
	["InventoryFonts"] = "KkthnxUI Outline",
	["MinimapFonts"] = "KkthnxUI",
	["NameplateFonts"] = "KkthnxUI",
	["QuestTrackerFonts"] = "KkthnxUI",
	["SkinFonts"] = "KkthnxUI",
	["TooltipFonts"] = "KkthnxUI",
	["UnitframeFonts"] = "KkthnxUI",
	-- Font Sizes Will Go Here (Not Sure How Much I Care About Improving This)
	["QuestFontSize"] = 11,
}

-- Textures
C["UITextures"] = {
	["DataBarsTexture"] = "KkthnxUI",
	["FilgerTextures"] = "KkthnxUI",
	["GeneralTextures"] = "KkthnxUI",
	["HealPredictionTextures"] = "KkthnxUI",
	["LootTextures"] = "KkthnxUI",
	["NameplateTextures"] = "KkthnxUI",
	["QuestTrackerTexture"] = "KkthnxUI",
	["SkinTextures"] = "KkthnxUI",
	["TooltipTextures"] = "KkthnxUI",
	["UnitframeTextures"] = "KkthnxUI",
}

-- Unitframe
C["Unitframe"] = {
	["AdditionalPower"] = false,
	["AutoAttack"] = true,
	["CastClassColor"] = false,
	["CastReactionColor"] = false,
	["CastbarLatency"] = true,
	["ClassResources"] = true,
	["CombatFade"] = false,
	["CombatText"] = false,
	["DebuffHighlight"] = true,
	["Enable"] = true,
	["FCTOverHealing"] = false,
	["FocusFrameHeight"] = 40,
	["FocusFrameWidth"] = 210,
	["FocusPower"] = true,
	["FocusTargetFrameHeight"] = 20,
	["FocusTargetFrameWidth"] = 110,
	["FocusTargetPower"] = true,
	["GlobalCooldown"] = true,
	["HidePetLevel"] = true,
	["HidePetName"] = true,
	["HideTargetOfTargetLevel"] = false,
	["HideTargetOfTargetName"] = false,
	["HideTargetofTarget"] = false,
	["HotsDots"] = true,
	["OnlyShowPlayerDebuff"] = false,
	["PetCombatText"] = true,
	["PetFrameHeight"] = 20,
	["PetFrameWidth"] = 110,
	["PetPower"] = true,
	["PlayerBuffs"] = false,
	["PlayerCastbar"] = true,
	["PlayerCastbarHeight"] = 24,
	["PlayerCastbarWidth"] = 260,
	["PlayerDeBuffs"] = false,
	["PlayerFrameHeight"] = 44,
	["PlayerFrameWidth"] = 218,
	["PlayerPower"] = true,
	["PlayerPowerPrediction"] = true,
	["PvPIndicator"] = true,
	["ResurrectSound"] = false,
	["ShowHealPrediction"] = true,
	["ShowPlayerLevel"] = true,
	["ShowPlayerName"] = false,
	["Smooth"] = false,
	["Stagger"] = true,
	["Swingbar"] = false,
	["SwingbarTimer"] = false,
	["TargetBuffs"] = true,
	["TargetBuffsPerRow"] = 6,
	["TargetCastbar"] = true,
	["TargetCastbarHeight"] = 30,
	["TargetCastbarWidth"] = 260,
	["TargetDebuffs"] = true,
	["TargetDebuffsPerRow"] = 5,
	["TargetFrameHeight"] = 44,
	["TargetFrameWidth"] = 218,
	["TargetPower"] = true,
	["TargetTargetFrameHeight"] = 20,
	["TargetTargetFrameWidth"] = 110,
	["TargetTargetPower"] = true,
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class"
	},
	["PortraitStyle"] = {
		["Options"] = {
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits",
			["No Portraits"] = "NoPortraits"
		},
		["Value"] = "DefaultPortraits"
	},
}

C["Party"] = {
	["Castbars"] = false,
	["Enable"] = true,
	["PortraitTimers"] = false,
	["ShowBuffs"] = true,
	["ShowHealPrediction"] = true,
	["ShowPartySolo"] = false,
	["ShowPet"] = false,
	["ShowPlayer"] = true,
	["Smooth"] = false,
	["TargetHighlight"] = false,
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class"
	},
}

C["Boss"] = {
	["Castbars"] = true,
	["Enable"] = true,
	["Smooth"] = false,
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class"
	},
}

C["Arena"] = {
	["Castbars"] = true,
	["Enable"] = true,
	["Height"] = 34,
	["Power"] = true,
	["Smooth"] = false,
	["Width"] = 174,
	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class"
	},
}

-- Raidframe
C["Raid"] = {
	-- ["SpecRaidPos"] = false,
	["Enable"] = true,
	["Height"] = 40,
	["HorizonRaid"] = false,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["NumGroups"] = 6,
	["RaidUtility"] = true,
	["ReverseRaid"] = false,
	["ShowHealPrediction"] = true,
	["ShowNotHereTimer"] = true,
	["ShowRaidSolo"] = false,
	["ShowTeamIndex"] = false,
	["Smooth"] = false,
	["TargetHighlight"] = false,
	["Width"] = 66,

	["DebuffWatchScale"] = 1,
	["DebuffWatch"] = true,
	["DesaturateNonPlayerBuffs"] = false,
	["RaidBuffs"] = {
		["Options"] = {
			["Hide"] = "Hide",
			["Only my buffs"] = "Self",
			["Only castable buffs"] = "Castable",
			["All buffs"] = "All",
		},
		["Value"] = "Self",
	},
	["AuraTrack"] = true,
	["AuraTrackIcons"] = true,
	["AuraTrackSpellTextures"] = true,
	["AuraTrackThickness"] = 5,


	["HealthbarColor"] = {
		["Options"] = {
			["Dark"] = "Dark",
			["Value"] = "Value",
			["Class"] = "Class",
		},
		["Value"] = "Class"
	},
	["HealthFormat"] = {
		["Options"] = {
			["Disable HP"] = 1,
			["Health Percentage"] = 2,
			["Health Remaining"] = 3,
			["Health Lost"] = 4,
		},
		["Value"] = 1
	},
}

-- Worldmap
C["WorldMap"] = {
	["AlphaWhenMoving"] = 0.35,
	["Coordinates"] = true,
	["FadeWhenMoving"] = true,
	["MapRevealGlow"] = true,
	["MapRevealGlowColor"] = {0.4, 0.61, 1},
	["SmallWorldMap"] = true,
}