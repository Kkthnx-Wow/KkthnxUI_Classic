local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

local tinsert = tinsert

local margin, padding = 6, 0
local num = NUM_STANCE_SLOTS or 10

-- Update the stance bar's size, layout, and button positions
function Module:UpdateStanceBar()
	if InCombatLockdown() then
		return
	end

	local frame = _G["KKUI_ActionBarStance"]
	if not frame then
		return
	end

	local size = C["ActionBar"].BarStanceSize
	local fontSize = C["ActionBar"].BarStanceFont
	local perRow = C["ActionBar"].BarStancePerRow
	local column = math.min(num, perRow)
	local rows = math.ceil(num / perRow)
	local buttons = frame.buttons
	local button, buttonX, buttonY

	for i = 1, num do
		button = buttons[i]
		if not button then
			break
		end

		button:SetSize(size, size)
		buttonX = ((i - 1) % perRow) * (size + margin) + padding
		buttonY = math.floor((i - 1) / perRow) * (size + margin) + padding
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonX, -buttonY)
		Module:UpdateFontSize(button, fontSize)
	end

	frame:SetWidth(column * size + (column - 1) * margin + 2 * padding)
	frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
	frame.mover:SetSize(size, size)
end

function Module:CreateStancebar()
	local buttonList = {}
	local frame = CreateFrame("Frame", "KKUI_ActionBarStance", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "StanceBar", "StanceBar", { "BOTTOMLEFT", _G.KKUI_ActionBar3, "TOPLEFT", 0, margin })
	Module.movers[11] = frame.mover

	-- StanceBar
	StanceBarFrame:SetParent(frame)
	StanceBarFrame:EnableMouse(false)
	StanceBarLeft:SetTexture(nil)
	StanceBarMiddle:SetTexture(nil)
	StanceBarRight:SetTexture(nil)

	for i = 1, num do
		local button = _G["StanceButton" .. i]
		button:SetParent(frame)
		tinsert(buttonList, button)
		tinsert(Module.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", not C["ActionBar"].ShowStance and "hide" or frame.frameVisibility)
end
