local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Tracks last thank time for each caster and spellID combination
local thankCooldown = {}
local currentAuras = {}
local shouldThank = true

local spellList = { 1126, 1459, 1243, 19740, 19742, 20217, 5697 }
local emoteList = { "THANK", "BOW", "SALUTE" }
local buffsToThank = {}

-- Debug mode toggle
local debugMode = false
local function DebugPrint(msg)
	if debugMode then
		print("|cFFFF0000[BuffThanks Debug]|r " .. msg)
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

-- Helper function to generate a unique key for cooldown tracking
local function GetCooldownKey(caster, spellID)
	return caster .. ":" .. spellID
end

local function UpdateBuffsToThank()
	ClearTable(buffsToThank)
	for _, spellID in ipairs(spellList) do
		local spellName = GetSpellInfo(spellID)
		if spellName then
			buffsToThank[spellName] = true
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
		if buffsToThank[name] then
			targetTable[spellID] = { name = name, caster = caster }
		end
	end
end

local function HandleNewBuff(spellID, caster)
	if not shouldThank then
		return
	end

	local key = GetCooldownKey(caster, spellID)
	if thankCooldown[key] then
		return -- Already thanked for this buff from this caster
	end

	thankCooldown[key] = true -- Mark as thanked

	local emote = GetRandomEmote()
	DebugPrint("Thanking " .. (caster or "Unknown") .. " for " .. GetSpellInfo(spellID))
	DoEmote(emote, caster)
end

local function HandleUnitAura(_, unit)
	if unit == "player" then
		local newAuras = {}
		CacheAuras(newAuras)
		for spellID, data in pairs(newAuras) do
			if not currentAuras[spellID] or (currentAuras[spellID].caster ~= data.caster) then
				-- New buff or new caster for the buff
				if data.caster and data.caster ~= UnitName("player") then
					HandleNewBuff(spellID, data.caster)
				end
			end
		end
		currentAuras = newAuras
	end
end

local function HandleLoadingScreenEnabled()
	shouldThank = false
end

local function HandleLoadingScreenDisabled()
	shouldThank = true
	ClearTable(currentAuras) -- Clear current auras as they might have changed due to loading
	CacheAuras(currentAuras) -- Re-cache current auras
end

function Module:CreateAutoBuffThanks()
	if C["Automation"].BuffThanks then
		UpdateBuffsToThank() -- Initialize buff list
		K:RegisterEvent("UNIT_AURA", HandleUnitAura, "player")
		K:RegisterEvent("LOADING_SCREEN_ENABLED", HandleLoadingScreenEnabled)
		K:RegisterEvent("LOADING_SCREEN_DISABLED", HandleLoadingScreenDisabled)
	else
		K:UnregisterEvent("UNIT_AURA", HandleUnitAura, "player")
		K:UnregisterEvent("LOADING_SCREEN_ENABLED", HandleLoadingScreenEnabled)
		K:UnregisterEvent("LOADING_SCREEN_DISABLED", HandleLoadingScreenDisabled)
	end
end
