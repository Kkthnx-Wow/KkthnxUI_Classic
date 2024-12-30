local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Minimap")

local math_floor = math.floor
local mod = mod
local select = select
-- local table_sort = table.sort

local C_Calendar_GetNumPendingInvites = C_Calendar.GetNumPendingInvites
-- local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local GetUnitName = GetUnitName
local InCombatLockdown = InCombatLockdown
local Minimap = Minimap
local Minimap = Minimap
local UnitClass = UnitClass
local hooksecurefunc = hooksecurefunc

function Module:CreateStyle()
	local minimapBorder = CreateFrame("Frame", "KKUI_MinimapBorder", Minimap)
	minimapBorder:SetAllPoints(Minimap)
	minimapBorder:SetFrameLevel(Minimap:GetFrameLevel())
	minimapBorder:SetFrameStrata("LOW")
	minimapBorder:CreateBorder()

	if not C["Minimap"].MailPulse then
		return
	end

	local MinimapMailFrame = MiniMapMailFrame

	local minimapMailPulse = CreateFrame("Frame", nil, Minimap, "BackdropTemplate")
	minimapMailPulse:SetBackdrop({
		edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay",
		edgeSize = 12,
	})
	minimapMailPulse:SetPoint("TOPLEFT", minimapBorder, -5, 5)
	minimapMailPulse:SetPoint("BOTTOMRIGHT", minimapBorder, 5, -5)
	minimapMailPulse:Hide()

	local anim = minimapMailPulse:CreateAnimationGroup()
	anim:SetLooping("BOUNCE")
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(0.8)
	anim.fader:SetToAlpha(0.2)
	anim.fader:SetDuration(1)
	anim.fader:SetSmoothing("OUT")

	-- Add comments to describe the purpose of the function
	local function updateMinimapBorderAnimation(event)
		local borderColor = nil

		-- If player enters combat, set border color to red
		if event == "PLAYER_REGEN_DISABLED" then
			borderColor = { 1, 0, 0, 0.8 }
		elseif not InCombatLockdown() then
			if C_Calendar.GetNumPendingInvites() > 0 or MinimapMailFrame:IsShown() then
				-- If there are pending calendar invites or minimap mail frame is shown, set border color to yellow
				borderColor = { 1, 1, 0, 0.8 }
			end
		end

		-- If a border color was set, show the minimap mail pulse frame and play the animation
		if borderColor then
			minimapMailPulse:Show()
			minimapMailPulse:SetBackdropBorderColor(unpack(borderColor))
			anim:Play()
		else
			minimapMailPulse:Hide()
			minimapMailPulse:SetBackdropBorderColor(1, 1, 0, 0.8)
			-- Stop the animation
			anim:Stop()
		end
	end
	K:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateMinimapBorderAnimation)
	K:RegisterEvent("PLAYER_REGEN_DISABLED", updateMinimapBorderAnimation)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", updateMinimapBorderAnimation)
	K:RegisterEvent("UPDATE_PENDING_MAIL", updateMinimapBorderAnimation)

	MinimapMailFrame:HookScript("OnHide", function()
		if InCombatLockdown() then
			return
		end

		if anim and anim:IsPlaying() then
			anim:Stop()
			minimapMailPulse:Hide()
		end
	end)
end

