local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local IsAddOnLoaded = _G.IsAddOnLoaded
local Details = _G.Details

local function ReskinDetails()
	if not IsAddOnLoaded("Details") or not C["Skins"].Details then
		return
	end

	local function setupInstance(instance)
		if instance.styled then
			return
		end

		if not instance.baseframe then
			return
		end

		instance:ChangeSkin("Minimalistic")
		instance:InstanceWallpaper(false)
		instance:DesaturateMenu(true)
		instance:HideMainIcon(false)
		instance:SetBackdropTexture("None")
		instance:MenuAnchor(16, 3)
		instance:ToolbarMenuButtonsSize(1)
		instance:AttributeMenu(true, 0, 3, "KkthnxUI_Normal", 12, {1, 1, 1}, 1, false)
		instance:SetBarSettings(20, KkthnxUIData["ResetDetails"] and "KkthnxUI_Statusbar" or nil)
		instance:SetBarTextSettings(12, "KkthnxUI_Normal", nil, nil, nil, true, true, nil, nil, nil, nil, nil, nil, false, nil, false, nil)

		instance.baseframe:CreateBackdrop()
		instance.baseframe.Backdrop:SetPoint("TOPLEFT", -1, 18)
		instance.baseframe.Backdrop:SetPoint("TOPRIGHT", 1, 0)

		instance.styled = true
	end

	local index = 1
	local instance = Details:GetInstance(index)
	while instance do
		setupInstance(instance)
		index = index + 1
		instance = Details:GetInstance(index)
	end

	-- Reanchor
	local instance1 = Details:GetInstance(1)
	local instance2 = Details:GetInstance(2)

	local function EmbedWindow(instance, x, y, width, height)
		if not instance.baseframe then
			return
		end

		instance.baseframe:ClearAllPoints()
		instance.baseframe:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", x, y)
		instance:SetSize(width, height)
		instance:SaveMainWindowPosition()
		instance:RestoreMainWindowPosition()
		instance:LockInstance(true)
	end

	if KkthnxUIData["ResetDetails"] then
		local height = 126
		if instance1 then
			if instance2 then
				height = 112
				EmbedWindow(instance2, -3, 140, 260, height)
			end
			EmbedWindow(instance1, -320, 4, 260, height)
		end
	end

	local listener = Details:CreateEventListener()
	listener:RegisterEvent("DETAILS_INSTANCE_OPEN")
	function listener:OnDetailsEvent(event, instance)
		if event == "DETAILS_INSTANCE_OPEN" then
			setupInstance(instance)

			if instance:GetId() == 2 then
				instance1:SetSize(260, 112)
				EmbedWindow(instance, -3, 140, 250, 112)
			end
		end
	end

	-- Numberize
	local _detalhes = _G._detalhes
	local current = C["General"].NumberPrefixStyle.Value
	if current < 3 then
		_detalhes.numerical_system = current
		_detalhes:SelectNumericalSystem()
	end

	KkthnxUIData["ResetDetails"] = false
end

table.insert(Module.NewSkin["KkthnxUI"], ReskinDetails)