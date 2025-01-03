local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Variables
local isBuffThanksPaused = false
local lastThanked = {}
local pauseDuration = 10 -- Default pause duration in seconds

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

	-- 5118, -- Debug
}

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

-- Core Buff Thanks Logic
local function HandleBuffThanks()
	if isBuffThanksPaused then
		return
	end

	local _, subEvent, _, _, sourceName, _, _, _, destName, _, _, spellID = CombatLogGetCurrentEventInfo()

	if destName == K.Name and (subEvent == "SPELL_CAST_SUCCESS" or subEvent == "SPELL_AURA_APPLIED") then
		local spellName = GetSpellInfo(spellID)

		if buffsToThank[spellName] then
			local currentTime = GetTime()

			if not lastThanked[sourceName] or (currentTime - lastThanked[sourceName]) > 60 then
				local delay = math.random(1, 20) / 10 -- Random delay between 1 and 2 seconds

				C_Timer.After(delay, function()
					-- print("Thanking", sourceName, "for buff", spellName, "(Spell ID:", spellID, ")", "after", delay, "seconds")
					DoEmote("THANK", sourceName)
				end)

				lastThanked[sourceName] = currentTime
			end
		end
	end
end

-- Forward Declaration
local HandlePlayerEnteringWorld

-- Resume Buff Thanks After Pause
local function ResumeBuffThanks()
	-- print("BuffThanks resumed after initial pause.")
	isBuffThanksPaused = false

	-- Unregister PLAYER_ENTERING_WORLD after its purpose is served
	K:UnregisterEvent("PLAYER_ENTERING_WORLD", HandlePlayerEnteringWorld)
	-- print("PLAYER_ENTERING_WORLD event unregistered.")
end

-- Handle Login, Reload, or Zoning
HandlePlayerEnteringWorld = function(_, isInitialLogin, isReloadingUi)
	if isInitialLogin or isReloadingUi then
		-- print("Login/Reload detected. Pausing BuffThanks for", pauseDuration, "seconds.")
		isBuffThanksPaused = true

		-- Resume BuffThanks after the configured pause duration
		C_Timer.After(pauseDuration, ResumeBuffThanks)
	else
		-- print("Zoning detected. BuffThanks remains active.")
		-- isBuffThanksPaused = false
	end
end

-- Initialization
function Module:CreateAutoBuffThanks()
	if C["Automation"].BuffThanks then
		-- Register Events
		K:RegisterEvent("PLAYER_ENTERING_WORLD", HandlePlayerEnteringWorld)
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", HandleBuffThanks)
	else
		-- Unregister Events
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", HandlePlayerEnteringWorld)
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", HandleBuffThanks)
	end
end
