local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

local bit_band, math_random = bit.band, math.random
local DoEmote = DoEmote
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local CreateFrame = CreateFrame
local SlashCmdList = SlashCmdList

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

local function GetClassColor(class)
	return RAID_CLASS_COLORS[class] or { r = 1, g = 1, b = 1 }
end

-- Function to parse class from GUID
local function GetClassFromGUID(guid)
	if not guid then
		return "UNKNOWN"
	end
	local _, _, classAndRace = string.find(guid, "0x0000000000000000, 0x(.+)")
	if classAndRace then
		local classID = tonumber(classAndRace:sub(1, 1), 16)
		local classes = {
			[0x0] = "WARRIOR",
			[0x1] = "PALADIN",
			[0x2] = "HUNTER",
			[0x3] = "ROGUE",
			[0x4] = "PRIEST",
			[0x6] = "SHAMAN",
			[0x7] = "MAGE",
			[0x8] = "WARLOCK",
			[0xA] = "DRUID",
		}
		return classes[classID] or "UNKNOWN"
	end
	return "UNKNOWN"
end

function Module:DisplayKillPopup(targetName, class)
	local frame = _G["PlayerKillBanner"]
	if not frame then
		frame = CreateFrame("Frame", "PlayerKillBanner", UIParent)
		local bossBannerTexture = "Interface/LevelUp/BossBanner"

		frame:SetSize(400, 180)
		frame:SetPoint("TOP", 0, -120)

		local function createTexture(frame, layer, sizeX, sizeY, point, relPoint, offsetX, offsetY, texCoords)
			local texture = frame:CreateTexture(nil, layer)
			texture:SetSize(sizeX, sizeY)
			texture:SetPoint(point, relPoint or frame, offsetX, offsetY)
			texture:SetTexture(bossBannerTexture)
			texture:SetTexCoord(unpack(texCoords))
			return texture
		end

		frame.bannerTop = createTexture(frame, "BORDER", 440, 112, "TOP", nil, 0, -44, { 0.00195312, 0.861328, 0.224609, 0.443359 })
		frame.topFillagree = createTexture(frame, "ARTWORK", 176, 74, "CENTER", frame.bannerTop, 0, 46, { 0.244140, 0.587890, 0.576171, 0.720703 })
		frame.bannerBottom = createTexture(frame, "BORDER", 440, 112, "BOTTOM", nil, 0, 0, { 0.00195312, 0.861328, 0.00195312, 0.220703 })
		frame.bannerMiddle = createTexture(frame, "BACKGROUND", 440, 64, "TOPLEFT", frame.bannerTop, -100, -34, { 0.00195312, 0.861328, 0.447266, 0.572266 })
		frame.bannerMiddle:SetPoint("BOTTOMRIGHT", frame.bannerBottom, "BOTTOMRIGHT", 100, 25)
		frame.bottomFillagree = createTexture(frame, "ARTWORK", 66, 28, "CENTER", frame.bannerBottom, 0, -36, { 0.865234, 0.994141, 0.314453, 0.369141 })
	end

	local classColor = GetClassColor(class)

	if not frame.killText then
		frame.killText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
		frame.killText:SetFont(select(1, frame.killText:GetFont()), 24, select(3, frame.killText:GetFont()))
		frame.killText:SetPoint("CENTER", frame.bannerMiddle, 0, 0)
	end
	frame.killText:SetText(string.format("|cFFFFFFFFKilled|r |cFF%02x%02x%02x%s|r", classColor.r * 255, classColor.g * 255, classColor.b * 255, targetName))

	-- Fade out animation
	if not frame.fadeOut then
		frame.fadeOut = frame:CreateAnimationGroup()
		local fade = frame.fadeOut:CreateAnimation("Alpha")
		fade:SetFromAlpha(1)
		fade:SetToAlpha(0)
		fade:SetDuration(3)
		fade:SetStartDelay(2)
		frame.fadeOut:SetScript("OnFinished", function()
			frame:Hide()
		end)
	end

	frame:Show()
	frame.fadeOut:Play()
end

function Module:OnCombatLogEvent()
	local _, subevent, _, _, sourceName, _, _, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()

	if subevent == "PARTY_KILL" and sourceName == K.Name then
		local isPlayer = bit_band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
		if isPlayer then
			-- Check if destGUID is not nil and not an empty string before parsing
			if destGUID and destGUID ~= "" then
				local targetClass = GetClassFromGUID(destGUID)
				Module:DisplayKillPopup(destName, targetClass)
			else
				-- Log or handle the case where destGUID is not available
				print("GUID not available for:", destName)
				-- Optionally, you might decide to show a generic popup here
				Module:DisplayKillPopup(destName, "UNKNOWN")
			end

			if C["Announcements"].PvPEmote then
				local emote = pvpEmotes and pvpEmotes[math_random(#pvpEmotes)] or "hug"
				DoEmote(emote, destName)
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
	Module:DisplayKillPopup("Kkthnxbye", "HUNTER")
end

-- Registering the slash command
SLASH_TESTPOPUP1 = "/testkill"
SlashCmdList["TESTPOPUP"] = TestPopupCommand
