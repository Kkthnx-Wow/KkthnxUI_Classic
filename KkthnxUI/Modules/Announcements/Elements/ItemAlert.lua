local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Announcements")

-- Localize WoW API functions
local GetSpellLink = GetSpellLink
local GetSpellInfo = GetSpellInfo
local IsInGroup = IsInGroup
local SendChatMessage = SendChatMessage
local UnitName = UnitName

local lastTime = 0
local itemList = {
	[226241] = true, -- 宁神圣典
	[256230] = true, -- 静心圣典
	[185709] = true, -- 焦糖鱼宴
	[259409] = true, -- 海帆盛宴
	[259410] = true, -- 船长盛宴
	[276972] = true, -- 秘法药锅
	[286050] = true, -- 鲜血大餐
	[265116] = true, -- 工程战复
}

function Module:ItemAlert_Update(unit, _, spellID)
	if not C["Announcements"].ItemAlert then
		return
	end

	if (UnitInRaid(unit) or UnitInParty(unit)) and spellID and itemList[spellID] and lastTime ~= GetTime() then
		local who = UnitName(unit)
		local link = GetSpellLink(spellID)
		local name = GetSpellInfo(spellID)
		SendChatMessage(format("%s placed %s", who, link or name), K.CheckChat())

		lastTime = GetTime()
	end
end

function Module:ItemAlert_CheckGroup()
	if IsInGroup() then
		K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	else
		K:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED", Module.ItemAlert_Update)
	end
end

function Module:CreateItemAnnounce()
	self:ItemAlert_CheckGroup()
	K:RegisterEvent("GROUP_LEFT", self.ItemAlert_CheckGroup)
	K:RegisterEvent("GROUP_JOINED", self.ItemAlert_CheckGroup)
end
