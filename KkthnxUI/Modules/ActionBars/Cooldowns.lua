local K, C = unpack(select(2, ...))
local Module = K:NewModule("Cooldowns")

local _G = _G
local math_floor = math.floor
local pairs = pairs
local select = select
local string_find = string.find

local CreateFrame = _G.CreateFrame
local GetActionCooldown = _G.GetActionCooldown
local getmetatable = _G.getmetatable
local GetTime = _G.GetTime
local hooksecurefunc = _G.hooksecurefunc
local SetCVar = _G.SetCVar

local FONT_SIZE = 19
local MIN_DURATION = 2 -- the minimum duration to show cooldown text for
local MIN_SCALE = 0.5 -- the minimum scale we want to show cooldown counts at, anything below this will be hidden
local ICON_SIZE = 36

local hideNumbers, active, hooked = {}, {}, {}

function Module:StopTimer()
	self.enabled = nil
	self:Hide()
end

function Module:ForceUpdate()
	self.nextUpdate = 0
	self:Show()
end

function Module:OnSizeChanged(width)
	local cooldownFont = K.GetFont(C["UIFonts"].ActionBarsFonts)

	local fontScale = math_floor(width + 0.5) / ICON_SIZE
	if fontScale == self.fontScale then
		return
	end
	self.fontScale = fontScale

	if fontScale < MIN_SCALE then
		self:Hide()
	else
		self.text:SetFontObject(cooldownFont)
		self.text:SetFont(select(1, self.text:GetFont()), fontScale * FONT_SIZE, select(3, self.text:GetFont()))
		self.text:SetShadowColor(0, 0, 0, 0)

		if self.enabled then
			Module.ForceUpdate(self)
		end
	end
end

function Module:TimerOnUpdate(elapsed)
	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
	else
		local remain = self.duration - (GetTime() - self.start)
		if remain > 0 then
			local getTime, nextUpdate = K.FormatTime(remain)
			self.text:SetText(getTime)
			self.nextUpdate = nextUpdate
		else
			Module.StopTimer(self)
		end
	end
end

function Module:OnCreate()
	local scaler = CreateFrame("Frame", nil, self)
	scaler:SetAllPoints(self)

	local timer = CreateFrame("Frame", nil, scaler)
	timer:Hide()
	timer:SetAllPoints(scaler)
	timer:SetScript("OnUpdate", Module.TimerOnUpdate)

	local text = timer:CreateFontString(nil, "BACKGROUND")
	text:SetPoint("CENTER", 2, 0)
	text:SetJustifyH("CENTER")
	timer.text = text

	Module.OnSizeChanged(timer, scaler:GetSize())
	scaler:SetScript("OnSizeChanged", function(_, ...)
		Module.OnSizeChanged(timer, ...)
	end)

	self.timer = timer
	return timer
end

function Module:StartTimer(start, duration)
	if self:IsForbidden() then
		return
	end

	if self.noOCC or self.noCooldownCount or hideNumbers[self] then
		return
	end

	local frameName = self.GetName and self:GetName() or ""
	if C["ActionBar"].OverrideWA and string_find(frameName, "WeakAuras") then
		self.noOCC = true
		return
	end

	if start > 0 and duration > MIN_DURATION then
		local timer = self.timer or Module.OnCreate(self)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0

		-- Wait For Blizz To Fix Itself
		local parent = self:GetParent()
		local charge = parent and parent.chargeCooldown
		local chargeTimer = charge and charge.timer
		if chargeTimer and chargeTimer ~= timer then
			Module.StopTimer(chargeTimer)
		end

		if timer.fontScale >= MIN_SCALE then
			timer:Show()
		end
	elseif self.timer then
		Module.StopTimer(self.timer)
	end

	-- Hide Cooldown Flash If Barfader Enabled
	if self:GetParent().__faderParent then
		if self:GetEffectiveAlpha() > 0 then
			self:Show()
		else
			self:Hide()
		end
	end
end

function Module:HideCooldownNumbers()
	hideNumbers[self] = true
	if self.timer then
		Module.StopTimer(self.timer)
	end
end

function Module:CooldownOnShow()
	active[self] = true
end

function Module:CooldownOnHide()
	active[self] = nil
end

local function shouldUpdateTimer(self, start)
	local timer = self.timer
	if not timer then
		return true
	end
	return timer.start ~= start
end

function Module:CooldownUpdate()
	local button = self:GetParent()
	local start, duration = GetActionCooldown(button.action)

	if shouldUpdateTimer(self, start) then
		Module.StartTimer(self, start, duration)
	end
end

function Module:ActionbarUpateCooldown()
	for cooldown in pairs(active) do
		Module.CooldownUpdate(cooldown)
	end
end

function Module:RegisterActionButton()
	local cooldown = self.cooldown
	if not hooked[cooldown] then
		cooldown:HookScript("OnShow", Module.CooldownOnShow)
		cooldown:HookScript("OnHide", Module.CooldownOnHide)

		hooked[cooldown] = true
	end
end

function Module:OnEnable()
	if K.CheckAddOnState("OmniCC") or K.CheckAddOnState("ncCooldown") or K.CheckAddOnState("CooldownCount") then
		return
	end

	if not C["ActionBar"].Cooldowns then
		return
	end

	local cooldownIndex = getmetatable(ActionButton1Cooldown).__index
	hooksecurefunc(cooldownIndex, "SetCooldown", Module.StartTimer)

	hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", Module.HideCooldownNumbers)

	K:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", Module.ActionbarUpateCooldown)

	if _G["ActionBarButtonEventsFrame"].frames then
		for _, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
			Module.RegisterActionButton(frame)
		end
	end
	hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", Module.RegisterActionButton)

	-- Hide Default Cooldown
	if not InCombatLockdown() then
		SetCVar("countdownForCooldowns", 0)
	end
	K.HideInterfaceOption(InterfaceOptionsActionBarsPanelCountdownCooldowns)
end