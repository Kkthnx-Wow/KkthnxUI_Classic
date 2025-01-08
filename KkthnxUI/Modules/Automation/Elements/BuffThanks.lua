local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local thankCooldown = {} -- Tracks last thank time for each caster and spellID
local currentAuras = {}
local previousAuras = {}
local globalThankCooldown = 0

local spellList = { 1126, 1459, 1243, 19740, 19742, 20217, 5697 }
local emoteList = { "THANK", "BOW", "SALUTE" }
local buffsToThank = {}

for _, spellID in ipairs(spellList) do
	local spellName = GetSpellInfo(spellID)
	if spellName then
		buffsToThank[spellName] = true
	end
end

local function ClearTable(tbl)
	for k in pairs(tbl) do
		tbl[k] = nil
	end
end

local function GetRandomEmote()
	return emoteList[math.random(1, #emoteList)]
end

local function PruneOldEntries()
	local currentTime = GetTime()
	for caster, spells in pairs(thankCooldown) do
		for spellID, timestamp in pairs(spells) do
			if currentTime - timestamp > 3600 then
				thankCooldown[caster][spellID] = nil
			end
		end
		if not next(thankCooldown[caster]) then
			thankCooldown[caster] = nil
		end
	end
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
	local currentTime = GetTime()
	if currentTime - globalThankCooldown < 2 then
		return
	end -- Global cooldown
	thankCooldown[caster] = thankCooldown[caster] or {}
	if thankCooldown[caster][spellID] and (currentTime - thankCooldown[caster][spellID] < 5) then
		return
	end

	thankCooldown[caster][spellID] = currentTime

	local delay = math.random(1, 20) / 10
	local emote = GetRandomEmote()
	C_Timer.After(delay, function()
		DoEmote(emote, caster)
	end)

	globalThankCooldown = currentTime
end

local function CompareAndHandleAuras()
	for spellID, data in pairs(currentAuras) do
		if not previousAuras[spellID] then
			local name, caster = data.name, data.caster
			if name and caster and buffsToThank[name] and caster ~= UnitName("player") then
				HandleNewBuff(spellID, caster)
			end
		end
	end
end

local function HandlePlayerEnteringWorld()
	PruneOldEntries()
	CacheAuras(previousAuras)
	CacheAuras(currentAuras)
end

local function HandleUnitAura(_, unit)
	if unit == "player" then
		for spellID, data in pairs(currentAuras) do
			previousAuras[spellID] = data
		end
		CacheAuras(currentAuras)
		CompareAndHandleAuras()
	end
end

function Module:CreateAutoBuffThanks()
	if C["Automation"].BuffThanks then
		K:RegisterEvent("PLAYER_ENTERING_WORLD", HandlePlayerEnteringWorld)
		K:RegisterEvent("UNIT_AURA", HandleUnitAura, "player")
	else
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", HandlePlayerEnteringWorld)
		K:UnregisterEvent("UNIT_AURA", HandleUnitAura, "player")
	end
end
