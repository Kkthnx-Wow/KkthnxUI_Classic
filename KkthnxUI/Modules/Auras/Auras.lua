local K, C = unpack(select(2, ...))
local Module = K:NewModule("Auras")

-- Sourced: KkthnxUI (Siweia)

local _G = _G
local format, floor, strmatch, select, unpack = _G.format, _G.floor, _G.strmatch, _G.select, _G.unpack
local DebuffTypeColor = _G.DebuffTypeColor
local UnitAura, GetTime = _G.UnitAura, _G.GetTime
local GetInventoryItemQuality, GetInventoryItemTexture, GetItemQualityColor, GetWeaponEnchantInfo = _G.GetInventoryItemQuality, _G.GetInventoryItemTexture, _G.GetItemQualityColor, _G.GetWeaponEnchantInfo

local margin, offset, settings = 6, 12
function Module:OnEnable()
    -- Config
    settings = {
        Buffs = {
            size = C["Auras"].BuffSize,
            wrapAfter = C["Auras"].BuffsPerRow,
            maxWraps = 3,
            reverseGrow = C["Auras"].ReverseBuffs,
        },
        Debuffs = {
            size = C["Auras"].DebuffSize,
            wrapAfter = C["Auras"].DebuffsPerRow,
            maxWraps = 1,
            reverseGrow = C["Auras"].ReverseDebuffs,
        },
    }

    -- HideBlizz
    K.HideInterfaceOption(_G.BuffFrame)
    K.HideInterfaceOption(_G.TemporaryEnchantFrame)

    -- Movers
    self.BuffFrame = self:CreateAuraHeader("HELPFUL")
    local buffAnchor = K.Mover(self.BuffFrame, "Buffs", "BuffAnchor", {"TOPRIGHT", Minimap, "TOPLEFT", -6, 0})
    self.BuffFrame:ClearAllPoints()
    self.BuffFrame:SetPoint("TOPRIGHT", buffAnchor)

    self.DebuffFrame = self:CreateAuraHeader("HARMFUL")
    local debuffAnchor = K.Mover(self.DebuffFrame, "Debuffs", "DebuffAnchor", {"TOPRIGHT", buffAnchor, "BOTTOMRIGHT", 0, -12})
    self.DebuffFrame:ClearAllPoints()
    self.DebuffFrame:SetPoint("TOPRIGHT", debuffAnchor)

    self:CreateReminder()
end

function Module:UpdateTimer(elapsed)
    if self.offset then
        local expiration = select(self.offset, GetWeaponEnchantInfo())
        if expiration then
            self.timeLeft = expiration / 1e3
        else
            self.timeLeft = 0
        end
    else
        self.timeLeft = self.timeLeft - elapsed
    end

    if self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed
        return
    end

    if self.timeLeft >= 0 then
		local timer, nextUpdate = K.FormatTime(self.timeLeft)
		self.nextUpdate = nextUpdate
		self.timer:SetText(timer)
	end
end

function Module:UpdateAuras(button, index)
    local filter = button:GetParent():GetAttribute("filter")
    local unit = button:GetParent():GetAttribute("unit")
    local name, texture, count, debuffType, duration, expirationTime = UnitAura(unit, index, filter)

    if name then
        if duration > 0 and expirationTime then
            local timeLeft = expirationTime - GetTime()
            if not button.timeLeft then
				button.nextUpdate = -1
                button.timeLeft = timeLeft
                button:SetScript("OnUpdate", Module.UpdateTimer)
            else
                button.timeLeft = timeLeft
            end
            -- Need Reviewed
			button.nextUpdate = -1
			Module.UpdateTimer(button, 0)
        else
            button.timeLeft = nil
            button.timer:SetText("")
            button:SetScript("OnUpdate", nil)
        end

        if count and count > 1 then
            button.count:SetText(count)
        else
            button.count:SetText("")
        end

        if filter == "HARMFUL" then
            local color = DebuffTypeColor[debuffType or "none"]
            button:SetBackdropBorderColor(color.r, color.g, color.b)
        else
            button:SetBackdropBorderColor()
        end

        button.icon:SetTexture(texture)
        button.offset = nil
    end
end