function Module:ReskinRegions()
	-- -- QueueStatus Button
	-- if LFGMinimapFrame then
	-- 	LFGMinimapFrame:SetParent(MinimapCluster)
	-- 	LFGMinimapFrame:SetSize(24, 24)
	-- 	LFGMinimapFrame:SetFrameLevel(20)
	-- 	LFGMinimapFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -4, 4)

	-- 	LFGMinimapFrameIcon:SetAlpha(0)

	-- 	QueueStatusFrame:SetPoint("TOPRIGHT", LFGMinimapFrame, "TOPLEFT")

	-- 	hooksecurefunc(LFGMinimapFrame, "SetPoint", function(button, _, _, _, x, y)
	-- 		if not (x == -4 and y == 4) then
	-- 			button:ClearAllPoints()
	-- 			button:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -4, 4)
	-- 		end
	-- 	end)

	-- 	local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
	-- 	queueIcon:SetPoint("CENTER", LFGMinimapFrame)
	-- 	queueIcon:SetSize(56, 56)
	-- 	queueIcon:SetTexture("Interface\\Minimap\\Dungeon_Icon")

	-- 	local anim = queueIcon:CreateAnimationGroup()
	-- 	anim:SetLooping("REPEAT")
	-- 	anim.rota = anim:CreateAnimation("Rotation")
	-- 	anim.rota:SetDuration(2)
	-- 	anim.rota:SetDegrees(360)

	-- 	hooksecurefunc(QueueStatusFrame, "Update", function()
	-- 		queueIcon:SetShown(LFGMinimapFrame:IsShown())
	-- 	end)

	-- 	hooksecurefunc(LFGMinimapFrame.Eye, "PlayAnim", function()
	-- 		anim:Play()
	-- 	end)

	-- 	hooksecurefunc(LFGMinimapFrame.Eye, "StopAnimating", function()
	-- 		anim:Pause()
	-- 	end)

	-- 	local queueStatusDisplay = Module.QueueStatusDisplay
	-- 	if queueStatusDisplay then
	-- 		queueStatusDisplay.text:ClearAllPoints()
	-- 		queueStatusDisplay.text:SetPoint("CENTER", LFGMinimapFrame, 0, -5)
	-- 		queueStatusDisplay.text:SetFontObject(K.UIFont)
	-- 		queueStatusDisplay.text:SetFont(
	-- 			select(1, queueStatusDisplay.text:GetFont()),
	-- 			13,
	-- 			select(3, queueStatusDisplay.text:GetFont())
	-- 		)

	-- 		if queueStatusDisplay.title then
	-- 			Module:ClearQueueStatus()
	-- 		end
	-- 	end
	-- end

	-- Difficulty Flags
	local instDifficulty = MinimapCluster.InstanceDifficulty
	if instDifficulty then
		instDifficulty:SetParent(Minimap)
		instDifficulty:SetScale(0.9)

		local function UpdateFlagAnchor(frame, _, _, _, _, _, force)
			if force then
				return
			end
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 2, -2, true)
		end

		UpdateFlagAnchor(instDifficulty)
		hooksecurefunc(instDifficulty, "SetPoint", UpdateFlagAnchor)

		local function ReplaceFlagTexture(texture)
			texture:SetTexture(K.MediaFolder .. "Minimap\\Flag")
		end

		local function ReskinDifficultyFrame(frame)
			if not frame then
				return
			end

			if frame.Border then
				frame.Border:Hide()
			end
			ReplaceFlagTexture(frame.Background)
			hooksecurefunc(frame.Background, "SetAtlas", ReplaceFlagTexture)
		end

		ReskinDifficultyFrame(instDifficulty.Instance)
		ReskinDifficultyFrame(instDifficulty.Guild)
		ReskinDifficultyFrame(instDifficulty.ChallengeMode)
	end

	-- Mail icon
	if MiniMapMailFrame then
		MiniMapMailFrame:ClearAllPoints()
		if C["DataText"].Time then
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 14)
		else
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 4)
		end
		MiniMapMailIcon:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Mail")
		MiniMapMailIcon:SetSize(64, 58)
		MiniMapMailIcon:SetScale(0.5)
	end

	if TimeManagerClockButton then
		TimeManagerClockButton:ClearAllPoints()
		TimeManagerClockButton:SetPoint("BOTTOM", K.UIFrameHider)
		TimeManagerClockButton:Hide()
	end

	-- Invites Icon
	if GameTimeCalendarInvitesTexture then
		GameTimeCalendarInvitesTexture:ClearAllPoints()
		GameTimeCalendarInvitesTexture:SetParent(Minimap)
		GameTimeCalendarInvitesTexture:SetPoint("TOPLEFT")
	end

	-- Streaming icon
	if StreamingIcon then
		StreamingIcon:ClearAllPoints()
		StreamingIcon:SetParent(Minimap)
		StreamingIcon:SetPoint("LEFT", -6, 0)
		StreamingIcon:SetAlpha(0.5)
		StreamingIcon:SetScale(0.8)
		StreamingIcon:SetFrameStrata("LOW")
	end

	local inviteNotification = CreateFrame("Button", nil, UIParent, "BackdropTemplate")
	inviteNotification:SetBackdrop({
		edgeFile = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_Glow_Overlay",
		edgeSize = 12,
	})
	inviteNotification:SetPoint("TOPLEFT", Minimap, -5, 5)
	inviteNotification:SetPoint("BOTTOMRIGHT", Minimap, 5, -5)
	inviteNotification:SetBackdropBorderColor(1, 1, 0, 0.8)
	inviteNotification:Hide()

	K.CreateFontString(inviteNotification, 12, K.InfoColor .. "Pending Calendar Invite(s)!", "")

	local function updateInviteVisibility()
		inviteNotification:SetShown(C_Calendar_GetNumPendingInvites() > 0)
	end
	K:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateInviteVisibility)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", updateInviteVisibility)

	inviteNotification:SetScript("OnClick", function(_, btn)
		inviteNotification:Hide()

		if btn == "LeftButton" then
			ToggleCalendar()
		end

		K:UnregisterEvent("CALENDAR_UPDATE_PENDING_INVITES", updateInviteVisibility)
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", updateInviteVisibility)
	end)

	-- LFG Icon
	C_Timer.After(1, function()
		if LFGMinimapFrame then
			LFGMinimapFrame:ClearAllPoints()
			LFGMinimapFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -0, 0)
			LFGMinimapFrameBorder:Hide()
		end
	end)
