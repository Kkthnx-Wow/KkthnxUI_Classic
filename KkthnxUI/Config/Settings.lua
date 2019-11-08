local K, C = unpack(select(2, ...))

local _G = _G

local DAMAGE = _G.DAMAGE
local DISABLE = _G.DISABLE
local HEALER = _G.HEALER
local IsAddOnLoaded = _G.IsAddOnLoaded

-- Actionbar
C["ActionBar"] = {
	["Cooldowns"] = true,
	["Count"] = true,
	["DecimalCD"] = true,
	["DefaultButtonSize"] = 34,
	["DisableStancePages"] = K.Class == "DRUID",
	["Enable"] = true,
	["EquipBorder"] = true,
	["FadeRightBar"] = false,
	["FadeRightBar2"] = false,
	["HideHighlight"] = false,
	["Hotkey"] = true,
	["Macro"] = true,
	["MicroBar"] = true,
	["MicroBarMouseover"] = false,
	["OverrideWA"] = false,
	["RightButtonSize"] = 34,
	["StancePetSize"] = 28,
	["Layout"] = {
		["Options"] = {
			["Mainbar 2x3x4"] = "3x4 Boxed arrangement"
			["Mainbar 3x12"] = "Default Style",
			["Mainbar 4x12"] = "Four Stacked",
		},
		["Value"] = "Default Style"
	},
}

-- Announcements
C["Announcements"] = {
	["PullCountdown"] = true,
	["SaySapped"] = false,
	["Interrupt"] = {
		["Options"] = {
			["Disabled"] = "NONE",
			["Emote Chat"] = "EMOTE",
			["Party Chat"] = "PARTY",
			["Raid Chat Only"] = "RAID_ONLY",
			["Raid Chat"] = "RAID",
			["Say Chat"] = "SAY"
		},
		["Value"] = "PARTY"
	},
}

-- Automation
C["Automation"] = {
	["AutoBubbles"] = true,
	["AutoDisenchant"] = false,
	["AutoInvite"] = false,
	["AutoQuest"] = false,
	["AutoRelease"] = false,
	["AutoResurrect"] = false,
	["AutoResurrectThank"] = false,
	["AutoReward"] = false,
	["AutoTabBinder"] = false,
	["BuffThanks"] = false,
	["DeclinePvPDuel"] = false,
	["WhisperInvite"] = "inv",
}

C["Inventory"] = {
	-- ["ItemSetFilter"] = false,

	["AutoRepair"] = true,
	["AutoSell"] = true,
	["BagBar"] = true,
	["BagBarMouseover"] = false,
	["BagsWidth"] = 12,
	["BagsiLvl"] = true,
	["BankWidth"] = 14,
	["DeleteButton"] = true,
	["Enable"] = true,
	["GatherEmpty"] = false,
	["IconSize"] = 34,
	["ItemFilter"] = true,
	["QuestItemFilter"] = false,
	["SpecialBagsColor"] = true,
	["TradeGoodsFilter"] = false,
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
}

-- Chat
C["Chat"] = {
	["Background"] = false,
	["BackgroundAlpha"] = 0.25,
	["ChatItemLevel"] = true,
	["Enable"] = true,
	["EnableFilter"] = true,
	["Fading"] = true,
	["FadingTimeFading"] = 3,
	["FadingTimeVisible"] = 20,
	["Height"] = 149,
	["ScrollByX"] = 3,
	["ShortenChannelNames"] = true,
	["TabsMouseover"] = true,
	["WhisperSound"] = true,
	["Width"] = 410
}

-- DataBars
C["DataBars"] = {
	["Enable"] = true,
	["ExperienceColor"] = {0.6, 0.3, 0.8, 1.0},
	["Height"] = 14,
	["MouseOver"] = false,
	["RestedColor"] = {0.2, 0.5, 1.0, 1.0},
	["Text"] = true,
	["Width"] = 180,
}

-- Datatext
C["DataText"] = {
	["System"] = true,
	["Time"] = true,
}

C["Filger"] = {
	["BuffSize"] = 36,
	["CooldownSize"] = 30,
	["DisableCD"] = false,
	["DisablePvP"] = false,
	["Expiration"] = false,
	["Enable"] = false,
	["MaxTestIcon"] = 5,
	["PvPSize"] = 60,
	["ShowTooltip"] = false,
	["TestMode"] = false,
}

