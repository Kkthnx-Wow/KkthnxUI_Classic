local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- Modified by KkthnxUI (Kkthnx) from ElvUI (Elv)

local C_Timer_NewTicker = C_Timer.NewTicker
local C_Timer_NewTimer = C_Timer.NewTimer
local math_floor = math.floor
local string_format = string.format
local string_gsub = string.gsub
local string_sub = string.sub

local ChatFrame_GetMobileEmbeddedTexture = ChatFrame_GetMobileEmbeddedTexture
local ChatHistory_GetAccessID = ChatHistory_GetAccessID
local ChatTypeInfo = ChatTypeInfo
local Chat_GetChatCategory = Chat_GetChatCategory
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetColoredName = GetColoredName
local GetGuildInfo = GetGuildInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsMacClient = IsMacClient
local IsShiftKeyDown = IsShiftKeyDown
local NONE = NONE
local SetCVar = SetCVar
local UIParent = UIParent
local UnitCastingInfo = UnitCastingInfo
local UnitIsAFK = UnitIsAFK

local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}

local printKeys = {
	["PRINTSCREEN"] = true,
}

local monthAbr = {
	[1] = "Jan",
	[2] = "Feb",
	[3] = "Mar",
	[4] = "Apr",
	[5] = "May",
	[6] = "Jun",
	[7] = "Jul",
	[8] = "Aug",
	[9] = "Sep",
	[10] = "Oct",
	[11] = "Nov",
	[12] = "Dec",
}

local daysAbr = {
	[1] = "Sun",
	[2] = "Mon",
	[3] = "Tue",
	[4] = "Wed",
	[5] = "Thu",
	[6] = "Fri",
	[7] = "Sat",
}

local function IsIn(val, ...)
	for i = 1, select("#", ...) do
		if val == select(i, ...) then
			return true
		end
	end
	return false
end

local function setupTime(color, hour, minute)
	local useMilitaryTime = GetCVarBool("timeMgrUseMilitaryTime")

	if useMilitaryTime then
		return string.format("%s" .. TIMEMANAGER_TICKER_24HOUR, color, hour, minute)
	else
		local timerUnit = K.MyClassColor .. (hour < 12 and " AM" or " PM")

		if hour >= 12 then
			hour = hour - 12
		else
			if hour == 0 then
				hour = 12
			end
		end

		return string.format("%s" .. TIMEMANAGER_TICKER_12HOUR .. timerUnit, color, hour, minute)
	end
end

local function createTime(self)
	local color = C_Calendar.GetNumPendingInvites() > 0 and "|cffFF0000" or ""
	local hour, minute

	if GetCVarBool("timeMgrUseLocalTime") then
		hour, minute = tonumber(date("%H")), tonumber(date("%M"))
	else
		hour, minute = GetGameTime()
	end

	self.top.time:SetText(setupTime(color, hour, minute))
end

-- Create Date
local function createDate(self)
	local date = C_DateAndTime.GetCurrentCalendarTime()
	local presentWeekday = date.weekday
	local presentMonth = date.month
	local presentDay = date.monthDay
	local presentYear = date.year

	self.top.date:SetFormattedText("%s, %s %d, %d", daysAbr[presentWeekday], monthAbr[presentMonth], presentDay, presentYear)
end

local function UpdateTimer(self)
	createTime(self)
	createDate(self)
end

local function SetAFK(self, status)
	if status then
		MoveViewLeftStart(0.035)
		self:Show()
		CloseAllWindows()
		UIParent:Hide()

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo("player")
			self.bottom.guild:SetFormattedText("%s - %s", guildName, guildRankName)
		else
			self.bottom.guild:SetText(L["No Guild"])
		end

		self.bottom.model.curAnimation = "wave"
		self.bottom.model.startTime = GetTime()
		self.bottom.model.duration = 2.3
		self.bottom.model:SetUnit("player")
		self.bottom.model.isIdle = nil
		self.bottom.model:SetAnimation(67)
		self.bottom.model.idleDuration = 30

		self.bottom.modelPet:SetUnit("pet")
		self.bottom.modelPet:SetAnimation(0)

		self.startTime = GetTime()

		if self.timer then
			self.timer:Cancel()
		end
		self.timer = C_Timer_NewTicker(1, function()
			UpdateTimer(self)
		end)

		self.chat:RegisterEvent("CHAT_MSG_WHISPER")
		self.chat:RegisterEvent("CHAT_MSG_BN_WHISPER")
		self.chat:RegisterEvent("CHAT_MSG_GUILD")
		self.chat:RegisterEvent("CHAT_MSG_PARTY")
		self.chat:RegisterEvent("CHAT_MSG_RAID")

		self.isAFK = true
	elseif self.isAFK then
		UIParent:Show()
		self:Hide()
		MoveViewLeftStop()

		if self.startTime then
			self.startTime = nil
		end

		if self.timer then
			self.timer:Cancel()
		end

		if self.logoffTimer then
			self.logoffTimer:Cancel()
		end

		if self.animTimer then
			self.animTimer:Cancel()
		end

		self.chat:UnregisterAllEvents()
		self.chat:Clear()

		self.isAFK = false
	end
