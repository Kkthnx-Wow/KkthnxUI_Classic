local K, C = unpack(select(2, ...))
local Module = K:NewModule("Minimap", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

local _G = _G
local string_sub = string.sub

local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local Minimap = _G.Minimap
local MiniMapMailFrame = _G.MiniMapMailFrame
local UIParent = _G.UIParent
local GetZonePVPInfo = _G.GetZonePVPInfo

function Module:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	elseif pvpType == "hostile" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "combat" then
		return 0.84, 0.03, 0.03
	else
		return 0.9, 0.85, 0.05
	end
end

function Module:OnMouseWheelScroll(d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end

local isResetting
local function ResetZoom()
	Minimap:SetZoom(0)
	MinimapZoomIn:Enable() -- Reset enabled state of buttons
	MinimapZoomOut:Disable()
	isResetting = false
end

local function SetupZoomReset()
	if C["Minimap"].ResetZoom and not isResetting then
		isResetting = true
		C_Timer_After(C["Minimap"].ResetZoomTime, ResetZoom)
	end
end
hooksecurefunc(Minimap, "SetZoom", SetupZoomReset)

function Module:UpdateZoneText()
	if not C["Minimap"].Enable then
		return
	end

	Minimap.Location:SetText(GetMinimapZoneText())
	Minimap.Location:SetTextColor(Module:GetLocTextColor())
	Minimap.Location:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	Minimap.Location:SetFont(select(1, Minimap.Location:GetFont()), 13, select(3, Minimap.Location:GetFont()))
end

function Module:UpdateSettings()
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED)
		return
	end

	K.MinimapSize = C["Minimap"].Enable and C["Minimap"].Size or Minimap:GetWidth() + 10
	K.MinimapWidth, K.MinimapHeight = K.MinimapSize, K.MinimapSize

	Minimap:SetSize(K.MinimapSize, K.MinimapSize)

	local MinimapFrameHolder = _G.MinimapFrameHolder
	if MinimapFrameHolder then
		MinimapFrameHolder:SetWidth(Minimap:GetWidth())
	end

	-- Stop here if KkthnxUI Minimap is disabled.
	if not C["Minimap"].Enable then
		return
	end

	Minimap.Location:SetWidth(K.MinimapSize)
	Minimap.Location:Hide()

	if MiniMapMailFrame then
		MiniMapMailFrame:ClearAllPoints()
		if C["DataText"].Time then
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 4)
		else
			MiniMapMailFrame:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -6)
		end
		MiniMapMailFrame:SetScale(1.2)
		MiniMapMailFrame:SetHitRectInsets(8, 8, 12, 11)
	end

	if MiniMapTrackingFrame then
		MiniMapTrackingFrame:ClearAllPoints()
		MiniMapTrackingFrame:SetPoint("BOTTOMRIGHT", Minimap, 2, -2)

		if (MiniMapTrackingBorder) then
			MiniMapTrackingBorder:Hide()
		end

		if (MiniMapTrackingIcon) then
			MiniMapTrackingIcon:SetDrawLayer("ARTWORK")
			MiniMapTrackingIcon:SetTexCoord(unpack(K.TexCoords))
			MiniMapTrackingIcon:SetSize(20, 20)
		end

		MiniMapTrackingFrame:CreateBackdrop()
		MiniMapTrackingFrame.Backdrop:CreateInnerShadow()
		MiniMapTrackingFrame.Backdrop:SetFrameLevel(MiniMapTrackingFrame:GetFrameLevel())
		MiniMapTrackingFrame.Backdrop:SetAllPoints(MiniMapTrackingIcon)
		MiniMapTrackingFrame.Backdrop:CreateBorder()
		MiniMapTrackingFrame.Backdrop:CreateInnerShadow()
		MiniMapTrackingFrame.Backdrop:SetBackdropBorderColor(1, 1, 0)
	end

	local MiniMapBattlefieldFrame = _G.MiniMapBattlefieldFrame
	if MiniMapBattlefieldFrame then
		MiniMapBattlefieldFrame:ClearAllPoints()
		MiniMapBattlefieldFrame:Point("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -2, -2)
		MiniMapBattlefieldBorder:Hide()
		MiniMapBattlefieldIcon:SetAlpha(0)
		BattlegroundShine:SetTexture(nil)

		local queueIcon = Minimap:CreateTexture(nil, "ARTWORK")
		queueIcon:SetPoint("CENTER", MiniMapBattlefieldFrame)
		queueIcon:SetSize(50, 50)
		queueIcon:SetTexture("Interface\\Minimap\\Raid_Icon")
		queueIcon:Hide()

		local anim = queueIcon:CreateAnimationGroup()
		anim:SetLooping("REPEAT")
		anim.rota = anim:CreateAnimation("Rotation")
		anim.rota:SetDuration(2)
		anim.rota:SetDegrees(360)

		hooksecurefunc("BattlefieldFrame_UpdateStatus", function()
			queueIcon:SetShown(MiniMapBattlefieldFrame:IsShown())

			anim:Play()
			for i = 1, MAX_BATTLEFIELD_QUEUES do
				local status = GetBattlefieldStatus(i)
				if status == "confirm" then
					anim:Stop()
					break
				end
			end
		end)
	end

	if StreamingIcon then
		StreamingIcon:ClearAllPoints()
		StreamingIcon:SetPoint("TOP", UIParent, "TOP", 0, -6)
	end
end

function Module.ADDON_LOADED(_, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		FeedbackUIButton:Kill()
	end
end

function Module.PLAYER_REGEN_ENABLED()
	K:UnregisterEvent("PLAYER_REGEN_ENABLED")
	Module:UpdateSettings()
end

function Module:WhoPingedMyMap()
	local MinimapPing = CreateFrame("Frame", nil, Minimap)
	MinimapPing:SetAllPoints()

	MinimapPing.Text = MinimapPing:CreateFontString(nil, "OVERLAY")
	MinimapPing.Text:FontTemplate(nil, 14)
	MinimapPing.Text:SetPoint("TOP", MinimapPing, "TOP", 0, -20)

	local AnimationPing = MinimapPing:CreateAnimationGroup()
	AnimationPing:SetScript("OnPlay", function()
		MinimapPing:SetAlpha(1)
	end)

	AnimationPing:SetScript("OnFinished", function()
		MinimapPing:SetAlpha(0)
	end)

	AnimationPing.Fader = AnimationPing:CreateAnimation("Alpha")
	AnimationPing.Fader:SetFromAlpha(1)
	AnimationPing.Fader:SetToAlpha(0)
	AnimationPing.Fader:SetDuration(3)
	AnimationPing.Fader:SetSmoothing("OUT")
	AnimationPing.Fader:SetStartDelay(3)

	function Module.MINIMAP_PING(_, unit)
		local class = select(2, UnitClass(unit))
		if not class then
			return
		end

		local r, g, b = K.ColorClass(class)
		local name = GetUnitName(unit)
		if not name then
			return
		end

		AnimationPing:Stop()
		MinimapPing.Text:SetText(name)
		MinimapPing.Text:SetTextColor(r, g, b)
		AnimationPing:Play()
	end

	K:RegisterEvent("MINIMAP_PING", self.MINIMAP_PING)
end

local function GetMinimapShape()
	return "SQUARE"
end

function Module:SetGetMinimapShape()
	-- This is just to support for other mods
	_G.GetMinimapShape = GetMinimapShape
	Minimap:SetSize(C["Minimap"].Size, C["Minimap"].Size)
end

function Module:OnEnable()
	if not C["Minimap"].Enable then
		Minimap:SetMaskTexture([[Interface\CharacterFrame\TempPortraitAlphaMask]])
		Minimap:SetBlipTexture("Interface\\MiniMap\\ObjectIconsAtlas")
		return
	end

	local pos
	local MinimapFrameHolder = CreateFrame("Frame", "MinimapFrameHolder", Minimap)
	if K.CheckAddOnState("TitanClassic") then
		-- MinimapFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -4, -50)
		pos = {"TOPRIGHT", UIParent, "TOPRIGHT", -4, -30}
	else
		MinimapFrameHolder:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -4, -4)
		pos = {"TOPRIGHT", UIParent, "TOPRIGHT", -4, -4}
	end
	MinimapFrameHolder:SetSize(C["Minimap"].Size, C["Minimap"].Size)

	Minimap:ClearAllPoints()
	Minimap:SetPoint("CENTER", MinimapFrameHolder, "CENTER", 0, 0)
	Minimap:SetMaskTexture(C["Media"].Blank)
	Minimap:CreateBorder()
	Minimap:CreateInnerShadow(nil, 0.4)
	Minimap:SetScale(1.0)
	Minimap:SetBlipTexture(C["Minimap"].BlipTexture.Value)

	Minimap:HookScript("OnEnter", function(mm)
		if not C["Minimap"].Enable then
			return
		end

		mm.Location:Show()
	end)

	Minimap:HookScript("OnLeave", function(mm)
		if not C["Minimap"].Enable then
			return
		end

		mm.Location:Hide()
	end)

	Minimap.Location = Minimap:CreateFontString(nil, "OVERLAY")
	Minimap.Location:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	Minimap.Location:SetFont(select(1, Minimap.Location:GetFont()), 13, select(3, Minimap.Location:GetFont()))
	Minimap.Location:SetPoint("TOP", Minimap, "TOP", 0, -4)
	Minimap.Location:SetJustifyH("CENTER")
	Minimap.Location:SetJustifyV("MIDDLE")
	if not C["Minimap"].Enable then
		Minimap.Location:Hide()
	end

	_G.GameTimeFrame:Hide()
	_G.MiniMapMailBorder:Hide()
	_G.MiniMapMailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")
	_G.MinimapBorder:Hide()
	_G.MinimapNorthTag:Kill()
	_G.MinimapBorderTop:Hide()
	_G.MinimapToggleButton:Hide()
	_G.MinimapZoneTextButton:Hide()
	_G.MinimapZoomIn:Hide()
	_G.MinimapZoomOut:Hide()

	_G.MiniMapWorldMapButton:Hide()

	if _G.TimeManagerClockButton then
		_G.TimeManagerClockButton:Kill()
	end

	if _G.FeedbackUIButton then
		_G.FeedbackUIButton:Kill()
	end

	_G.MinimapCluster:EnableMouse(false)

	K.Mover(MinimapFrameHolder, "Minimap", "Minimap", pos)

	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", Module.OnMouseWheelScroll)

	K:RegisterEvent("PLAYER_ENTERING_WORLD", self.UpdateZoneText)
	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", self.UpdateZoneText)
	K:RegisterEvent("ZONE_CHANGED", self.UpdateZoneText)
	K:RegisterEvent("ZONE_CHANGED_INDOORS", self.UpdateZoneText)
	K:RegisterEvent("ADDON_LOADED", self.ADDON_LOADED)

	self:UpdateSettings()
	self:SetGetMinimapShape()
	self:WhoPingedMyMap()
	self:CreateRecycleBin()
end