-- General
C["General"] = {
	["AutoScale"] = true,
	["ColorTextures"] = false,
	["FixGarbageCollect"] = true,
	["FontSize"] = 12,
	["HideErrors"] = true,
	["LagTolerance"] = false,
	["MoveBlizzardFrames"] = false,
	["ReplaceBlizzardFonts"] = true,
	["TexturesColor"] = {0.9, 0.9, 0.9},
	["UIScale"] = 0.71111,
	["Welcome"] = true,
	["NumberPrefixStyle"] = {
		["Options"] = {
			["Standard: b/m/k"] = 1,
			["Asian: y/w"] = 2,
			["Full Digits"] = 3,
		},
		["Value"] = 1
	},
	["PortraitStyle"] = {
		["Options"] = {
			["3D Portraits"] = "ThreeDPortraits",
			["Class Portraits"] = "ClassPortraits",
			["New Class Portraits"] = "NewClassPortraits",
			["Default Portraits"] = "DefaultPortraits"
		},
		["Value"] = "DefaultPortraits"
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
	["ResetZoom"] = false,
	["ResetZoomTime"] = 4,
	["ShowRecycleBin"] = true,
	["Size"] = 180,
	["BlipTexture"] = {
		["Options"] = {
			["Nandini"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Classic-Nandini-New",
			["Charmed"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Classic-Charmed",
			["Blizzard"] = "Interface\\MiniMap\\ObjectIconsAtlas",
		},
		["Value"] = "Interface\\AddOns\\KkthnxUI\\Media\\MiniMap\\Classic-Charmed"
	},
}

-- Miscellaneous
C["Misc"] = {
	-- ["KillingBlow"] = false, -- Not Ready

	["AFKCamera"] = false,
	["AutoDismountStand"] = true,
	["ColorPicker"] = false,
	["EnhancedFriends"] = false,
	["EnhancedMenu"] = true,
	["GemEnchantInfo"] = false,
	["ImprovedProfessionWindow"] = true,
	["ImprovedQuestLog"] = true,
	["ImprovedTrainerWindow"] = true,
	["ItemLevel"] = false,
	["PvPEmote"] = false,
	["ShowHelmCloak"] = false,
	["ShowWowHeadLinks"] = false,
	["SlotDurability"] = false,
	["TradeTabs"] = false,
}

C["Nameplates"] = {
	["Clamp"] = false,
	["ClassIcons"] = false,
	["Enable"] = true,
	["HealthValue"] = true,
	["Height"] = 13,
	["NonTargetAlpha"] = 0.35,
	["OverlapH"] = 1.2,
	["OverlapV"] = 1.2,
	["QuestInfo"] = true,
	["SelectedScale"] = 1.2,
	["ShowFullHealth"] = true,
	["Smooth"] = false,
	["TrackAuras"] = true,
	["Width"] = 150,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
    },
	["TargetArrowMark"] = {
		["Options"] = {
			["None"] = "NONE",
			["Left / Right"] = "LEFT/RIGHT",
			["Top"] = "TOP",
		},
		["Value"] = "LEFT/RIGHT"
	},
	["ShowEnemyCombat"] = {
		["Options"] = {
			[DISABLE] = "DISABLED",
			["Toggle On In Combat"] = "TOGGLE_ON",
			["Toggle Off In Combat"] = "TOGGLE_OFF",

		},
		["Value"] = "DISABLED"
	},
	["ShowFriendlyCombat"] = {
		["Options"] = {
			[DISABLE] = "DISABLED",
			["Toggle On In Combat"] = "TOGGLE_ON",
			["Toggle Off In Combat"] = "TOGGLE_OFF",

		},
		["Value"] = "DISABLED"
	}
}

-- Skins
C["Skins"] = {
	["ChatBubbles"] = true,
	["DBM"] = false,
	["Details"] = false,
	["Skada"] = false,
	["TitanClassic"] = false,
	["WeakAuras"] = false,
	["Spy"] = false,
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
	["SpecLevelByShift"] = true,
	["TargetBy"] = true,
}

-- Fonts
C["UIFonts"] = {
	["ActionBarsFonts"] = "KkthnxUI Outline",
	["AuraFonts"] = "KkthnxUI Outline",
	["ChatFonts"] = "KkthnxUI",
	["DataBarsFonts"] = "KkthnxUI",
	["DataTextFonts"] = "KkthnxUI",
	["FilgerFonts"] = "KkthnxUI",
	["GeneralFonts"] = "KkthnxUI",
	["InventoryFonts"] = "KkthnxUI Outline",
	["MinimapFonts"] = "KkthnxUI",
	["NameplateFonts"] = "KkthnxUI",
	["QuestTrackerFonts"] = "KkthnxUI",
	["SkinFonts"] = "KkthnxUI",
	["TooltipFonts"] = "KkthnxUI",
	["UnitframeFonts"] = "KkthnxUI",
}

-- Textures
C["UITextures"] = {
	["DataBarsTexture"] = "KkthnxUI",
	["FilgerTextures"] = "KkthnxUI",
	["GeneralTextures"] = "KkthnxUI",
	["HealPredictionTextures"] = "Blank",
	["LootTextures"] = "KkthnxUI",
	["NameplateTextures"] = "KkthnxUI",
	["QuestTrackerTexture"] = "KkthnxUI",
	["SkinTextures"] = "KkthnxUI",
	["TooltipTextures"] = "KkthnxUI",
	["UnitframeTextures"] = "KkthnxUI",
}

-- Unitframe
C["Unitframe"] = {
	-- ["TotemBar"] = true,

	["AdditionalPower"] = K.Class == "DRUID",
	["CastClassColor"] = true,
	["CastReactionColor"] = true,
	["CastbarLatency"] = true,
	["Castbars"] = true,
	["CombatFade"] = false,
	["CombatText"] = false,
	["ComboPoints"] = K.Class == "DRUID" or K.Class == "ROGUE",
	["DebuffHighlight"] = true,
	["DebuffsOnTop"] = true,
	["Enable"] = true,
	["EnergyTick"] = true,
	["GlobalCooldown"] = false,
	["HideTargetofTarget"] = false,
	["OnlyShowPlayerDebuff"] = false,
	["PlayerAuraBars"] = false,
	["PlayerBuffs"] = false,
	["PlayerCastbarHeight"] = 24,
	["PlayerCastbarWidth"] = 260,
	["PortraitTimers"] = false,
	["PvPIndicator"] = true,
	["ShowHealPrediction"] = true,
	["ShowPetHappinessIcon"] = true,
	["ShowPlayerLevel"] = true,
	["ShowPlayerName"] = false,
	["Smooth"] = false,
	["Swingbar"] = false,
	["SwingbarTimer"] = false,
	["TargetAuraBars"] = false,
	["TargetCastbarHeight"] = 24,
	["TargetCastbarWidth"] = 260,
	["Totems"] = K.Class == "SHAMAN",
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
	},
}

C["Party"] = {
	["Castbars"] = false,
	["Enable"] = true,
	["PortraitTimers"] = false,
	["ShowBuffs"] = true,
	["ShowHealPrediction"] = true,
	["ShowPets"] = true,
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

-- Raidframe
C["Raid"] = {
	["AuraDebuffIconSize"] = 22,
	["AuraWatch"] = true,
	["AuraWatchIconSize"] = 11,
	["AuraWatchTexture"] = true,
	["DeficitThreshold"] = .95,
	["Enable"] = true,
	["Height"] = 40,
	["MainTankFrames"] = true,
	["ManabarShow"] = false,
	["MaxUnitPerColumn"] = 10,
	["RaidUtility"] = true,
	["ShowNotHereTimer"] = true,
	["Smooth"] = false,
	["TargetHighlight"] = false,
	["Width"] = 66,
	["HealthbarColor"] = {
        ["Options"] = {
            ["Dark"] = "Dark",
            ["Value"] = "Value",
            ["Class"] = "Class",
        },
        ["Value"] = "Class"
    },
	["RaidLayout"] = {
		["Options"] = {
			[DAMAGE] = "Damage",
			[HEALER] = "Healer"
		},
		["Value"] = "Damage"
	},
	["GroupBy"] = {
		["Options"] = {
			["Group"] = "GROUP",
			["Class"] = "CLASS",
			["Role"] = "ROLE"
		},
		["Value"] = "GROUP"
	},
	["HealthFormat"] = {
        ["Options"] = {
			["DisableRaidHP"] = 1,
			["RaidHPPercent"] = 2,
			["RaidHPCurrent"] = 3,
			["RaidHPLost"] = 4,
        },
        ["Value"] = 1
    },
}

if not IsAddOnLoaded("QuestNotifier") then
	C["QuestNotifier"] = {
		["Enable"] = IsAddOnLoaded("QuestNotifier") and false,
		["OnlyCompleteRing"] = false,
		["QuestProgress"] = false,
	}
end

-- Worldmap
C["WorldMap"] = {
	["Coordinates"] = true,
	["MapFader"] = true,
	["MapReveal"] = false,
	["MapScale"] = 0.7,
	["PartyIconSize"] = 14,
	["PlayerIconSize"] = 24,
	["WorldMapIcons"] = false,
}