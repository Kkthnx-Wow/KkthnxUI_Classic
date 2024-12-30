local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Bags")

local table_wipe = table.wipe

local C_Container_GetContainerItemInfo = C_Container.GetContainerItemInfo
local C_Container_GetContainerNumSlots = C_Container.GetContainerNumSlots
local C_Container_UseContainerItem = C_Container.UseContainerItem
local IsShiftKeyDown = IsShiftKeyDown

local sellStop = true -- Flag to stop the selling process
local sellCache = {} -- Table to store items that have already been processed
local sellCount = 0 -- Counter for the amount of money earned
local sellError = ERR_VENDOR_DOESNT_BUY -- Error message for when the vendor doesn't buy certain items

local function stopSelling(results)
	sellStop = true
	if sellCount > 0 and results then
		K.Print(format(K.SystemColor .. "%s|r%s", "You have sold junk items for", K.FormatMoney(sellCount)))
	end
	sellCount = 0
end

local function startSelling()
	if sellStop then
		return
	end

	for bag = 0, 4 do
		for slot = 1, C_Container_GetContainerNumSlots(bag) do
			if sellStop then
				return
			end

			local info = C_Container_GetContainerItemInfo(bag, slot)
			if info then
				local quality, link, noValue, itemID = info.quality, info.hyperlink, info.hasNoValue, info.itemID
				if link and not noValue and (quality == 0 or KkthnxUIDB.Variables[K.Realm][K.Name].CustomJunkList[itemID]) and not sellCache["b" .. bag .. "s" .. slot] then
					sellCache["b" .. bag .. "s" .. slot] = true
					C_Container_UseContainerItem(bag, slot)
					K.Delay(0.15, startSelling)
					return
				end
			end
		end
	end
end

local function updateAutoSell(event, ...)
	if not C["Inventory"].AutoSell then
		return
	end

	local _, arg = ...
	if event == "MERCHANT_SHOW" then
		if IsShiftKeyDown() then
			return
		end

		sellStop = false
		table_wipe(sellCache)
		startSelling()
		K:RegisterEvent("UI_ERROR_MESSAGE", updateAutoSell)
	elseif event == "UI_ERROR_MESSAGE" and arg == sellError then
		stopSelling(false)
	elseif event == "MERCHANT_CLOSED" then
		stopSelling(true)
	end
end

function Module:CreateAutoSell()
	K:RegisterEvent("MERCHANT_SHOW", updateAutoSell)
	K:RegisterEvent("MERCHANT_CLOSED", updateAutoSell)
end
