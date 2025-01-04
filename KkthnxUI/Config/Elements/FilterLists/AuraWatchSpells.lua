local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("AurasTable")

local UIParent = UIParent

local AuraWatchList = {}
local groups = {
	["Special Aura"] = { "LEFT", 6, "ICON", 30, { "BOTTOMRIGHT", UIParent, "BOTTOM", -160, 432 } },
	["Spell Cooldown"] = { "UP", 6, "BAR", 20, { "BOTTOMRIGHT", UIParent, "BOTTOM", -486, 120 }, 150 },
	["Enchant Aura"] = { "LEFT", 6, "ICON", 36, { "BOTTOMRIGHT", UIParent, "BOTTOM", -160, 468 } },
	["Raid Buff"] = { "LEFT", 6, "ICON", 42, { "CENTER", UIParent, "CENTER", -220, 300 } },
	["Raid Debuff"] = { "RIGHT", 6, "ICON", 42, { "CENTER", UIParent, "CENTER", 220, 300 } },
	["Warning"] = { "RIGHT", 6, "ICON", 36, { "BOTTOMLEFT", UIParent, "BOTTOM", 160, 468 } },
	["InternalCD"] = { "UP", 6, "BAR", 20, { "BOTTOMRIGHT", UIParent, "BOTTOM", -425, 600 }, 150 },
}

local function newAuraFormat(value)
	local newTable = {}
	for _, v in pairs(value) do
		local id = v.AuraID or v.SpellID or v.ItemID or v.SlotID or v.TotemID or v.IntID
		if id then
			newTable[id] = v
		end
	end
	return newTable
end

function Module:AddNewAuraWatch(class, list)
	for _, k in pairs(list) do
		for _, v in pairs(k) do
			local spellID = v.AuraID or v.SpellID
			if spellID then
				local name = GetSpellInfo(spellID)
				if not name then
					wipe(v)
					if K.isDeveloper then
						print(format("|cffFF0000Invalid spellID:|r '%s' %s", class, spellID))
					end
				end
			end
		end
	end

	if class ~= "ALL" and class ~= K.Class then
		return
	end

	if not AuraWatchList[class] then
		AuraWatchList[class] = {}
	end

	for name, v in pairs(list) do
		local direction, interval, mode, size, pos, width = unpack(groups[name])
		tinsert(AuraWatchList[class], {
			Name = name,
			Direction = direction,
			Interval = interval,
			Mode = mode,
			IconSize = size,
			Pos = pos,
			BarWidth = width,
			List = newAuraFormat(v),
		})
	end
end

function Module:OnEnable()
	C.AuraWatchList = AuraWatchList
end