end

function Module:CreatePing()
	local pingFrame = CreateFrame("Frame", nil, Minimap)
	pingFrame:SetSize(Minimap:GetWidth(), 13)
	pingFrame:SetPoint("BOTTOM", _G.Minimap, "BOTTOM", 0, 30)
	pingFrame.text = K.CreateFontString(pingFrame, 13, "", "OUTLINE", false, "CENTER")

	local pingAnimation = pingFrame:CreateAnimationGroup()

	pingAnimation:SetScript("OnPlay", function()
		pingFrame:SetAlpha(0.8)
	end)

	pingAnimation:SetScript("OnFinished", function()
		pingFrame:SetAlpha(0)
	end)

	pingAnimation.fader = pingAnimation:CreateAnimation("Alpha")
	pingAnimation.fader:SetFromAlpha(1)
	pingAnimation.fader:SetToAlpha(0)
	pingAnimation.fader:SetDuration(3)
	pingAnimation.fader:SetSmoothing("OUT")
	pingAnimation.fader:SetStartDelay(3)

	K:RegisterEvent("MINIMAP_PING", function(_, unit)
		if UnitIsUnit(unit, "player") then -- ignore player ping
			return
		end

		local class = select(2, UnitClass(unit))
		local r, g, b = K.ColorClass(class)
		local name = GetUnitName(unit)

		pingAnimation:Stop()
		pingFrame.text:SetText(name)
		pingFrame.text:SetTextColor(r, g, b)
		pingAnimation:Play()
	end)
end

function Module:UpdateMinimapScale()
	local size = C["Minimap"].Size
	Minimap:SetSize(size, size)
	if Minimap.mover then
		Minimap.mover:SetSize(size, size)
	end
end

function GetMinimapShape() -- LibDBIcon
	if not Module.Initialized then
		Module:UpdateMinimapScale()
		Module.Initialized = true
	end

	return "SQUARE"
end

function Module:HideMinimapClock()
	if TimeManagerClockButton then
		TimeManagerClockButton:Hide()
	end
end

