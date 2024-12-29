local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Tooltip")

local gsub, unpack, strfind = gsub, unpack, strfind
local GetItemIcon, GetSpellTexture = GetItemIcon, GetSpellTexture
local newString = "0:0:64:64:5:59:5:59"

function Module:SetupTooltipIcon(icon)
	local title = icon and _G[self:GetName() .. "TextLeft1"]
	local titleText = title and title:GetText()
	if titleText then
		title:SetFormattedText("|T%s:20:20:" .. newString .. ":%d|t %s", icon, 20, titleText)
	end

	for i = 2, self:NumLines() do
		local line = _G[self:GetName() .. "TextLeft" .. i]
		if not line then
			break
		end
		local text = line:GetText()
		if text and text ~= " " and not strfind(text, "UI%-CharacterCreate%-Classes") then
			local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:" .. newString .. "|t")
			if count > 0 then
				line:SetText(newText)
			end
		end
	end
end

function Module:HookTooltipCleared()
	self.tipModified = false
end

function Module:HookTooltipSetItem()
	if not self.tipModified then
		local _, link = self:GetItem()
		if link then
			Module.SetupTooltipIcon(self, GetItemIcon(link))
		end

		self.tipModified = true
	end
end

function Module:HookTooltipSetSpell()
	if not self.tipModified then
		local _, id = self:GetSpell()
		if id then
			Module.SetupTooltipIcon(self, GetSpellTexture(id))
		end

		self.tipModified = true
	end
end

function Module:HookTooltipMethod()
	self:HookScript("OnTooltipSetItem", Module.HookTooltipSetItem)
	self:HookScript("OnTooltipSetSpell", Module.HookTooltipSetSpell)
	self:HookScript("OnTooltipCleared", Module.HookTooltipCleared)
end

local function updateBackdropColor(self, r, g, b)
	self.bg.KKUI_Border:SetVertexColor(r, g, b)
end

local function resetBackdropColor(self)
	self.bg.KKUI_Border:SetVertexColor(1, 1, 1)
end

function Module:ReskinRewardIcon()
	self.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	self.Count:ClearAllPoints()
	self.Count:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", 1, 1)

	self.bg = CreateFrame("Frame", nil, self)
	self.bg:SetAllPoints(self.Icon)
	self.bg:SetFrameLevel(2)
	self.bg:CreateBorder()

	local iconBorder = self.IconBorder
	iconBorder:SetAlpha(0)
	hooksecurefunc(iconBorder, "SetVertexColor", updateBackdropColor)
	hooksecurefunc(iconBorder, "Hide", resetBackdropColor)
end

function Module:CreateTooltipIcons()
	if not C["Tooltip"].Icons then
		return
	end

	Module.HookTooltipMethod(GameTooltip)
	Module.HookTooltipMethod(ItemRefTooltip)

	hooksecurefunc(GameTooltip, "SetUnitAura", function(self)
		Module.SetupTooltipIcon(self)
	end)

	-- Tooltip rewards icon
	Module.ReskinRewardIcon(EmbeddedItemTooltip.ItemTooltip)
end
