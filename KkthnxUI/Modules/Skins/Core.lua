local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Skins")

local table_wipe = table.wipe

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

-- Tables to store default themes, registered themes and other skins
C.defaultThemes = {}
C.themes = {}
C.otherSkins = {}

-- Function to register a skin for an external addon
function Module:RegisterSkin(addonName, skinFunction)
	C.otherSkins[addonName] = skinFunction
end

-- Function to load skins from a given list
function Module:LoadSkins(skinList)
	if type(skinList) ~= "table" or not next(skinList) then
		return
	end

	for addonName, skinFunction in pairs(skinList) do
		local isLoaded, isFinished = C_AddOns_IsAddOnLoaded(addonName)
		if isLoaded and isFinished then
			if type(skinFunction) == "function" then
				skinFunction()
			end
			skinList[addonName] = nil
		end
	end
end

-- Function to load default skins
function Module:LoadDefaultSkins()
	if C_AddOns_IsAddOnLoaded("AuroraClassic") or C_AddOns_IsAddOnLoaded("Aurora") then
		return
	end

	for _, defaultSkinFunction in pairs(C.defaultThemes) do
		defaultSkinFunction()
	end
	table_wipe(C.defaultThemes)

	if not C["Skins"].BlizzardFrames then
		table_wipe(C.themes)
	end

	Module:LoadSkins(C.themes)
	Module:LoadSkins(C.otherSkins)

	K:RegisterEvent("ADDON_LOADED", function(_, addonName)
		local blizzardSkinFunction = C.themes[addonName]
		if blizzardSkinFunction then
			blizzardSkinFunction()
			C.themes[addonName] = nil
		end

		local otherSkinFunction = C.otherSkins[addonName]
		if otherSkinFunction then
			otherSkinFunction()
			C.otherSkins[addonName] = nil
		end
	end)
end

Module.SharedWindowData = {
	area = "override",
	xoffset = -16,
	yoffset = 12,
	bottomClampOverride = 152,
	width = 714,
	height = 487,
	whileDead = 1,
}

function Module:EnlargeDefaultUIPanel(name, pushed)
	local frame = _G[name]
	if not frame then
		return
	end

	UIPanelWindows[name] = Module.SharedWindowData
	UIPanelWindows[name].pushable = pushed

	frame:SetSize(Module.SharedWindowData.width, Module.SharedWindowData.height)
	frame.TitleText:ClearAllPoints()
	frame.TitleText:SetPoint("TOP", frame, 0, -18)

	frame.scrollFrame:ClearAllPoints()
	frame.scrollFrame:SetPoint("TOPRIGHT", frame, -65, -70)
	frame.scrollFrame:SetPoint("BOTTOMRIGHT", frame, -65, 80)
	frame.listScrollFrame:ClearAllPoints()
	frame.listScrollFrame:SetPoint("TOPLEFT", frame, 19, -70)
	frame.listScrollFrame:SetPoint("BOTTOMLEFT", frame, 19, 80)

	local leftTex = frame:CreateTexture(nil, "BACKGROUND")
	leftTex:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Skins\\UI-QuestLogDualPane-Left")
	leftTex:SetSize(512, 512)
	leftTex:SetPoint("TOPLEFT")

	local rightTex = frame:CreateTexture(nil, "BACKGROUND")
	rightTex:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Skins\\UI-QUESTLOGDUALPANE-RIGHT")
	rightTex:SetSize(256, 512)
	rightTex:SetPoint("TOPLEFT", leftTex, "TOPRIGHT")
end

function Module:OnEnable()
	local loadSkinModules = {
		"LoadDefaultSkins",
		"QuestTracker",
		"ReskinDeadlyBossMods",
		"TradeSkillSkin",
		-- "ReskinBartender4",
		-- "ReskinNekometer",
		-- "ReskinBigWigs",
		-- "ReskinButtonForge",
		-- "ReskinChocolateBar",
		-- "ReskinDominos",
		-- "ReskinRareScanner",
		-- "ReskinSimulationcraft",
	}

	for _, funcName in ipairs(loadSkinModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end