local GameTimeFrameStyled
function Module:ShowCalendar()
	if C["Minimap"].Calendar then
		if not GameTimeFrameStyled then
			local GameTimeFrame = GameTimeFrame
			local calendarText = GameTimeFrame:CreateFontString(nil, "OVERLAY")

			GameTimeFrame:SetParent(Minimap)
			GameTimeFrame:SetFrameLevel(16)
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:SetPoint("TOPRIGHT", Minimap, -4, -4)
			GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
			GameTimeFrame:SetSize(22, 22)

			-- calendarText:ClearAllPoints()
			-- calendarText:SetPoint("CENTER", 0, -4)
			-- calendarText:SetFontObject(K.UIFont)
			-- calendarText:SetFont(select(1, calendarText:GetFont()), 12, select(3, calendarText:GetFont()))
			-- calendarText:SetTextColor(0, 0, 0)
			-- calendarText:SetShadowOffset(0, 0)
			-- calendarText:SetAlpha(0.9)

			-- hooksecurefunc("GameTimeFrame_SetDate", function()
			-- 	GameTimeFrame:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
			-- 	GameTimeFrame:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp")
			-- 	GameTimeFrame:SetHighlightTexture(0)
			-- 	GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
			-- 	GameTimeFrame:GetPushedTexture():SetTexCoord(0, 1, 0, 1)
			-- 	calendarText:SetText(C_DateAndTime_GetCurrentCalendarTime().monthDay)
			-- end)

			GameTimeFrameStyled = true
		end

		GameTimeFrame:Show()
	else
		GameTimeFrame:Hide()
	end
end

local function GetVolumeColor(cur)
	local r, g, b = K.oUF:RGBColorGradient(cur, 100, 1, 1, 1, 1, 0.8, 0, 1, 0, 0)
	return r, g, b
end

local function GetCurrentVolume()
	return K.Round(GetCVar("Sound_MasterVolume") * 100)
end

function Module:CreateSoundVolume()
	if not C["Minimap"].EasyVolume then
		return
	end

	local f = CreateFrame("Frame", nil, Minimap)
	f:SetAllPoints()
	local text = K.CreateFontString(f, 30)

	local anim = f:CreateAnimationGroup()
	anim:SetScript("OnPlay", function()
		f:SetAlpha(1)
	end)
	anim:SetScript("OnFinished", function()
		f:SetAlpha(0)
	end)
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(1)
	anim.fader:SetToAlpha(0)
	anim.fader:SetDuration(3)
	anim.fader:SetSmoothing("OUT")
	anim.fader:SetStartDelay(1)

	Module.VolumeText = text
	Module.VolumeAnim = anim
end

function Module:Minimap_OnMouseWheel(zoom)
	if IsControlKeyDown() and Module.VolumeText then
		local value = GetCurrentVolume()
		local mult = IsAltKeyDown() and 100 or 2
		value = value + zoom * mult
		if value > 100 then
			value = 100
		end
		if value < 0 then
			value = 0
		end

		SetCVar("Sound_MasterVolume", tostring(value / 100))
		Module.VolumeText:SetText(value .. "%")
		Module.VolumeText:SetTextColor(GetVolumeColor(value))
		Module.VolumeAnim:Stop()
		Module.VolumeAnim:Play()
	else
		if zoom > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end
end

function Module:OnEnable()
	if not C["Minimap"].Enable then
		return
	end

	-- Shape and Position
	Minimap:SetFrameLevel(10)
	Minimap:SetMaskTexture(C["Media"].Textures.White8x8Texture)
	DropDownList1:SetClampedToScreen(true)

	local minimapMover = K.Mover(Minimap, "Minimap", "Minimap", { "TOPRIGHT", UIParent, "TOPRIGHT", -4, -4 })
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", minimapMover)
	Minimap.mover = minimapMover

	self:HideMinimapClock()
	self:ShowCalendar()
	self:UpdateMinimapScale()

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.Minimap_OnMouseWheel)
	-- Minimap:SetScript("OnMouseUp", Module.Minimap_OnMouseUp)

	-- Hide Blizz
	local frames = {
		"MinimapBorderTop",
		"MinimapNorthTag",
		"MinimapBorder",
		"MinimapZoneTextButton",
		"MinimapZoomOut",
		"MinimapZoomIn",
		"MiniMapWorldMapButton",
		"MiniMapMailBorder",
		"MinimapToggleButton",
		"GameTimeFrame",
	}

	for _, v in pairs(frames) do
		local object = _G[v]
		if object then
			K.HideInterfaceOption(_G[v])
		end
	end
	MinimapCluster:EnableMouse(false)

	-- Add Elements
	local loadMinimapModules = {
		"BlizzardACF",
		"CreatePing",
		"CreateRecycleBin",
		"CreateSoundVolume",
		"CreateStyle",
		"ReskinRegions",
	}

	for _, funcName in ipairs(loadMinimapModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
