local K, C = KkthnxUI[1], KkthnxUI[2]
local Announcements = K:GetModule("Announcements")

local bit_band, math_random = bit.band, math.random
local DoEmote = DoEmote
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo

local pvpEmotes = {
	"ANGRY",
	"BARK",
	"BECKON",
	"BITE",
	"BONK",
	"BURP",
	"BYE",
	"CACKLE",
	"CALM",
	"CHUCKLE",
	"COMFORT",
	"CRACK",
	"CUDDLE",
	"CURTSEY",
	"FLEX",
	"GIGGLE",
	"GLOAT",
	"GRIN",
	"GROWL",
	"GUFFAW",
	"INSULT",
	"LAUGH",
	"LICK",
	"MOCK",
	"MOO",
	"MOON",
	"MOURN",
	"NO",
	"NOSEPICK",
	"PITY",
	"RASP",
	"ROAR",
	"ROFL",
	"RUDE",
	"SCRATCH",
	"SHOO",
	"SIGH",
	"SLAP",
	"SMIRK",
	"SNARL",
	"SNICKER",
	"SNIFF",
	"SNUB",
	"SOOTHE",
	"TAP",
	"TAUNT",
	"TEASE",
	"THANK",
	"THREATEN",
	"TICKLE",
	"VETO",
	"VIOLIN",
	"YAWN",
}

function Announcements:OnCombatLogEvent()
	-- Retrieve combat log details
	local _, eventType, _, _, casterName, _, _, _, targetName, targetFlags = CombatLogGetCurrentEventInfo()

	-- Check if the event is a PARTY_KILL and the caster is the player
	if eventType == "PARTY_KILL" and casterName == K.Name then
		-- Determine if the target is a player or a battleground opponent
		local isPlayer = bit_band(targetFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
		if isPlayer then
			-- Execute a PvP emote on the target if enabled
			if C["Announcements"].PvPEmote then
				local emote = pvpEmotes and pvpEmotes[math_random(#pvpEmotes)] or "hug" -- Fallback to "hug" if no emotes are defined
				DoEmote(emote, targetName)
			end
		end
	end
end

function Announcements:CreateKillingBlow()
	if C["Announcements"].PvPEmote then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatLogEvent) -- Register event to listen for combat log events
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatLogEvent) -- Unregister event if settings are disabled
	end
end
