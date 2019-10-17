local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G
local string_split = _G.string.split

local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local EMOTE98_TOKEN = _G.EMOTE98_TOKEN
local UnitInParty = _G.UnitInParty
local UnitInRaid = _G.UnitInRaid
local UnitGUID = _G.UnitGUID
local GetSpellInfo = _G.GetSpellInfo
local DoEmote = _G.DoEmote
local IsAddOnLoaded = _G.IsAddOnLoaded

local playerGUID = UnitGUID("player")

-- Build Spell list (this ignores ranks)
local AutoBuffThanksList = {
	[GetSpellInfo(1255)] = true, -- Power Word: Fortitude
	[GetSpellInfo(1459)] = true, -- Arcane Intellect
	[GetSpellInfo(19742)] = true, -- Blessing Of Wisdom
	[GetSpellInfo(19834)] = true, -- Blessing Of Might
	[GetSpellInfo(20217)] = true, -- Blessing Of Kings
	[GetSpellInfo(467)] = true, -- Thorns
	[GetSpellInfo(5231)] = true, -- Mark of the Wild
	[GetSpellInfo(5697)] = true, -- Unending Breath
}

function Module:SetupAutoBuffThanksAnnounce()
	local _, event, _, sourceGUID, sourceName, _, _, destGUID, _, _, _, _, spellName = CombatLogGetCurrentEventInfo()

	if not (event == "SPELL_AURA_APPLIED") or (event == "PLAYER_ENTERING_WORLD") then
		return
	end

	-- Make sure its cast on us from another source and they are not in our raidgroup / party
	-- do not consider source-less buffs, sourceGUID ~= playerGUID is not enough because nil ~= playerGUID == true
	if (destGUID and sourceGUID) and (destGUID == playerGUID) and (sourceGUID ~= destGUID) and not (UnitInParty(sourceName) or UnitInRaid(sourceName)) then
		if AutoBuffThanksList[spellName] then
			local sourceType = string_split("-", sourceGUID) -- `type` is a reserved word for a Lua function
			-- Make sure the other source is a player
			if sourceType == "Player" then
				K.Delay(1.2, function() -- Give this more time to say thanks, so we do not look like we are bots.
					DoEmote(EMOTE98_TOKEN, sourceName)
				end)
			end
		end
	end
end

function Module:CreateAutoBuffThanksAnnounce()
	if IsAddOnLoaded("TFTB") or C["Automation"].BuffThanks ~= true then
		return
	end

	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.SetupAutoBuffThanksAnnounce)
end