end

local function AFKMode_OnEvent(self, event, ...)
	if IsIn(event, "PLAYER_REGEN_DISABLED", "LFG_PROPOSAL_SHOW", "UPDATE_BATTLEFIELD_STATUS") then
		if event == "UPDATE_BATTLEFIELD_STATUS" then
			local status = GetBattlefieldStatus(...)
			if status == "confirm" then
				SetAFK(self, false)
			end
		else
			SetAFK(self, false)
		end

		if event == "PLAYER_REGEN_DISABLED" then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown() then
		return
	end

	if UnitCastingInfo("player") ~= nil then
		-- Don"t activate afk if player is crafting stuff, check back in 30 seconds
		K.Delay(30, function()
			AFKMode_OnEvent(self)
		end)
		return
	end

	if UnitIsAFK("player") then
		SetAFK(self, true)
	else
		SetAFK(self, false)
	end
end

local function OnKeyDown(self, key)
	if ignoreKeys[key] then
		return
	end

	if printKeys[key] then
		Screenshot()
	else
		SetAFK(self, false)
		K.Delay(60, function()
			AFKMode_OnEvent(self)
		end)
	end
end

local function Chat_OnMouseWheel(self, delta)
	if delta == 1 and IsShiftKeyDown() then
		self:ScrollToTop()
	elseif delta == -1 and IsShiftKeyDown() then
		self:ScrollToBottom()
	elseif delta == -1 then
		self:ScrollDown()
	else
		self:ScrollUp()
	end
end

local function Chat_OnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	local type = string_sub(event, 10)
	local info = ChatTypeInfo[type]

	if event == "CHAT_MSG_BN_WHISPER" then
		coloredName = string_format("|c%s%s|r", RAID_CLASS_COLORS.PRIEST.colorStr, arg2)
	end

	arg1 = RemoveExtraSpaces(arg1)

	local chatGroup = Chat_GetChatCategory(type)
	local chatTarget, body
	if chatGroup == "BN_CONVERSATION" then
		chatTarget = tostring(arg8)
	elseif chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
		if not (string_sub(arg2, 1, 2) == "|K") then
			chatTarget = arg2:upper()
		else
			chatTarget = arg2
		end
	end

	local playerLink
	if type ~= "BN_WHISPER" and type ~= "BN_CONVERSATION" then
		playerLink = "|Hplayer:" .. arg2 .. ":" .. arg11 .. ":" .. chatGroup .. (chatTarget and ":" .. chatTarget or "") .. "|h"
	else
		playerLink = "|HBNplayer:" .. arg2 .. ":" .. arg13 .. ":" .. arg11 .. ":" .. chatGroup .. (chatTarget and ":" .. chatTarget or "") .. "|h"
	end

	local message = arg1
	if arg14 then -- isMobile
		message = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b) .. message
	end

	-- Escape any % characters, as it may otherwise cause an "invalid option in format" error in the next step
	message = string_gsub(message, "%%", "%%%%")

	_, body = pcall(string_format, _G["CHAT_" .. type .. "_GET"] .. message, playerLink .. "[" .. coloredName .. "]" .. "|h")

	local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget)
	local typeID = ChatHistory_GetAccessID(type, chatTarget, arg12 == "" and arg13 or arg12)

	self:AddMessage(body, info.r, info.g, info.b, info.id, false, accessID, typeID)
end

local function LoopAnimations(self)
	if self.curAnimation == "wave" then
		self:SetAnimation(69)
		self.curAnimation = "dance"
		self.startTime = GetTime()
		self.duration = 300
		self.isIdle = false
		self.idleDuration = 120
	end
end

