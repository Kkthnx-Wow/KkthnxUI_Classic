local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Constants
local BAG_FULL_MESSAGE_THROTTLE = 10 -- Time in seconds between "Bag Full" messages
local LOOT_DELAY = 0.5 -- Reduced delay for quicker response

-- Variables
local lastBagFullMessageTime = 0
local isItemProcessing = false
local lastWindowState = true
local lastLootActionTime = 0

-- Utility Function: Check if any UI window is open
local function IsAnyWindowOpen()
	local framesToCheck = {
		AuctionFrame,
		BankFrame,
		ContainerFrame1,
		ContainerFrame2,
		ContainerFrame3,
		ContainerFrame4,
		ContainerFrame5,
		CraftFrame,
		GossipFrame,
		LootFrame,
		MailFrame,
		MerchantFrame,
		ReagentBankFrame,
		TradeFrame,
		TradeSkillFrame,
	}

	for _, frame in ipairs(framesToCheck) do
		if frame and frame:IsVisible() then
			local currentWindowState = true
			if lastWindowState ~= currentWindowState then
				print("Window state changed from", lastWindowState, "to", currentWindowState)
			end
			lastWindowState = currentWindowState
			return true
		end
	end
	lastWindowState = false

	return false
end

-- Utility Function: Check available bag space, only includes generic bags
local function GetAvailableBagSlots()
	local freeSlots = 0
	local totalSlots = 0

	for bagID = Enum.BagIndex.Backpack, NUM_BAG_SLOTS do
		local slots, bagType = C_Container.GetContainerNumFreeSlots(bagID)
		local slotsTotal = C_Container.GetContainerNumSlots(bagID)

		-- Check if the bag is a generic bag (bagType == 0)
		if bagID == Enum.BagIndex.Backpack or (GetInventoryItemLink("player", C_Container.ContainerIDToInventoryID(bagID)) and bagType == 0) then
			freeSlots = freeSlots + slots
			totalSlots = totalSlots + slotsTotal
		end
	end

	return freeSlots, totalSlots
end

-- Process openable items in the bags
local function ProcessBagItems()
	if isItemProcessing or UnitAffectingCombat("player") then
		-- print("Item processing or in combat, skipping.") -- Debug
		return
	end

	isItemProcessing = true
	-- print("Starting item processing.") -- Debug

	if IsAnyWindowOpen() then
		-- print("UI window open, stopping item processing.") -- Debug
		isItemProcessing = false
		return
	end

	local freeSlots = GetAvailableBagSlots()
	-- print("Total Free Slots:", freeSlots) -- Debug output

	if freeSlots < 4 then
		local currentTime = GetTime()
		if currentTime - lastBagFullMessageTime > BAG_FULL_MESSAGE_THROTTLE then
			print("|cff4FC3F7AutoOpenItems|r : Paused until you have at least 4 free bag spaces.")
			lastBagFullMessageTime = currentTime
		end
		-- print("Not enough free slots, stopping.") -- Debug
		isItemProcessing = false
		return
	end

	local itemsProcessed = 0
	for bag = 0, 4 do
		local numSlots = C_Container.GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local itemInfo = C_Container.GetContainerItemInfo(bag, slot)
			if itemInfo and C.AutoOpenItems[itemInfo.itemID] then
				-- print("Processing item:", itemInfo.itemID, "in bag:", bag, "slot:", slot) -- Debug
				C_Container.UseContainerItem(bag, slot)
				itemsProcessed = itemsProcessed + 1
				C_Timer.After(LOOT_DELAY, ProcessBagItems)
				isItemProcessing = false
				-- print("Processed", itemsProcessed, "items.") -- Debug
				return
			end
		end
	end

	if itemsProcessed == 0 then
		-- print("No items processed this cycle.") -- Debug
	end
	isItemProcessing = false
	-- print("Finished item processing.") -- Debug
end

-- Event Handlers
function Module:BAG_UPDATE()
	local function checkSlots()
		local slots = GetAvailableBagSlots()
		-- print("BAG_UPDATE event triggered. Available slots:", slots)
		ProcessBagItems()
	end

	C_Timer.After(0.1, checkSlots)
end

function Module:LOOT_OPENED()
	-- print("LOOT_OPENED event triggered.")
	ProcessBagItems()
end

function Module:PLAYER_REGEN_ENABLED()
	-- print("PLAYER_REGEN_ENABLED event triggered.")
	ProcessBagItems()
end

function Module:LOOT_READY()
	if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
		local currentTime = GetTime()
		if (currentTime - lastLootActionTime) >= LOOT_DELAY then
			-- print("LOOT_READY event triggered, looting items.")
			for i = GetNumLootItems(), 1, -1 do
				LootSlot(i)
			end
			lastLootActionTime = currentTime
		else
			-- print("LOOT_READY event too soon after last action, skipping.")
		end
	else
		-- print("LOOT_READY event ignored due to auto-loot settings.")
	end
end

-- Module Init
function Module:CreateAutoOpenItems()
	if not C["Automation"].AutoOpenItems then
		-- print("AutoOpenItems disabled in configuration.") -- Debug
		return
	end

	K:RegisterEvent("BAG_UPDATE", self.BAG_UPDATE)
	K:RegisterEvent("LOOT_OPENED", self.LOOT_OPENED)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", self.PLAYER_REGEN_ENABLED)
	K:RegisterEvent("LOOT_READY", self.LOOT_READY)

	-- Monitor Window States to Trigger Item Processing
	local monitorFrame = CreateFrame("Frame")
	monitorFrame:SetScript("OnUpdate", function()
		local currentWindowState = IsAnyWindowOpen()
		if lastWindowState and not currentWindowState then
			-- print("Window closed, resuming item processing.")
			ProcessBagItems()
		end
	end)
	-- print("AutoOpenItems module initialized.") -- Debug
end
