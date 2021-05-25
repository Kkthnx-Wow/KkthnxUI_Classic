local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local function FindAutoKeystone()
	-- search for the key in the bags
	for bag = 0, NUM_BAG_SLOTS do
		local slots = GetContainerNumSlots(bag)
		for slot = 1, slots do
			-- check if item at slot is the key
			local item_id = GetContainerItemID(bag, slot)
			if item_id == 180653 or item_id == 158923 or item_id == 151086 then
				-- pickup item and insert it
				PickupContainerItem(bag, slot)
				if (CursorHasItem()) then
					C_ChallengeMode.SlotKeystone()
				end
				return
			end
		end
	end
end

local function SetupAutoKeystone(name)
	if name == "Blizzard_ChallengesUI" then
		ChallengesKeystoneFrame:HookScript("OnShow", FindAutoKeystone)
	end
end

function Module:CreateKeystone()
    if C["Automation"].AutoKeystone then
		return
	end

	if IsAddOnLoaded("Blizzard_ChallengesUI") then
		ChallengesKeystoneFrame:HookScript("OnShow", FindAutoKeystone)
	else
		K:RegisterEvent("ADDON_LOADED", SetupAutoKeystone)
	end
end