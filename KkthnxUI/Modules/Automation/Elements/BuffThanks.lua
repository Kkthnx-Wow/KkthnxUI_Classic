local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Variables
local lastThanked = {} -- Tracks buffs we've already thanked for
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

-- Emote List for Thanking
local emoteList = { "THANK", "BOW", "SALUTE" }

-- Prebuilt Buffs to Thank
local buffsToThank = {}
for _, spellID in ipairs(spellList) do
	local spellName = GetSpellInfo(spellID)
	if spellName then
		buffsToThank[spellName] = true
	end
end

-- Utility Functions
local function ClearTable(tbl)
	for k in pairs(tbl) do
		tbl[k] = nil
	end
end

local function GetRandomEmote()
	return emoteList[math.random(1, #emoteList)]
end

local function CacheAuras(targetTable)
	ClearTable(targetTable)
	for i = 1, 40 do
		local name, _, _, _, _, _, caster, _, _, spellID = UnitBuff("player", i)
		if not name then
			break
		end
		targetTable[spellID] = { name = name, caster = caster }
	end
end

local function HandleNewBuff(spellID, caster)
	if not lastThanked[spellID] or lastThanked[spellID] ~= caster then
		lastThanked[spellID] = caster

		local delay = math.random(1, 20) / 10 -- Random delay between 1 and 2 seconds
		local emote = GetRandomEmote()

		C_Timer.After(delay, function()
			DoEmote(emote, caster)
		end)
	end
end

-- Core Logic for Comparing Buffs
local function CompareAndHandleAuras()
	for spellID, data in pairs(currentAuras) do
		if not previousAuras[spellID] then
			-- Buff is new
			local name = data.name
			local caster = data.caster

			if name and caster and buffsToThank[name] and caster ~= UnitName("player") then
				HandleNewBuff(spellID, caster)
			end
		end
	end
end

-- Event Handlers
local function HandlePlayerEnteringWorld()
	ClearTable(previousAuras)
	CacheAuras(previousAuras) -- Cache current buffs as previous
	ClearTable(lastThanked) -- Clear thanked buffs to reset state for zoning
end

local function HandleUnitAura(_, unit)
	if unit == "player" then
		CacheAuras(currentAuras)
		CompareAndHandleAuras()

		-- Update previous auras
		ClearTable(previousAuras)
		for spellID, data in pairs(currentAuras) do
			previousAuras[spellID] = data
		end
	end
end

-- Initialization
function Module:CreateAutoBuffThanks()
	if C["Automation"].BuffThanks then
		K:RegisterEvent("PLAYER_ENTERING_WORLD", HandlePlayerEnteringWorld)
		K:RegisterEvent("UNIT_AURA", HandleUnitAura, "player")
	else
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", HandlePlayerEnteringWorld)
		K:UnregisterEvent("UNIT_AURA", HandleUnitAura, "player")
	end
end