function Module:UpdateTempEnchant(button, index)
    local quality = GetInventoryItemQuality("player", index)
    button.icon:SetTexture(GetInventoryItemTexture("player", index))

    local offset = 2
    local weapon = button:GetName():sub(-1)
    if strmatch(weapon, "2") then
        offset = 6
    end

    if quality then
        button:SetBackdropBorderColor(GetItemQualityColor(quality))
    end

    local expirationTime, count = select(offset, GetWeaponEnchantInfo())
    if expirationTime then
        if count and count > 0 then
			button.count:SetText(count)
		else
			button.count:SetText("")
		end
        button.offset = offset
        button:SetScript("OnUpdate", Module.UpdateTimer)
        button.nextUpdate = -1
        Module.UpdateTimer(button, 0)
    else
        button.offset = nil
        button.timeLeft = nil
        button:SetScript("OnUpdate", nil)
        button.timer:SetText("")
        button.count:SetText("")
    end
end

function Module:OnAttributeChanged(attribute, value)
    if attribute == "index" then
        Module:UpdateAuras(self, value)
    elseif attribute == "target-slot" then
        Module:UpdateTempEnchant(self, value)
    end
end

function Module:UpdateHeader(header)
    local cfg = settings.Debuffs
    if header:GetAttribute("filter") == "HELPFUL" then
        cfg = settings.Buffs
        header:SetAttribute("consolidateTo", 0)
		header:SetAttribute("weaponTemplate", format("KkthnxUIAuraTemplate%d", cfg.size))
    end

    header:SetAttribute("separateOwn", 1)
    header:SetAttribute("sortMethod", "INDEX")
    header:SetAttribute("sortDirection", "+")
    header:SetAttribute("wrapAfter", cfg.wrapAfter)
    header:SetAttribute("maxWraps", cfg.maxWraps)
    header:SetAttribute("point", cfg.reverseGrow and "TOPLEFT" or "TOPRIGHT")
    header:SetAttribute("minWidth", (cfg.size + margin) * cfg.wrapAfter)
    header:SetAttribute("minHeight", (cfg.size + offset) * cfg.maxWraps)
    header:SetAttribute("xOffset", (cfg.reverseGrow and 1 or -1) * (cfg.size + margin))
    header:SetAttribute("yOffset", 0)
    header:SetAttribute("wrapXOffset", 0)
    header:SetAttribute("wrapYOffset", -(cfg.size + offset))
    header:SetAttribute("template", format("KkthnxUIAuraTemplate%d", cfg.size))

    local index = 1
    local child = select(index, header:GetChildren())
    while child do
        if (floor(child:GetWidth() * 100 + .5) / 100) ~= cfg.size then
            child:SetSize(cfg.size, cfg.size)
        end

        -- Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
        if index > (cfg.maxWraps * cfg.wrapAfter) and child:IsShown() then
            child:Hide()
        end

        index = index + 1
        child = select(index, header:GetChildren())
    end
end

function Module:CreateAuraHeader(filter)
    local name = "KkthnxUIPlayerDebuffs"
    if filter == "HELPFUL" then
        name = "KkthnxUIPlayerBuffs"
    end

    local header = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
    header:SetClampedToScreen(true)
    header:SetAttribute("unit", "player")
    header:SetAttribute("filter", filter)
    RegisterStateDriver(header, "visibility", "[petbattle] hide; show")
    RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

    if filter == "HELPFUL" then
        header:SetAttribute("consolidateDuration", -1)
        header:SetAttribute("includeWeapons", 1)
    end

    Module:UpdateHeader(header)
    header:Show()

    return header
end

function Module:CreateAuraIcon(button)
    local header = button:GetParent()
    local cfg = settings.Debuffs
    if header:GetAttribute("filter") == "HELPFUL" then
        cfg = settings.Buffs
    end
    local fontSize = floor(cfg.size / 30 * 12 + .5)

    button.icon = button:CreateTexture(nil, "BORDER")
    button.icon:SetAllPoints()
    button.icon:SetTexCoord(unpack(K.TexCoords))

    button.count = button:CreateFontString(nil, "OVERLAY")
    button.count:SetPoint("TOPRIGHT", -1, -3)
    button.count:SetFontObject(K.GetFont(C["UIFonts"].AuraFonts))
    button.count:SetFont(select(1, button.count:GetFont()), fontSize, select(3, button.count:GetFont()))

    button.timer = button:CreateFontString(nil, "OVERLAY")
    button.timer:SetPoint("TOP", button, "BOTTOM", 1, -4)
    button.timer:SetFontObject(K.GetFont(C["UIFonts"].AuraFonts))
    button.timer:SetFont(select(1, button.timer:GetFont()), fontSize, select(3, button.timer:GetFont()))

    button:CreateBorder()
    button:CreateInnerShadow()

    button:SetScript("OnAttributeChanged", Module.OnAttributeChanged)
end