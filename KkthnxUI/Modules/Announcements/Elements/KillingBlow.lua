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

	if not frame.killText then
		frame.killText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
		frame.killText:SetFont(select(1, frame.killText:GetFont()), 32, "")
		frame.killText:SetPoint("CENTER", frame.bannerMiddle, 0, 0)
	end
	frame.killText:SetText("|cFFB22222" .. targetName .. "|r")

	-- Hide the frame immediately if it's already visible
	if frame:IsVisible() then
		frame:Hide()
	end

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
	PlaySoundFile("Interface\\AddOns\\KkthnxUI\\Media\\Sounds\\KillingBlow.ogg", "Master")
	if frame.fadeOut then
		frame.fadeOut:Stop()
	end
	frame.fadeOut:Play()
end

function Module:OnCombatLogEvent()
	local _, subevent, _, _, sourceName, _, _, destGUID, destName, destFlags = CombatLogGetCurrentEventInfo()

	if subevent == "PARTY_KILL" and sourceName == K.Name then
		local isPlayer = bit_band(destFlags, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
		if isPlayer then
			local frame = _G["PlayerKillBanner"]
			if frame and frame:IsVisible() then
				frame.fadeOut:Stop()
				frame:Hide()
			end
			if destGUID and destGUID ~= "" then
				Module:DisplayKillPopup(destName)
			else
				print("GUID not available for:", destName)
				Module:DisplayKillPopup(destName, "UNKNOWN")
			end

			if C["Announcements"].PvPEmote then
				local emote = pvpEmotes[math_random(#pvpEmotes)] or "hug"
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
	Module:DisplayKillPopup(K.Name)
end

-- Registering the slash command
SLASH_TESTPOPUP1 = "/tk"
SlashCmdList["TESTPOPUP"] = TestPopupCommand
