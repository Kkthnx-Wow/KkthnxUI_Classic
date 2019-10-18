--[[
LICENSE
	cargBags: An inventory framework addon for World of Warcraft

	Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

	cargBags is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	cargBags is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with cargBags; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

DESCRIPTION
	An infotext-module which can display several things based on tags.

	Supported tags:
		space - specify a formatstring as arg #1, using "free" / "max" / "used"
		item - count of the item in arg #1 (itemID, itemLink, itemName)
			shards - "sub-tag" of item, displays soul shard info
		ammo - count of ammo slot
		currency - displays the currency with id arg #1
			currencies - displays all tracked currencies
		money - formatted money display

	The space-tag still needs .bags defined in the plugin!
	e.g. tagDisplay.bags = cargBags:ParseBags("backpack+bags")

DEPENDENCIES
	mixins/api-common.lua

CALLBACKS
	:OnTagUpdate(event) - When the tag is updated
]]

local _, ns = ...
local cargBags = ns.cargBags

local _G = _G
local math_floor = _G.math.floor

local CalculateTotalNumberOfFreeBagSlots = _G.CalculateTotalNumberOfFreeBagSlots
local GetBackpackCurrencyInfo = _G.GetBackpackCurrencyInfo
local GetContainerNumFreeSlots = _G.GetContainerNumFreeSlots
local GetItemCount = _G.GetItemCount
local GetItemIcon = _G.GetItemIcon
local GetMoney = _G.GetMoney
local GetNumWatchedTokens = _G.GetNumWatchedTokens

local tagPool, tagEvents, object = {}, {}
local function tagger(tag, ...)
	return object.tags[tag] and object.tags[tag](object, ...) or ""
end

-- Update the space display
local function updater(self, event)
	object = self
	self:SetText(self.tagString:gsub("%[([^%]:]+):?(.-)%]", tagger))

	if (self.OnTagUpdate) then
		self:OnTagUpdate(event)
	end
end

local function setTagString(self, tagString)
	self.tagString = tagString
	for tag in tagString:gmatch("%[([^%]:]+):?.-]") do
		if (self.tagEvents[tag]) then
			for _, event in pairs(self.tagEvents[tag]) do
				self.implementation:RegisterEvent(event, self, updater)
			end
		end
	end
end

cargBags:RegisterPlugin("TagDisplay", function(self, tagString, parent)
	parent = parent or self
	tagString = tagString or ""

	local plugin = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	plugin.implementation = self.implementation
	plugin.SetTagString = setTagString
	plugin.tags = tagPool
	plugin.tagEvents = tagEvents
	plugin.iconValues = "16:16:0:0"
	plugin.forceEvent = function(event) updater(plugin, event) end

	setTagString(plugin, tagString)

	self.implementation:RegisterEvent("BAG_UPDATE", plugin, updater)

	return plugin
end)

local function createIcon(icon, iconValues)
	if (type(iconValues) == "table") then
		iconValues = table.concat(iconValues, ":")
	end

	return ("|T%s:%s|t"):format(icon, iconValues)
end

-- Tags
local function GetNumFreeSlots(name)
	if name == "Main" then
		return CalculateTotalNumberOfFreeBagSlots()
	elseif name == "Bank" then
		local numFreeSlots = GetContainerNumFreeSlots(-1)
		for bagID = 5, 11 do
			numFreeSlots = numFreeSlots + GetContainerNumFreeSlots(bagID)
		end

		return numFreeSlots
	end
end

tagPool["space"] = function(self)
	local string = GetNumFreeSlots(self.__name)

	return string
end

tagPool["item"] = function(self, item)
	local bags = GetItemCount(item, nil)
	local total = GetItemCount(item, true)
	local bank = total-bags

	if (total > 0) then
		return bags..(bank and " ("..bank..")")..createIcon(GetItemIcon(item), self.iconValues)
	end
end

tagPool["currency"] = function(self, id)
	local _, count, icon = GetBackpackCurrencyInfo(id)

	if (count) then
		return count..createIcon(icon, self.iconValues)
	end
end
tagEvents["currency"] = {"CURRENCY_DISPLAY_UPDATE"}

tagPool["currencies"] = function(self)
	local string
	for i = 1, GetNumWatchedTokens() do
		local curr = self.tags["currency"](self, i)
		if (curr) then
			string = (string and string or "")..curr
		end
	end

	return string
end
tagEvents["currencies"] = tagEvents["currency"]

tagPool["money"] = function()
	local money = GetMoney() or 0
	local gold, silver, copper = math_floor(money / 1e4), math_floor(money / 100) % 100, money % 100
	local string

	if (gold > 0) then
		string = (string and string or "")..gold.."|cffffd700"..GOLD_AMOUNT_SYMBOL.."|r "
	end

	if (silver > 0) then
		string = (string and string or "")..silver.."|cffc7c7cf"..SILVER_AMOUNT_SYMBOL.."|r "
	end

	if (copper >= 0) then
		string = (string and string or "")..copper.."|cffeda55f"..COPPER_AMOUNT_SYMBOL.."|r"
	end

	return string
end
tagEvents["money"] = {"PLAYER_MONEY"}