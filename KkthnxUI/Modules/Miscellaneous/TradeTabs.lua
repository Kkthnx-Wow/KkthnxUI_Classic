local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local table_insert = _G.table.insert

local IsPlayerSpell = _G.IsPlayerSpell
local IsCurrentSpell = _G.IsCurrentSpell
local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellInfo = _G.GetSpellInfo
local CreateFrame = _G.CreateFrame
local InCombatLockdown = _G.InCombatLockdown

local myProfessions = {}
local tabList = {}
local CAMPFIRE_ID = 818
local SMELTING_ID = 2656

local tradeList = {
	["Cooking"] = {
		[2550] = true,
		[3102] = true,
		[3413] = true,
		[18260] = true,
	},
	["FistAid"] = {
		[3273] = true,
		[3274] = true,
		[7924] = true,
		[10846] = true,
	},
	["Alchemy"] = {
		[2259] = true,
		[3101] = true,
		[3464] = true,
		[11611] = true,
	},
	["Blacksmithing"] = {
		[2018] = true,
		[3100] = true,
		[3538] = true,
		[9785] = true,
	},
	["Enchanting"] = {
		[7411] = true,
		[7412] = true,
		[7413] = true,
		[13920] = true,
	},
	["Engineering"] = {
		[4036] = true,
		[4037] = true,
		[4038] = true,
		[12656] = true,
	},
	["Leatherworking"] = {
		[2108] = true,
		[3104] = true,
		[3811] = true,
		[10662] = true,
	},
	["Mining"] = {
		[2575] = true,
		[2576] = true,
		[3564] = true,
		[10248] = true,
	},
	["Tailoring"] = {
		[3908] = true,
		[3909] = true,
		[3910] = true,
		[12180] = true,
	},
	["Poisons"] = {
		[2842] = true,
	},
}

function Module:UpdateProfessions()
	for tradeName, list in pairs(tradeList) do
		for spellID in pairs(list) do
			if IsPlayerSpell(spellID) then
				myProfessions[tradeName] = spellID
				break
			end
		end
	end
end

function Module:TradeTabs_Update()
	for _, tab in pairs(tabList) do
		local spellID = tab.spellID
		if IsCurrentSpell(spellID) then
			tab:SetChecked(true)
			tab.cover:Show()
		else
			tab:SetChecked(false)
			tab.cover:Hide()
		end

		local start, duration = GetSpellCooldown(spellID)
		if start and duration and duration > 1.5 then
			tab.CD:SetCooldown(start, duration)
		end
	end
end

local index = 1
function Module:TradeTabs_Create(spellID)
	local name, _, texture = GetSpellInfo(spellID)

	local tab = CreateFrame("CheckButton", nil, TradeSkillFrame, "SpellBookSkillLineTabTemplate, SecureActionButtonTemplate")
	tab.tooltip = name
	tab.spellID = spellID
	tab:SetAttribute("type", "spell")
	tab:SetAttribute("spell", name)
	tab:SetNormalTexture(texture)
	tab:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	tab:Show()

	tab.CD = CreateFrame("Cooldown", nil, tab, "CooldownFrameTemplate")
	tab.CD:SetAllPoints()

	local cover = CreateFrame("Frame", nil, tab)
	cover:SetAllPoints()
	cover:EnableMouse(true)
	tab.cover = cover

	tab:SetPoint("TOPLEFT", TradeSkillFrame, "TOPRIGHT", -33, -70 - (index - 1) * 45)
	table_insert(tabList, tab)
	index = index + 1

	return tab
end

function Module:TradeTabs_OnLoad()
	Module:UpdateProfessions()

	local hasCooking

	for tradeName, spellID in pairs(myProfessions) do
		if tradeName == "Mining" then
			spellID = SMELTING_ID
		elseif tradeName == "Cooking" then
			hasCooking = true
		end

		self:TradeTabs_Create(spellID)
	end

	if hasCooking then
		self:TradeTabs_Create(CAMPFIRE_ID)
	end

	Module:TradeTabs_Update()
	K:RegisterEvent("TRADE_SKILL_SHOW", Module.TradeTabs_Update)
	K:RegisterEvent("TRADE_SKILL_CLOSE", Module.TradeTabs_Update)
	K:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.TradeTabs_Update)
end

function Module.TradeTabs_OnEvent(event, addon)
	if event == "ADDON_LOADED" and addon == "Blizzard_TradeSkillUI" then
		K:UnregisterEvent(event, Module.TradeTabs_OnEvent)
		if InCombatLockdown() then
			K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.TradeTabs_OnEvent)
		else
			Module:TradeTabs_OnLoad()
		end
	elseif event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent(event, Module.TradeTabs_OnEvent)
		Module:TradeTabs_OnLoad()
	end
end

function Module:CreateTradeTabs()
    if not C["Misc"].TradeTabs then
        return
    end

	K:RegisterEvent("ADDON_LOADED", Module.TradeTabs_OnEvent)
end