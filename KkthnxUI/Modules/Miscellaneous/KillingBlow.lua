local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local bit_band = _G.bit.band

local unitFilter = _G.COMBATLOG_OBJECT_CONTROL_PLAYER

local KBF = CreateFrame("Button", nil, UIParent)

function KBF:OnHide()
	KBF.Text:Hide()
end

KBF.Text = KBF:CreateFontString(nil, "OVERLAY")
KBF.Text:FontTemplate(C["Media"].Font, 18)
KBF.Text:SetPoint("TOP", UIParent, "TOP", 0, -8)
KBF.Text:SetTextColor(1, 0, 0)
KBF.Text:Hide()

KBF:SetAllPoints(KBF.Text)
KBF:SetScript("OnClick", KBF.Hide)

function Module.COMBAT_LOG_EVENT_UNFILTERED()
	local _, subEvent, _, sourceGUID, _, _, _, _, destName, destFlags = CombatLogGetCurrentEventInfo()
	if (subEvent == "PARTY_KILL") and (sourceGUID == K.GUID) and (bit_band(destFlags, unitFilter) > 0) then
		UIErrorsFrame:AddMessage("You killed "..(K.ColorClass(destName) or UNKNOWN))
		KBF.Text:SetText("You killed "..(K.ColorClass(destName) or UNKNOWN))
	end
end

function Module:CreateKillingBlow()
	-- if C["Misc"].KillingBlow ~= true then
	-- 	return
	-- end

	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.COMBAT_LOG_EVENT_UNFILTERED)
end