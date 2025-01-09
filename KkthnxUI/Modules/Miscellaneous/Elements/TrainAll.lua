local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

-- Tooltip setup for Train All button
local function TrainAllButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(format("%d skills available", self.skillCount), 1, 1, 1)
	GameTooltip:AddLine(format("Total cost: %s", K.FormatMoney(self.totalCost)), 1, 1, 1)
	GameTooltip:Show()
end

-- Function to train all available skills
local function TrainAllSkills()
	for i = 1, GetNumTrainerServices() do
		if select(3, GetTrainerServiceInfo(i)) == "available" then
			BuyTrainerService(i)
		end
	end
end

-- Function to update the Train All button state
local function UpdateTrainAllButton(button)
	local skillCount, totalCost = 0, 0
	for i = 1, GetNumTrainerServices() do
		if select(3, GetTrainerServiceInfo(i)) == "available" then
			skillCount = skillCount + 1
			totalCost = totalCost + GetTrainerServiceCost(i)
		end
	end

	button:SetEnabled(skillCount > 0)
	button.skillCount = skillCount
	button.totalCost = totalCost
end

-- Function to create the Train All button
function Module:CreateTrainAllButton(addon)
	if addon ~= "Blizzard_TrainerUI" then
		return
	end

	local button = CreateFrame("Button", nil, ClassTrainerFrame, "MagicButtonTemplate")
	button:SetAllPoints(ClassTrainerCancelButton)
	button:SetText("Train All")
	button.skillCount = 0
	button.totalCost = 0
	ClassTrainerFrame.TrainAllButton = button

	button:SetScript("OnClick", TrainAllSkills)
	button:SetScript("OnEnter", TrainAllButton_OnEnter)
	button:SetScript("OnLeave", GameTooltip_Hide)

	hooksecurefunc("ClassTrainerFrame_Update", function()
		UpdateTrainAllButton(button)
	end)

	ClassTrainerCancelButton:Hide()
end

-- Function to initialize the Train All feature
function Module:CreateTrainAll()
	if not C["Misc"].TrainAll then
		return
	end

	K:RegisterEvent("ADDON_LOADED", Module.CreateTrainAllButton)
end

Module:RegisterMisc("Train All", Module.CreateTrainAll)
