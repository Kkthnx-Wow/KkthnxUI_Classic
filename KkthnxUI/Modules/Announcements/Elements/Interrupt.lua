local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Announcements")

-- Localize API functions
local string_format, GetInstanceInfo, IsActiveBattlefieldArena, IsArenaSkirmish, IsInGroup, IsInRaid, IsPartyLFG, UnitInParty, UnitInRaid = string.format, GetInstanceInfo, IsActiveBattlefieldArena, IsArenaSkirmish, IsInGroup, IsInRaid, IsPartyLFG, UnitInParty, UnitInRaid

local AURA_TYPE_BUFF = AURA_TYPE_BUFF
local infoType = {}

local blackList = {
	[(GetSpellInfo(99))] = true, -- 夺魂咆哮
	[(GetSpellInfo(122))] = true, -- 冰霜新星
	[(GetSpellInfo(1776))] = true, -- 凿击
	[(GetSpellInfo(1784))] = true, -- 潜行
	[(GetSpellInfo(5246))] = true, -- 破胆怒吼
	[(GetSpellInfo(8122))] = true, -- 心灵尖啸
}

local LOCspells = {
	[(GetSpellInfo(853))] = true, -- 制裁之锤
	[(GetSpellInfo(1776))] = true, -- 凿击
	[(GetSpellInfo(2070))] = true, -- 闷棍
	[(GetSpellInfo(2094))] = true, -- 致盲
	[(GetSpellInfo(5246))] = true, -- 破胆怒吼
	[(GetSpellInfo(5782))] = true, -- 恐惧
	[(GetSpellInfo(8122))] = true, -- 心灵尖啸
	[(GetSpellInfo(14308))] = true, -- 冰冻陷阱
	[(GetSpellInfo(15487))] = true, -- 沉默
	[(GetSpellInfo(19386))] = true, -- 翼龙钉刺
	[(GetSpellInfo(19503))] = true, -- 驱散射击
	[(GetSpellInfo(20066))] = true, -- 忏悔
}

local function getAlertChannel()
	local _, instanceType = GetInstanceInfo()
	local inPartyLFG = IsPartyLFG()
	local inRaid = IsInRaid()

	if instanceType == "arena" then
		local isSkirmish = IsArenaSkirmish()
		local _, isRegistered = IsActiveBattlefieldArena()
		inPartyLFG = isSkirmish or not isRegistered
		inRaid = false -- Arenas should not be considered raids
	end

	local alertChannel = C["Announcements"].AlertChannel.Value
	if alertChannel == 1 then
		return inPartyLFG and "INSTANCE_CHAT" or "PARTY"
	elseif alertChannel == 2 then
		return inPartyLFG and "INSTANCE_CHAT" or (inRaid and "RAID" or "PARTY")
	elseif alertChannel == 3 and inRaid then
		return inPartyLFG and "INSTANCE_CHAT" or "RAID"
	elseif alertChannel == 4 and instanceType ~= "none" then
		return "SAY"
	elseif alertChannel == 5 and instanceType ~= "none" then
		return "YELL"
	end

	return "EMOTE"
end

function Module:InterruptAlert_Toggle()
	infoType["SPELL_STOLEN"] = C["Announcements"].DispellAlert and L["Steal"]
	infoType["SPELL_DISPEL"] = C["Announcements"].DispellAlert and L["Dispel"]
	infoType["SPELL_INTERRUPT"] = C["Announcements"].InterruptAlert and L["Interrupt"]
	infoType["SPELL_AURA_BROKEN_SPELL"] = C["Announcements"].BrokenAlert and L["Broken Spell"]
end

function Module:InterruptAlert_IsEnabled()
	for _, value in pairs(infoType) do
		if value then
			return true
		end
	end
	return false
end

function Module:IsAllyPet(sourceFlags)
	if K.IsMyPet(sourceFlags) or sourceFlags == K.PartyPetFlags or sourceFlags == K.RaidPetFlags then
		return true
	end
end

function Module:InterruptAlert_Update(...)
	local _, eventType, _, sourceGUID, sourceName, sourceFlags, _, destGUID, destName, _, _, _, spellName, _, _, extraskillName, _, auraType = ...
	if not sourceGUID or sourceName == destName then
		return
	end

	local LoCAlert = true
	if LoCAlert and eventType == "SPELL_AURA_APPLIED" and LOCspells[spellName] and destGUID == K.GUID then
		local duration = select(5, AuraUtil_FindAuraByName(spellName, "player", "HARMFUL"))
		if duration > 1.5 then
			SendChatMessage(string_format("LoC - %s > %s (%ss %s)", sourceName .. "[" .. spellName .. "]", destName, duration, GetMinimapZoneText()), getAlertChannel())
		end
	elseif UnitInRaid(sourceName) or UnitInParty(sourceName) or Module:IsAllyPet(sourceFlags) then
		local infoText = infoType[eventType]
		if infoText then
			local sourceSpellID, destSpellID
			if infoText == L["Broken Spell"] then
				if auraType and auraType == AURA_TYPE_BUFF or blackList[spellName] then
					return
				end
				sourceSpellID, destSpellID = extraskillName, spellName
			elseif infoText == L["Interrupt"] then
				if C["Announcements"].OwnInterrupt and sourceName ~= K.Name and not K.IsMyPet(sourceFlags) then
					return
				end
				sourceSpellID, destSpellID = spellName, extraskillName
			else
				if C["Announcements"].OwnDispell and sourceName ~= K.Name and not K.IsMyPet(sourceFlags) then
					return
				end
				sourceSpellID, destSpellID = spellName, extraskillName
			end

			if sourceSpellID and destSpellID then
				SendChatMessage(string_format(infoText, sourceName .. "[" .. sourceSpellID .. "]", destName .. "[" .. destSpellID .. "]"), getAlertChannel())
			end
		end
	end
end

function Module:InterruptAlert_CheckGroup()
	if IsInGroup() and (not C["Announcements"].InstAlertOnly or IsInInstance()) then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end

function Module:CreateInterruptAnnounce()
	Module:InterruptAlert_Toggle()

	if Module:InterruptAlert_IsEnabled() then
		Module:InterruptAlert_CheckGroup()
		K:RegisterEvent("GROUP_LEFT", Module.InterruptAlert_CheckGroup)
		K:RegisterEvent("GROUP_JOINED", Module.InterruptAlert_CheckGroup)
		K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.InterruptAlert_CheckGroup)
	else
		K:UnregisterEvent("GROUP_LEFT", Module.InterruptAlert_CheckGroup)
		K:UnregisterEvent("GROUP_JOINED", Module.InterruptAlert_CheckGroup)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.InterruptAlert_CheckGroup)
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.InterruptAlert_Update)
	end
end
