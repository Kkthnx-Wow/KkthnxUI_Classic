local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Tracks last thank time for each caster and spellID combination
local thankCooldown = {}
local shouldThank = true

local spellList = { 1126, 1459, 1243, 19740, 19742, 20217, 5697 }
local emoteList = { "THANK", "BOW", "SALUTE" }
local buffsToThank = {}

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

-- Build Spell list (this ignores ranks)
local function UpdateBuffsToThank()
	ClearTable(buffsToThank)
	for _, spellID in ipairs(spellList) do
		local spellName = GetSpellInfo(spellID)
		if spellName then
			buffsToThank[spellName] = true
		end
	end
end

-- Event handler for the module
function Module:OnEvent(event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		self:OnCombatEvent(CombatLogGetCurrentEventInfo())
	elseif event == "PLAYER_ENTERING_WORLD" then
		self:PLAYER_ENTERING_WORLD()
	elseif event == "PLAYER_LEAVING_WORLD" then
		self:PLAYER_LEAVING_WORLD()
	end
end

-- We're about to enter a loading screen, unregister our combat parser
function Module:PLAYER_LEAVING_WORLD()
	K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatEvent)
	shouldThank = false
end

-- We're exiting the loading screen, start monitoring for new buffs again
function Module:PLAYER_ENTERING_WORLD()
	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatEvent)
	self._enter = GetTime()
	shouldThank = true
end

-- Handle new buff application
function Module:OnCombatEvent(...)
	if not shouldThank then
		return
	end

	local _, subevent, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, spellID, spellName = ...
	local now = GetTime()

	-- Avoid thanking right after entering the world due to possible cached events
	if self._enter and now - self._enter < 2 then
		return
	end

	if subevent == "SPELL_AURA_APPLIED" then
		-- Clear expired thank cooldowns
		for key, value in pairs(thankCooldown) do
			if value < now then
				thankCooldown[key] = nil
			end
		end

		-- Make sure it's cast on us from another source and they are not in our raid group / party
		if (destGUID and sourceGUID) and (destGUID == UnitGUID("player")) and (sourceGUID ~= destGUID) and not thankCooldown[GetCooldownKey(sourceName, spellID)] and not (UnitInParty(sourceName) or UnitInRaid(sourceName)) then
			if buffsToThank[spellName] then
				local srcType = strsplit("-", sourceGUID)
				-- Make sure the other source is a player
				if srcType == "Player" then
					thankCooldown[GetCooldownKey(sourceName, spellID)] = now + 30 -- 30 seconds cooldown for thanking
					local emote = GetRandomEmote()
					DoEmote(emote, sourceName)
				end
			end
		end
	end
end

-- Register events for BuffThanks
function Module:CreateAutoBuffThanks()
	if C["Automation"].BuffThanks then
		UpdateBuffsToThank() -- Initialize buff list
		K:RegisterEvent("PLAYER_ENTERING_WORLD", self.OnEvent)
		K:RegisterEvent("PLAYER_LEAVING_WORLD", self.OnEvent)
	else
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", self.OnEvent)
		K:UnregisterEvent("PLAYER_LEAVING_WORLD", self.OnEvent)
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatEvent)
	end
end
