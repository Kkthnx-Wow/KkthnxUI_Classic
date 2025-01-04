local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Variables
local lastThanked = {}
local currentAuras = {}
local previousAuras = {}

-- Buffs List
local spellList = {
	-- Druid
	1126, -- Mark of the Wild

	-- Mage
	1459, -- Arcane Intellect

	-- Priest
	1243, -- Power Word: Fortitude

	-- Paladin
	19740, -- Blessing of Might
	19742, -- Blessing of Wisdom
	20217, -- Blessing of Kings

	-- Warlock
	5697, -- Unending Breath
}

-- List of targeted emotes for thanking
local emoteList = {
	"THANK",
	"BOW",
	"SALUTE",
	"CLAP",
	"CHEER",
}

-- Pick a random targeted emote from the list
local function GetRandomTargetedEmote()
	return emoteList[math.random(1, #emoteList)]
end

-- Credits
-- The caching and comparison methods, as well as the performance optimization for clearing tables, were inspired by Goldpaw's ideas.
-- Big thanks for these insights, which make this addon efficient and performant!

-- Helper Functions
local function BuildBuffsToThank(spellList)
	local buffsToThank = {}
	for _, spellID in ipairs(spellList) do
		local spellName = GetSpellInfo(spellID)
		if spellName then
			buffsToThank[spellName] = true
		end
	end
	return buffsToThank
end

local buffsToThank = BuildBuffsToThank(spellList)

-- Clear a table by setting all keys to nil
local function ClearTable(tbl)
	for k in pairs(tbl) do
		tbl[k] = nil
	end
end

-- Cache current player auras into a table
local function CacheAuras(targetTable)
	ClearTable(targetTable) -- Use optimized table clearing
	for i = 1, 40 do
		local name, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
		if not name then
			break
		end
		targetTable[spellID] = true
	end
end

-- Compare current and previous auras and handle new buffs
local function CompareAndHandleAuras()
	for spellID, _ in pairs(currentAuras) do
		if not previousAuras[spellID] then
			-- Handle new buffs only
			local name, _, _, _, _, _, _, caster = UnitBuff("player", spellID)
			if name and buffsToThank[name] and caster and caster ~= UnitName("player") then
				local currentTime = GetTime()

				if not lastThanked[caster] or (currentTime - lastThanked[caster]) > 60 then
					local delay = math.random(1, 20) / 10 -- Random delay between 1 and 2 seconds
					local randomEmote = GetRandomTargetedEmote() -- Get a random targeted emote

					C_Timer.After(delay, function()
						DoEmote(randomEmote, caster)
					end)

					lastThanked[caster] = currentTime
					print(randomEmote .. ":", caster, "for buff", name, "(Spell ID:", spellID, ")")
				end
			end
		end
	end
end

-- Handle Login, Reload, or Zoning
local function HandlePlayerEnteringWorld()
	-- Cache auras on login or zoning
	CacheAuras(previousAuras)
	print("Cached auras on PLAYER_ENTERING_WORLD.")
end

-- Handle Aura Changes
local function HandleUnitAura(_, unit)
	if unit == "player" then
		-- Cache current auras, compare, and process
		CacheAuras(currentAuras)
		CompareAndHandleAuras()

		-- Swap tables to avoid re-creating them
		ClearTable(previousAuras)
		for k, v in pairs(currentAuras) do
			previousAuras[k] = v
		end
	end
end

-- Initialization
function Module:CreateAutoBuffThanks()
	if C["Automation"].BuffThanks then
		-- Register Events
		K:RegisterEvent("PLAYER_ENTERING_WORLD", HandlePlayerEnteringWorld)
		K:RegisterEvent("UNIT_AURA", HandleUnitAura, "player")
	else
		-- Unregister Events
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", HandlePlayerEnteringWorld)
		K:UnregisterEvent("UNIT_AURA", HandleUnitAura, "player")
	end
end
