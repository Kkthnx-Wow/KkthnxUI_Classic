local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G

local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
-- local GetSpellInfo = _G.GetSpellInfo
local SendChatMessage = _G.SendChatMessage
local UNKNOWN = _G.UNKNOWN

-- Build Spell list (this ignores ranks)
local SaySappedList = {
	[11297] = true,
	[6770] = true,
	[2070] = true,
}

function Module:SetupSaySapped()
	local _, event, _, _, sourceName, _, _, _, destName, _, _, _, spellName = CombatLogGetCurrentEventInfo()
	local spellID = K.GetSpellID(spellName)

	-- if not (event == "SPELL_AURA_APPLIED") or not (event == "SPELL_AURA_REFRESH") then
	-- 	return
	-- end

	-- for key, value in pairs(SaySappedList) do
	-- 	if spellID == key and value == true and destName == K.Name then
	-- 		SendChatMessage(L["Sapped"], "SAY")
	-- 		UIErrorsFrame:AddMessage(L["SappedBy"]..(sourceName or UNKNOWN))
	-- 	end
	-- end

	for key, value in pairs(SaySappedList) do
		if spellID == key and value == true and destName == K.Name and sourceName ~= K.Name and event == "SPELL_CAST_SUCCESS" then
			SendChatMessage(L["Sapped"], "SAY")
			UIErrorsFrame:AddMessage(L["SappedBy"]..(sourceName or UNKNOWN))
		end
	end
end

function Module:CreateSaySappedAnnounce()
	if C["Announcements"].SaySapped ~= true then
		return
	end

	self:SetupSaySapped()
end