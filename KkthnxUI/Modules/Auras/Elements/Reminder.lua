local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Auras")

local IsPlayerSpell, GetSpellTexture = IsPlayerSpell, GetSpellTexture
local pairs, tinsert, next = pairs, table.insert, next

local groups = C.SpellReminderBuffs[K.Class]
local iconSize = 36
local frames, parentFrame = {}

function Module:Reminder_ConvertToName(cfg)
	local cache = {}
	for spellID in pairs(cfg.spells) do
		local name = GetSpellInfo(spellID)
		if name then
			cache[name] = true
		end
	end
	for name in pairs(cache) do
		cfg.spells[name] = true
	end
end

function Module:Reminder_CheckMeleeSpell()
	for _, cfg in pairs(groups) do
		local depends = cfg.depends
		if depends then
			for _, spellID in pairs(depends) do
				if IsPlayerSpell(spellID) then
					cfg.dependsKnown = true
					break
				end
			end
		end
	end
end

function Module:Reminder_Create(cfg)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(iconSize, iconSize)
	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	frame.Icon:SetTexture(cfg.texture or GetSpellTexture(next(cfg.spells)))
	frame:CreateBorder()
	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetFontObject(K.UIFontOutline)
	frame.text:SetText(L["Lack"])
	frame.text:SetPoint("TOP", frame, "TOP", 1, 15)
	frame:Hide()
	cfg.frame = frame
	tinsert(frames, frame)
end

function Module:Reminder_UpdateAnchor()
	local index, offset = 0, iconSize + 6
	for _, frame in next, frames do
		if frame:IsShown() then
			frame:SetPoint("LEFT", offset * index, 0)
			index = index + 1
		end
	end
	parentFrame:SetWidth(offset * index)
end

function Module:Reminder_OnEvent()
	for _, cfg in pairs(groups) do
		if not cfg.frame then
			Module:Reminder_Create(cfg)
			Module:Reminder_ConvertToName(cfg)
		end
		Module:Reminder_Update(cfg)
	end
	Module:Reminder_UpdateAnchor()
end

function Module:CreateReminder()
	if not groups or not next(groups) then
		return
	end

	if C["Auras"].Reminder then
		if not parentFrame then
			parentFrame = CreateFrame("Frame", nil, UIParent)
			parentFrame:SetPoint("CENTER", -220, 130)
			parentFrame:SetSize(iconSize, iconSize)
		end
		parentFrame:Show()

		Module:Reminder_OnEvent()
		K:RegisterEvent("UNIT_AURA", Module.Reminder_OnEvent, "player")
		K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
		K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
		K:RegisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
		K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
	else
		if parentFrame then
			parentFrame:Hide()
			K:UnregisterEvent("LEARNED_SPELL_IN_TAB", Module.Reminder_CheckMeleeSpell)
			K:UnregisterEvent("UNIT_AURA", Module.Reminder_OnEvent)
			K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
			K:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
			K:UnregisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
			K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
		end
	end
end