function Module:CreateAFKCam()
	if not C["Misc"].AFKCamera then
		return
	end

	local playerName = K.Name

	local AFKMode = CreateFrame("Frame")
	AFKMode:SetFrameLevel(1)
	AFKMode:SetScale(UIParent:GetScale())
	AFKMode:SetAllPoints(UIParent)
	AFKMode:Hide()
	AFKMode:EnableKeyboard(true)
	AFKMode:SetScript("OnKeyDown", OnKeyDown)

	AFKMode.chat = CreateFrame("ScrollingMessageFrame", nil, AFKMode)
	AFKMode.chat:SetSize(500, 200)
	AFKMode.chat:SetFontObject(K.UIFont)
	AFKMode.chat:SetJustifyH("LEFT")
	AFKMode.chat:SetMaxLines(100)
	AFKMode.chat:EnableMouseWheel(true)
	AFKMode.chat:SetFading(false)
	AFKMode.chat:SetMovable(true)
	AFKMode.chat:EnableMouse(true)
	AFKMode.chat:RegisterForDrag("LeftButton")
	AFKMode.chat:SetScript("OnDragStart", AFKMode.chat.StartMoving)
	AFKMode.chat:SetScript("OnDragStop", AFKMode.chat.StopMovingOrSizing)
	AFKMode.chat:SetScript("OnMouseWheel", Chat_OnMouseWheel)
	AFKMode.chat:SetScript("OnEvent", Chat_OnEvent)

	AFKMode.top = CreateFrame("Frame", nil, AFKMode)
	AFKMode.top:SetFrameLevel(0)
	AFKMode.top:CreateBorder(nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and 32, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and -10)
	AFKMode.top:SetPoint("TOP", AFKMode, "TOP", 0, 6)
	AFKMode.top:SetSize(UIParent:GetWidth() + 12, 54)

	AFKMode.chat:SetPoint("TOPLEFT", AFKMode.top, "BOTTOMLEFT", 10, -6)

	AFKMode.bottom = CreateFrame("Frame", nil, AFKMode)
	AFKMode.bottom:SetFrameLevel(0)
	AFKMode.bottom:CreateBorder(nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and 32, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and -10)
	AFKMode.bottom:SetPoint("BOTTOM", AFKMode, "BOTTOM", 0, -K.Mult + 8)
	AFKMode.bottom:SetWidth(GetScreenWidth() - 8)
	AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 11))

	AFKMode.bottom.logo = AFKMode:CreateTexture(nil, "OVERLAY")
	AFKMode.bottom.logo:SetSize(512 / 1.6, 256 / 1.6)
	AFKMode.bottom.logo:SetPoint("CENTER", AFKMode.bottom, "CENTER", 0, 60)
	AFKMode.bottom.logo:SetTexture(C["Media"].Textures.LogoTexture)

	AFKMode.top.time = AFKMode.top:CreateFontString(nil, "OVERLAY")
	AFKMode.top.time:SetFontObject(K.UIFont)
	AFKMode.top.time:SetFont(select(1, AFKMode.top.time:GetFont()), 16, select(3, AFKMode.top.time:GetFont()))
	AFKMode.top.time:SetText("")
	AFKMode.top.time:SetPoint("RIGHT", AFKMode.top, "RIGHT", -20, 0)
	AFKMode.top.time:SetJustifyH("LEFT")
	AFKMode.top.time:SetTextColor(0.7, 0.7, 0.7)

	-- WoW logo
	AFKMode.top.wowlogo = CreateFrame("Frame", nil, AFKMode) -- need this to upper the logo layer
	AFKMode.top.wowlogo:SetPoint("TOP", AFKMode.top, "TOP", 0, -5)
	AFKMode.top.wowlogo:SetFrameStrata("MEDIUM")
	AFKMode.top.wowlogo:SetSize(300, 150)
	AFKMode.top.wowlogo.tex = AFKMode.top.wowlogo:CreateTexture(nil, "OVERLAY")
	AFKMode.top.wowlogo.tex:SetTexture([[Interface\GLUES\COMMON\Glues-WoW-ClassicLogo]])
	AFKMode.top.wowlogo.tex:SetAllPoints()

	-- Date text
	AFKMode.top.date = AFKMode.top:CreateFontString(nil, "OVERLAY")
	AFKMode.top.date:SetFontObject(K.UIFont)
	AFKMode.top.date:SetFont(select(1, AFKMode.top.date:GetFont()), 16, select(3, AFKMode.top.date:GetFont()))
	AFKMode.top.date:SetText("")
	AFKMode.top.date:SetPoint("LEFT", AFKMode.top, "LEFT", 20, 0)
	AFKMode.top.date:SetJustifyH("RIGHT")
	AFKMode.top.date:SetTextColor(0.7, 0.7, 0.7)

	local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = K.Faction, 140, -20, -8, -10, -36
	if factionGroup == "Neutral" then
		factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = "Panda", 90, 15, 10, 20, -5
	end

	local modelOffsetY = 205
	if K.Race == "Human" then
		modelOffsetY = 195
	elseif K.Race == "Tauren" then
		modelOffsetY = 250
	elseif K.Race == "Draenei" then
		if K.Sex == 2 then
			modelOffsetY = 250
		end
	elseif K.Race == "Troll" then
		if K.Sex == 2 then
			modelOffsetY = 250
		elseif K.Sex == 3 then
			modelOffsetY = 280
		end
	elseif K.Race == "Dwarf" then
		if K.Sex == 2 then
			modelOffsetY = 250
		end
	end

	AFKMode.bottom.faction = AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", AFKMode.bottom, "BOTTOMLEFT", offsetX, offsetY)
	AFKMode.bottom.faction:SetTexture("Interface/Timer/" .. factionGroup .. "-Logo")
	AFKMode.bottom.faction:SetSize(size, size)

	AFKMode.bottom.name = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	AFKMode.bottom.name:SetFontObject(K.UIFont)
	AFKMode.bottom.name:SetFont(select(1, AFKMode.bottom.name:GetFont()), 20, select(3, AFKMode.bottom.name:GetFont()))
	AFKMode.bottom.name:SetFormattedText("%s-%s", playerName, K.Realm)
	AFKMode.bottom.name:SetPoint("TOPLEFT", AFKMode.bottom.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)
	AFKMode.bottom.name:SetTextColor(K.r, K.g, K.b)

	AFKMode.bottom.playerInfo = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	AFKMode.bottom.playerInfo:SetFontObject(K.UIFont)
	AFKMode.bottom.playerInfo:SetFont(select(1, AFKMode.bottom.playerInfo:GetFont()), 20, select(3, AFKMode.bottom.playerInfo:GetFont()))
	AFKMode.bottom.playerInfo:SetText(K.SystemColor .. LEVEL .. " " .. K.Level .. "|r " .. K.GreyColor .. K.Race .. "|r " .. K.MyClassColor .. UnitClass("player") .. "|r")
	AFKMode.bottom.playerInfo:SetPoint("TOPLEFT", AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)

	AFKMode.bottom.guild = AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	AFKMode.bottom.guild:SetFontObject(K.UIFont)
	AFKMode.bottom.guild:SetFont(select(1, AFKMode.bottom.guild:GetFont()), 20, select(3, AFKMode.bottom.guild:GetFont()))
	AFKMode.bottom.guild:SetText(L["No Guild"])
	AFKMode.bottom.guild:SetPoint("TOPLEFT", AFKMode.bottom.playerInfo, "BOTTOMLEFT", 0, -6)
	AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	-- Use this frame to control position of the model
	AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, AFKMode.bottom)
	AFKMode.bottom.modelHolder:SetSize(150, 150)
	AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", AFKMode.bottom, "BOTTOMRIGHT", -200, modelOffsetY)

	AFKMode.bottom.model = CreateFrame("PlayerModel", nil, AFKMode.bottom.modelHolder)
	AFKMode.bottom.model:SetPoint("CENTER", AFKMode.bottom.modelHolder, "CENTER")
	AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
	AFKMode.bottom.model:SetCamDistanceScale(4.5)
	AFKMode.bottom.model:SetFacing(6)
	AFKMode.bottom.model:SetScript("OnUpdate", function(self)
		local timePassed = GetTime() - self.startTime
		if timePassed > self.duration and self.isIdle ~= true then
			self:SetAnimation(0)
			self.isIdle = true
			AFKMode.animTimer = C_Timer_NewTimer(self.idleDuration, function()
				LoopAnimations(self)
			end)
		end
	end)

	AFKMode.bottom.modelPetHolder = CreateFrame("Frame", nil, AFKMode.bottom)
	AFKMode.bottom.modelPetHolder:SetSize(150, 150)
	AFKMode.bottom.modelPetHolder:SetPoint("BOTTOMRIGHT", AFKMode.bottom, "BOTTOMRIGHT", -500, 100)

	AFKMode.bottom.modelPet = CreateFrame("PlayerModel", nil, AFKMode.bottom.modelPetHolder)
	AFKMode.bottom.modelPet:SetPoint("CENTER", AFKMode.bottom.modelPetHolder, "CENTER")
	AFKMode.bottom.modelPet:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
	AFKMode.bottom.modelPet:SetCamDistanceScale(9)
	AFKMode.bottom.modelPet:SetFacing(6)

	AFKMode:RegisterEvent("PLAYER_FLAGS_CHANGED")
	AFKMode:RegisterEvent("PLAYER_REGEN_DISABLED")
	AFKMode:RegisterEvent("LFG_PROPOSAL_SHOW")
	AFKMode:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	AFKMode:SetScript("OnEvent", AFKMode_OnEvent)
	SetCVar("autoClearAFK", "1")

	if IsMacClient() then
		printKeys[KEY_PRINTSCREEN_MAC] = true
	end
end

Module:RegisterMisc("AFKCam", Module.CreateAFKCam)
