local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

local bit_band, math_random = bit.band, math.random
local DoEmote = DoEmote
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local CreateFrame = CreateFrame
local SlashCmdList = SlashCmdList

local killCounter = {}

-- stylua: ignore start
local pvpEmotes = {
    "ANGRY", "BARK", "BECKON", "BITE", "BONK", "BURP", "BYE", "CACKLE", "CALM", "CHUCKLE", 
    "COMFORT", "CRACK", "CUDDLE", "CURTSEY", "FLEX", "GIGGLE", "GLOAT", "GRIN", "GROWL", "GUFFAW", 
    "INSULT", "LAUGH", "LICK", "MOCK", "MOO", "MOON", "MOURN", "NO", "NOSEPICK", "PITY", 
    "RASP", "ROAR", "ROFL", "RUDE", "SCRATCH", "SHOO", "SIGH", "SLAP", "SMIRK", "SNARL", 
    "SNICKER", "SNIFF", "SNUB", "SOOTHE", "TAP", "TAUNT", "TEASE", "THANK", "THREATEN", "TICKLE", 
    "VETO", "VIOLIN", "YAWN"
}
-- stylua: ignore end

function Module:DisplayKillPopup(targetName, count)
	local frame = CreateFrame("Frame", "KillPopup", UIParent)
	frame:SetSize(250, 50)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 300)

	local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
	text:SetPoint("CENTER")
	text:SetText(string.format("Killed %s|n#%d", targetName, count))

	frame.fadeOut = frame:CreateAnimationGroup()
	local fade = frame.fadeOut:CreateAnimation("Alpha")
	fade:SetFromAlpha(1)
	fade:SetToAlpha(0)
	fade:SetDuration(3)
	fade:SetStartDelay(2)
	frame.fadeOut:SetScript("OnFinished", function()
		frame:Hide()
	end)

	frame:Show()
	frame.fadeOut:Play()
end

function Module:OnCombatLogEvent()
	local _, eventType, _, _, casterName, _, _, _, targetName, targetFlags = CombatLogGetCurrentEventInfo()

	if eventType == "PARTY_KILL" and casterName == K.Name then
		local isPlayer = bit_band(targetFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
		if isPlayer then
			killCounter[targetName] = (killCounter[targetName] or 0) + 1
			Module:DisplayKillPopup(targetName, killCounter[targetName])

			if C["Announcements"].PvPEmote then
				local emote = pvpEmotes and pvpEmotes[math_random(#pvpEmotes)] or "hug"
				DoEmote(emote, targetName)
			end
		end
	end
end

function Module:CreateKillingBlow()
	if C["Announcements"].PvPEmote then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatLogEvent)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.OnCombatLogEvent)
	end
end

-- Test command for the popup
local function TestPopupCommand()
	Module:DisplayKillPopup("BobbyBob", 20) -- Example: showing one kill for "TestPlayer"
end

-- Registering the slash command
SLASH_TESTPOPUP1 = "/testkill"
SlashCmdList["TESTPOPUP"] = TestPopupCommand
