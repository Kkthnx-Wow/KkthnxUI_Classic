local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Chat")

local string_find, string_gsub = string.find, string.gsub
local BetterDate = BetterDate
local INTERFACE_ACTION_BLOCKED = INTERFACE_ACTION_BLOCKED
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime

local timestampFormat = {
	[2] = "[%I:%M %p] ",
	[3] = "[%I:%M:%S %p] ",
	[4] = "[%H:%M] ",
	[5] = "[%H:%M:%S] ",
}

local function GetCurrentTime()
	local locTime = time()
	local realmTime = not GetCVarBool("timeMgrUseLocalTime") and C_DateAndTime_GetCurrentCalendarTime()

	if realmTime then
		realmTime.day = realmTime.monthDay
		realmTime.min = realmTime.minute
		realmTime.sec = date("%S") -- no sec value for realm time
		realmTime = time(realmTime)
	end

	return locTime, realmTime
end

function Module:SetupChannelNames(text, ...)
	if string_find(text, INTERFACE_ACTION_BLOCKED) and not K.isDeveloper then
		return
	end

	local r, g, b = ...
	if C["Chat"].WhisperColor and string_find(text, L["To"] .. " |H[BN]*player.+%]") then
		r, g, b = 0.6274, 0.3231, 0.6274
	end

	if C["Chat"].TimestampFormat.Value > 1 then
		local locTime, realmTime = GetCurrentTime()
		local oldTimeStamp = CHAT_TIMESTAMP_FORMAT and gsub(BetterDate(CHAT_TIMESTAMP_FORMAT, locTime), "%[([^]]*)%]", "%%[%1%%]")
		if oldTimeStamp then
			text = gsub(text, oldTimeStamp, "")
		end

		local timeStamp = BetterDate(K.GreyColor .. timestampFormat[C["Chat"].TimestampFormat.Value] .. "|r", realmTime or locTime)
		text = timeStamp .. text
	end

	if C["Chat"].OldChatNames then
		return self.oldAddMsg(self, text, r, g, b)
	else
		return self.oldAddMsg(self, string_gsub(text, "|h%[(%d+)%..-%]|h", "|h[%1]|h"), r, g, b)
	end
end

local function renameChatFrames()
	for i = 1, _G.NUM_CHAT_WINDOWS do
		if i ~= 2 then
			local chatFrame = _G["ChatFrame" .. i]
			chatFrame.oldAddMsg = chatFrame.AddMessage
			chatFrame.AddMessage = Module.SetupChannelNames
		end
	end
end

local function renameChatStrings()
	_G.ERR_FRIEND_ONLINE_SS = string_gsub(_G.ERR_FRIEND_ONLINE_SS, "%]%|h", "]|h|cff00c957")
	_G.ERR_FRIEND_OFFLINE_S = string_gsub(_G.ERR_FRIEND_OFFLINE_S, "%%s", "%%s|cffff7f50")

	_G.CHAT_WHISPER_INFORM_GET = L["To"] .. " %s "
	_G.CHAT_WHISPER_GET = L["From"] .. " %s "
	_G.CHAT_BN_WHISPER_INFORM_GET = L["To"] .. " %s "
	_G.CHAT_BN_WHISPER_GET = L["From"] .. " %s "

	_G.CHAT_SAY_GET = "%s "
	_G.CHAT_YELL_GET = "%s "

	if C["Chat"].OldChatNames then
		return
	end

	_G.CHAT_GUILD_GET = "|Hchannel:GUILD|h[G]|h %s "
	_G.CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[O]|h %s "

	_G.CHAT_RAID_GET = "|Hchannel:RAID|h[R]|h %s "
	_G.CHAT_RAID_WARNING_GET = "[RW] %s "
	_G.CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[RL]|h %s "

	_G.CHAT_PARTY_GET = "|Hchannel:PARTY|h[P]|h %s "
	_G.CHAT_PARTY_LEADER_GET = "|Hchannel:PARTY|h[PL]|h %s "
	_G.CHAT_PARTY_GUIDE_GET = "|Hchannel:PARTY|h[PG]|h %s "

	_G.CHAT_INSTANCE_CHAT_GET = "|Hchannel:INSTANCE|h[I]|h %s "
	_G.CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:INSTANCE|h[IL]|h %s "

	_G.CHAT_FLAG_AFK = "[AFK] "
	_G.CHAT_FLAG_DND = "[DND] "
	_G.CHAT_FLAG_GM = "[GM] "
end

function Module:CreateChatRename()
	renameChatFrames()
	renameChatStrings()
end
