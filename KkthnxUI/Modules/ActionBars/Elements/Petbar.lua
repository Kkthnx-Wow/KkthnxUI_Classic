local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

local _G = _G
local tinsert = tinsert

local margin = 6

function Module:CreatePetbar()
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBarPet", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Pet Actionbar", "PetBar", { "BOTTOMLEFT", _G.KKUI_ActionBar3, "TOPLEFT", 0, margin })
	Module.movers[10] = frame.mover

	PetActionBarFrame:SetParent(frame)
	PetActionBarFrame:EnableMouse(false)
	SlidingActionBarTexture0:SetTexture(nil)
	SlidingActionBarTexture1:SetTexture(nil)

	for i = 1, num do
		local button = _G["PetActionButton" .. i]
		button:SetParent(frame)
		tinsert(buttonList, button)
		tinsert(Module.buttons, button)

		local hotkey = button.HotKey
		if hotkey then
			hotkey:ClearAllPoints()
			hotkey:SetPoint("TOPRIGHT", 0, -2)
		end
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)
end
