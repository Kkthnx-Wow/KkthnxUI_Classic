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

local function ResetTrackingFrameAnchor()
	MiniMapTracking:ClearAllPoints()
	MiniMapTracking:SetPoint("RIGHT", Minimap, -5, 5)
end

function Module:ReskinRegions()
	-- Configure the tracking icon
	MiniMapTracking:SetScale(0.8)
	MiniMapTracking:SetFrameLevel(999)
	if MiniMapTrackingBorder then
		MiniMapTrackingBorder:Hide()
	end
	MiniMapTrackingIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	-- Create a background frame for the tracking icon
	local trackingIconBackground = CreateFrame("Frame", nil, MiniMapTracking, "BackdropTemplate")
	trackingIconBackground:SetAllPoints(MiniMapTrackingIcon)
	trackingIconBackground:SetFrameLevel(MiniMapTracking:GetFrameLevel())
	trackingIconBackground:CreateBorder()

	-- Set the border color
	trackingIconBackground.KKUI_Border:SetVertexColor(K.r, K.g, K.b)

	-- Reset the tracking frame anchor
	ResetTrackingFrameAnchor()
	hooksecurefunc("SetLookingForGroupUIAvailable", ResetTrackingFrameAnchor)

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

local calendarButton

-- Function to calculate the current day
local function GetCurrentDay()
	local today = date("*t") -- Get the current system time as a table
	return today.day -- Extract the day of the month
end

-- Function to create a custom calendar button
function Module:ShowCalendar()
	if not C["Minimap"].Calendar then
		if calendarButton then
			calendarButton:Hide()
		end
		return
	end

	if not calendarButton then
		calendarButton = CreateFrame("Button", "KKUI_CalendarButton", Minimap)
		calendarButton:SetSize(22, 22)
		calendarButton:SetPoint("TOPRIGHT", Minimap, -4, -4)

		local texturePath = "Interface\\AddOns\\KkthnxUI\\Media\\Minimap\\Calendar.blp"
		calendarButton:SetNormalTexture(texturePath)
		calendarButton:SetPushedTexture(texturePath)

		local normalTexture = calendarButton:GetNormalTexture()
		if normalTexture then
			normalTexture:SetTexCoord(0, 1, 0, 1)
		end

		local pushedTexture = calendarButton:GetPushedTexture()
		if pushedTexture then
			pushedTexture:SetTexCoord(0, 1, 0, 1)
		end

		local calendarText = calendarButton:CreateFontString(nil, "OVERLAY")
		calendarText:SetFontObject(K.UIFont)
		calendarText:SetFont(select(1, calendarText:GetFont()), 12, select(3, calendarText:GetFont()))
		calendarText:SetTextColor(0.2, 0.2, 0.2) -- Set text color to black
		calendarText:SetShadowOffset(0, 0)
		calendarText:SetPoint("CENTER", 0, -4)
		calendarText:SetText(GetCurrentDay()) -- Directly set the current day
		calendarButton.calendarText = calendarText
	end

	calendarButton:Show()
end

function Module:TrackMenu_OnClick(spellID)
	CastSpellByID(spellID)
end

function Module:TrackMenu_CheckStatus()
	local texture = GetSpellTexture(self.arg1)
	if texture == GetTrackingTexture() then
		return true
	end
end

function Module:EasyTrackMenu()
	local trackSpells = {
		2383, --Find Herbs
		2580, --Find Minerals
		2481, --Find Treasure
		1494, --Track Beasts
		19883, --Track Humanoids
		19884, --Track Undead
		19885, --Track Hidden
		19880, --Track Elementals
		19878, --Track Demons
		19882, --Track Giants
		19879, --Track Dragonkin
		5225, --Track Humanoids: Druid
		5500, --Sense Demons
		5502, --Sense Undead
	}

	local menuList = {
		[1] = { text = "TrackMenu", isTitle = true, notCheckable = true },
	}

	local function updateMenuList()
		for i = 2, #menuList do
			if menuList[i] then
				wipe(menuList[i])
			end
		end

		local index = 2
		for _, spellID in pairs(trackSpells) do
			if IsPlayerSpell(spellID) then
				if not menuList[index] then
					menuList[index] = {}
				end
				local spellName, _, texture = GetSpellInfo(spellID)
				menuList[index].arg1 = spellID
				menuList[index].text = spellName
				menuList[index].func = Module.TrackMenu_OnClick
				menuList[index].checked = Module.TrackMenu_CheckStatus
				menuList[index].icon = texture
				menuList[index].tCoordLeft = 0.08
				menuList[index].tCoordRight = 0.92
				menuList[index].tCoordTop = 0.08
				menuList[index].tCoordBottom = 0.92

				index = index + 1
			end
		end

		return index
	end

	local function toggleTrackMenu(self)
		if DropDownList1:IsShown() then
			DropDownList1:Hide()
		else
			local index = updateMenuList()
			if index > 2 then
				local offset = self:GetWidth() * self:GetScale() * 0.5
				K.LibEasyMenu.Create(menuList, K.EasyMenu, self, -offset, offset, "MENU")
			end
		end
	end

	-- Click Func
	local hasAlaCalendar = IsAddOnLoaded("alaCalendar")
	Minimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			toggleTrackMenu(self)
		elseif btn == "MiddleButton" and hasAlaCalendar then
			K:TogglePanel(ALA_CALENDAR)
		else
			Minimap_OnClick(self)
		end
	end)
end

local function UpdateDifficultyFlag()
	local frame = _G["KKUI_MinimapDifficulty"]
	local _, instanceType, difficulty, _, _, _, _, _, instanceGroupSize = GetInstanceInfo()
	local _, _, isHeroic, _, displayHeroic = GetDifficultyInfo(difficulty)
	if instanceType == "raid" or isHeroic or displayHeroic then
		if isHeroic or displayHeroic then
			frame.tex:SetTexCoord(0, 0.25, 0.0703125, 0.4296875)
		else
			frame.tex:SetTexCoord(0, 0.25, 0.5703125, 0.9296875)
		end
		frame.text:SetText(instanceGroupSize)
		frame:Show()
	else
		frame:Hide()
	end
end

function Module:MinimapDifficulty()
	if _G.MiniMapInstanceDifficulty then
		return
	end -- hide flag if blizz makes its own

	local frame = CreateFrame("Frame", "KKUI_MinimapDifficulty", Minimap)
	frame:SetSize(38, 46)
	frame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 2, 2)
	frame:SetScale(0.6)
	frame:Hide()

	local tex = frame:CreateTexture(nil, "ARTWORK")
	tex:SetTexture("Interface\\Minimap\\UI-DungeonDifficulty-Button")
	tex:SetPoint("CENTER")
	tex:SetSize(64, 46)
	tex:SetTexCoord(0, 0.25, 0.0703125, 0.4140625)
	frame.tex = tex

	frame.text = K.CreateFontString(frame, 15, "", "", true, "CENTER", 1, -8)

	K:RegisterEvent("GROUP_ROSTER_UPDATE", UpdateDifficultyFlag)
	K:RegisterEvent("UPDATE_INSTANCE_INFO", UpdateDifficultyFlag)
	K:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED", UpdateDifficultyFlag)
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

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.Minimap_OnMouseWheel)

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
		"CreatePing",
		"CreateRecycleBin",
		"CreateSoundVolume",
		"CreateStyle",
		"ReskinRegions",
		"EasyTrackMenu",
		"MinimapDifficulty",
		"HideMinimapClock",
		"ShowCalendar",
		"UpdateMinimapScale",
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
