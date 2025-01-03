local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- Credit: ElvUI

-- Localizing global functions and constants
local _G = _G
local pairs, ipairs, next = pairs, ipairs, next
local UnitAffectingCombat, UnitExists, UnitHealth, UnitHealthMax = _G.UnitAffectingCombat, _G.UnitExists, _G.UnitHealth, _G.UnitHealthMax
local UnitCastingInfo, UnitChannelInfo = _G.UnitCastingInfo, _G.UnitChannelInfo
local CreateFrame, C_Timer = _G.CreateFrame, _G.C_Timer

local function CancelTimer(timer)
	if timer and not timer:IsCancelled() then
		timer:Cancel()
	end
end

local function ClearTimers(object)
	CancelTimer(object.delayTimer)
	object.delayTimer = nil
end

local function DelayFadeOut(frame, timeToFade, startAlpha, endAlpha)
	ClearTimers(frame)

	if C["ActionBar"].BarFadeDelay > 0 then
		frame.delayTimer = C_Timer.NewTimer(C["ActionBar"].BarFadeDelay, function()
			K.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
		end)
	else
		K.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	end
end

function Module:FadeBlingTexture(cooldown, alpha)
	if cooldown then
		cooldown:SetBlingTexture(alpha > 0.5 and [[Interface\Cooldown\star4]] or C["Media"].Textures.BlankTexture)
	end
end

function Module:FadeBlings(alpha)
	for _, button in pairs(Module.buttons) do
		Module:FadeBlingTexture(button.cooldown, alpha)
	end
end

function Module:Button_OnEnter()
	if not Module.fadeParent.mouseLock then
		ClearTimers(Module.fadeParent)
		K.UIFrameFadeIn(Module.fadeParent, 0.2, Module.fadeParent:GetAlpha(), 1)
		Module:FadeBlings(1)
	end
end

function Module:Button_OnLeave()
	if not Module.fadeParent.mouseLock then
		DelayFadeOut(Module.fadeParent, 0.38, Module.fadeParent:GetAlpha(), C["ActionBar"].BarFadeAlpha)
		Module:FadeBlings(C["ActionBar"].BarFadeAlpha)
	end
end

function Module:FadeParent_OnEvent(event)
	local inCombat = C["ActionBar"].BarFadeCombat and UnitAffectingCombat("player")
	local hasTarget = C["ActionBar"].BarFadeTarget and UnitExists("target")
	local isCasting = C["ActionBar"].BarFadeCasting and (UnitCastingInfo("player") or UnitChannelInfo("player"))
	local lowHealth = C["ActionBar"].BarFadeHealth and (UnitHealth("player") < UnitHealthMax("player"))

	if event == "ACTIONBAR_SHOWGRID" or inCombat or hasTarget or isCasting or lowHealth then
		self.mouseLock = true
		ClearTimers(self)
		K.UIFrameFadeIn(self, 0.2, self:GetAlpha(), 1)
		Module:FadeBlings(1)
	else
		self.mouseLock = false
		DelayFadeOut(self, 0.38, self:GetAlpha(), C["ActionBar"].BarFadeAlpha)
		Module:FadeBlings(C["ActionBar"].BarFadeAlpha)
	end
end

local options = {
	BarFadeCombat = {
		enable = function(self)
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
			self:RegisterUnitEvent("UNIT_FLAGS", "player")
		end,
		events = { "PLAYER_REGEN_ENABLED", "PLAYER_REGEN_DISABLED", "UNIT_FLAGS" },
	},
	BarFadeTarget = {
		enable = function(self)
			self:RegisterEvent("PLAYER_TARGET_CHANGED")
		end,
		events = { "PLAYER_TARGET_CHANGED" },
	},
	BarFadeCasting = {
		enable = function(self)
			self:RegisterUnitEvent("UNIT_SPELLCAST_START", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_STOP", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_START", "player")
			self:RegisterUnitEvent("UNIT_SPELLCAST_CHANNEL_STOP", "player")
		end,
		events = { "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_STOP", "UNIT_SPELLCAST_CHANNEL_START", "UNIT_SPELLCAST_CHANNEL_STOP" },
	},
	BarFadeHealth = {
		enable = function(self)
			self:RegisterUnitEvent("UNIT_HEALTH", "player")
		end,
		events = { "UNIT_HEALTH" },
	},
}

function Module:UpdateFaderSettings()
	for key, option in pairs(options) do
		if C["ActionBar"][key] then
			if option.enable then
				option.enable(Module.fadeParent)
			end
		else
			if option.events and next(option.events) then
				for _, event in ipairs(option.events) do
					Module.fadeParent:UnregisterEvent(event)
				end
			end
		end
	end
end

local KKUI_ActionBars = {
	["Bar1Fade"] = "KKUI_ActionBar1",
	["Bar2Fade"] = "KKUI_ActionBar2",
	["Bar3Fade"] = "KKUI_ActionBar3",
	["Bar4Fade"] = "KKUI_ActionBar4",
	["Bar5Fade"] = "KKUI_ActionBar5",
	["Bar6Fade"] = "KKUI_ActionBar6",
	["Bar7Fade"] = "KKUI_ActionBar7",
	["Bar8Fade"] = "KKUI_ActionBar8",
	["BarPetFade"] = "KKUI_ActionBarPet",
	["BarStanceFade"] = "KKUI_ActionBarStance",
	["BarAspectFade"] = "KKUI_ActionBarAspect",
}

local function updateAfterCombat(event)
	Module:UpdateFaderState()
	K:UnregisterEvent(event, updateAfterCombat)
end

function Module:UpdateFaderState()
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", updateAfterCombat)
		return
	end

	for key, name in pairs(KKUI_ActionBars) do
		local bar = _G[name]
		if bar then
			bar:SetParent(C["ActionBar"][key] and Module.fadeParent or UIParent)
		end
	end

	if not Module.isHooked then
		for _, button in ipairs(Module.buttons) do
			button:HookScript("OnEnter", Module.Button_OnEnter)
			button:HookScript("OnLeave", Module.Button_OnLeave)
		end

		Module.isHooked = true
	end
end

function Module:CreateBarFadeGlobal()
	if not C["ActionBar"].BarFadeGlobal then
		return
	end

	Module.fadeParent = CreateFrame("Frame", "KKUI_BarFader", _G.UIParent, "SecureHandlerStateTemplate")
	RegisterStateDriver(Module.fadeParent, "visibility", "[petbattle] hide; show")
	Module.fadeParent:SetAlpha(C["ActionBar"].BarFadeAlpha)
	Module.fadeParent:RegisterEvent("ACTIONBAR_SHOWGRID")
	Module.fadeParent:RegisterEvent("ACTIONBAR_HIDEGRID")
	Module.fadeParent:SetScript("OnEvent", Module.FadeParent_OnEvent)

	Module:UpdateFaderSettings()
	Module:UpdateFaderState()
end
