-- Based on oUF_GCD(by ALZA)
local K = KkthnxUI[1]
local oUF = K.oUF

local starttime, duration, usingspell, spellID
local GetTime = GetTime

local classSpellIDs = {
	["DEATHKNIGHT"] = 45902,
	["DRUID"] = 1126,
	["HUNTER"] = 1978,
	["MAGE"] = 168,
	["PALADIN"] = 20154,
	["PRIEST"] = 1243,
	["ROGUE"] = 1752,
	["SHAMAN"] = 403,
	["WARLOCK"] = 687,
	["WARRIOR"] = 6673,
}

local playerClass = select(2, UnitClass("player"))
spellID = classSpellIDs[playerClass]

local function OnUpdateSpark(self)
	self.Spark:ClearAllPoints()
	local elapsed = GetTime() - starttime
	local perc = elapsed / duration
	if perc > 1 then
		self:Hide()
	else
		self.Spark:SetPoint("CENTER", self, "LEFT", self.width * perc, 0)
	end
end

local function OnHide(self)
	self:SetScript("OnUpdate", nil)
	usingspell = nil
end

local function OnShow(self)
	self:SetScript("OnUpdate", OnUpdateSpark)
end

local function Init()
	if IsSpellKnown(spellID) then
		return spellID
	end
	return nil
end

local function Update(self)
	local element = self.GCD
	if element then
		if not spellID then
			spellID = Init()
			if not spellID then
				return
			end
		end
		local start, dur = GetSpellCooldown(spellID)
		if dur and dur > 0 and dur <= 2.0 then -- Adjust duration check for WoW Classic GCD
			usingspell = 1
			starttime = start
			duration = dur
			element:Show()
		elseif usingspell == 1 and dur == 0 then
			element:Hide()
			usingspell = 0
		end
	end
end

local function ForceUpdate(element)
	return Update(element.__owner)
end

local function Enable(self)
	local element = self.GCD
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		element.width = element:GetWidth()
		element:Hide()

		element.Spark = element:CreateTexture(nil, "OVERLAY")
		element.Spark:SetTexture(element.Texture)
		element.Spark:SetVertexColor(unpack(element.Color))
		element.Spark:SetHeight(element.Height)
		element.Spark:SetWidth(element.Width)
		element.Spark:SetBlendMode("ADD")

		element:SetScript("OnShow", OnShow)
		element:SetScript("OnHide", OnHide)

		self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", Update, true)

		return true
	end
end

local function Disable(self)
	local element = self.GCD
	if element then
		element:Hide()

		self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN", Update)
	end
end

oUF:AddElement("GCD", Update, Enable, Disable)
