local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Tooltip")

local GetNumSkillLines = GetNumSkillLines
local GetSkillLineInfo = GetSkillLineInfo

-- Local variables
local lastTooltipText = ""
local tradeSkills = {}
local nodeNameList = {}
local shiftIsDown = false
local updateScheduled = false
local isTooltipHooked = false

-- Constants for colors
local COLOR_CODES = {
	GRAY = COMMON_GRAY_COLOR_CODE,
	GREEN = GREEN_FONT_COLOR_CODE,
	YELLOW = YELLOW_FONT_COLOR_CODE,
	ORANGE = ORANGE_FONT_COLOR_CODE,
	RED = RED_FONT_COLOR_CODE,
}

-- Node data structure
local NODE_LIST = {
	{ name = "Peacebloom", skill = 1, type = "Herbalism" },
	{ name = "Silverleaf", skill = 1, type = "Herbalism" },
	{ name = "Earthroot", skill = 15, type = "Herbalism" },
	{ name = "Mageroyal", skill = 50, type = "Herbalism" },
	{ name = "Briarthorn", skill = 70, type = "Herbalism" },
	{ name = "Stranglekelp", skill = 85, type = "Herbalism" },
	{ name = "Bruiseweed", skill = 100, type = "Herbalism" },
	{ name = "Wild Steelbloom", skill = 115, type = "Herbalism" },
	{ name = "Grave Moss", skill = 120, type = "Herbalism" },
	{ name = "Kingsblood", skill = 125, type = "Herbalism" },
	{ name = "Liferoot", skill = 150, type = "Herbalism" },
	{ name = "Fadeleaf", skill = 160, type = "Herbalism" },
	{ name = "Goldthorn", skill = 170, type = "Herbalism" },
	{ name = "Khadgar's Whisker", skill = 185, type = "Herbalism" },
	{ name = "Wintersbite", skill = 195, type = "Herbalism" },
	{ name = "Firebloom", skill = 205, type = "Herbalism" },
	{ name = "Purple Lotus", skill = 210, type = "Herbalism" },
	{ name = "Arthas' Tears", skill = 220, type = "Herbalism" },
	{ name = "Sungrass", skill = 230, type = "Herbalism" },
	{ name = "Blindweed", skill = 235, type = "Herbalism" },
	{ name = "Ghost Mushroom", skill = 245, type = "Herbalism" },
	{ name = "Gromsblood", skill = 250, type = "Herbalism" },
	{ name = "Golden Sansam", skill = 260, type = "Herbalism" },
	{ name = "Dreamfoil", skill = 270, type = "Herbalism" },
	{ name = "Mountain Silversage", skill = 280, type = "Herbalism" },
	{ name = "Plaguebloom", skill = 285, type = "Herbalism" },
	{ name = "Icecap", skill = 290, type = "Herbalism" },
	{ name = "Black Lotus", skill = 300, type = "Herbalism" },
	{ name = "Arcanite Lode", skill = 310, type = "Mining" },
	{ name = "Ooze Covered Arcanite Lode", skill = 310, type = "Mining" },
	{ name = "Rich Thorium Vein", skill = 275, type = "Mining" },
	{ name = "Ooze Covered Rich Thorium Vein", skill = 275, type = "Mining" },
	{ name = "Ooze Covered Thorium Vein", skill = 245, type = "Mining" },
	{ name = "Small Thorium Vein", skill = 245, type = "Mining" },
	{ name = "Dark Iron Deposit", skill = 230, type = "Mining" },
	{ name = "Ooze Covered Truesilver Deposit", skill = 230, type = "Mining" },
	{ name = "Truesilver Deposit", skill = 230, type = "Mining" },
	{ name = "Ooze Covered Mithril Deposit", skill = 175, type = "Mining" },
	{ name = "Mithril Deposit", skill = 175, type = "Mining" },
	{ name = "Ooze Covered Gold Vein", skill = 155, type = "Mining" },
	{ name = "Gold Vein", skill = 155, type = "Mining" },
	{ name = "Indurium Mineral Vein", skill = 150, type = "Mining" },
	{ name = "Iron Deposit", skill = 125, type = "Mining" },
	{ name = "Ooze Covered Iron Deposit", skill = 100, type = "Mining" },
	{ name = "Lesser Bloodstone Deposit", skill = 75, type = "Mining" },
	{ name = "Silver Vein", skill = 75, type = "Mining" },
	{ name = "Ooze Covered Silver Vein", skill = 75, type = "Mining" },
	{ name = "Incendicite Mineral Vein", skill = 65, type = "Mining" },
	{ name = "Tin Vein", skill = 65, type = "Mining" },
	{ name = "Small Obsidian Chunk", skill = 1, type = "Mining" },
	{ name = "Large Obsidian Chunk", skill = 1, type = "Mining" },
	{ name = "Copper Vein", skill = 1, type = "Mining" },
}

-- Helper functions
local function SplitString(s, delimiter)
	local result = {}
	for match in (s .. delimiter):gmatch("(.-)" .. delimiter) do
		table.insert(result, match)
	end
	return result
end

local function IsValidNode(nodeName)
	for key in pairs(nodeNameList) do
		if string.find(nodeName, key, 1, true) then
			return key
		end
	end
	return nil
end

local function GetNodeInfo(nodeName)
	for _, node in pairs(NODE_LIST) do
		if node.name == nodeName then
			return node
		end
	end
	return nil
end

local function CheckShiftState()
	local shiftChanged = false
	if IsShiftKeyDown() and not shiftIsDown then
		shiftIsDown = true
		shiftChanged = true
	elseif not IsShiftKeyDown() and shiftIsDown then
		shiftIsDown = false
		shiftChanged = true
	end
	return shiftChanged
end

local function GetSkillColor(nodeSkill, skillRank)
	local diff = skillRank - nodeSkill
	if diff < 0 then
		return COLOR_CODES.RED
	end
	if diff >= 100 then
		return COLOR_CODES.GRAY
	end
	if diff >= 50 then
		return COLOR_CODES.GREEN
	end
	if diff >= 25 then
		return COLOR_CODES.YELLOW
	end
	return COLOR_CODES.ORANGE
end

local function IsRelevantTooltip(frame)
	local owner = frame:GetOwner()
	if owner then
		local ownerName = owner:GetName()
		return ownerName == "Minimap"
	end
	return false
end

local function GetSkillInfo(skillName)
	local index = tradeSkills[skillName]
	if index then
		local name, _, _, rank, _, _, maxRank = GetSkillLineInfo(index)
		return { name = name, rank = rank, max = maxRank }
	end
	return nil
end

-- Debounced update
local function UpdateTradeSkills()
	tradeSkills = {}
	nodeNameList = {}
	for i = 1, GetNumSkillLines() do
		local name = GetSkillLineInfo(i)
		tradeSkills[name] = i
		for _, node in ipairs(NODE_LIST) do
			if node.type == name then
				nodeNameList[node.name] = true
			end
		end
	end
end

local function UpdateTradeSkillsIfNeeded()
	if not updateScheduled then
		updateScheduled = true
		C_Timer.After(0.1, function()
			UpdateTradeSkills()
			updateScheduled = false
		end)
	end
end

local function SkillChatFilter(_, _, msg, author, ...)
	if string.find(msg, "Your skill in") then
		local name = string.match(msg, "Your skill in (.+) has increased")
		local skillInfo = GetSkillInfo(name)
		if skillInfo then
			local color = "GREEN"
			if skillInfo.rank >= skillInfo.max then
				color = "RED"
			elseif skillInfo.rank >= skillInfo.max - 15 then
				color = "ORANGE"
			elseif skillInfo.rank >= skillInfo.max - 50 then
				color = "YELLOW"
			end

			local newMsg = string.gsub(msg, "(%d+)", COLOR_CODES[color] .. skillInfo.rank .. " / " .. skillInfo.max .. "|r")
			return false, newMsg, author, ...
		end
	end
end

local function UpdateTooltip(self)
	local text = _G[self:GetName() .. "TextLeft1"]:GetText()
	if text ~= lastTooltipText or CheckShiftState() then
		lastTooltipText = text
		local lines = SplitString(text, "\n")
		local newText = ""
		for _, line in ipairs(lines) do
			local nodeName = IsValidNode(line)
			if nodeName then
				local nodeInfo = GetNodeInfo(nodeName)
				local skillInfo = GetSkillInfo(nodeInfo.type)
				if skillInfo then
					local color = GetSkillColor(nodeInfo.skill, skillInfo.rank)
					newText = newText .. color .. nodeName
					if IsShiftKeyDown() then
						newText = newText .. " (" .. skillInfo.rank .. " / " .. nodeInfo.skill .. ")"
					end
					newText = newText .. "|r\n"
				end
			end
		end

		if newText ~= "" then
			_G[self:GetName() .. "TextLeft1"]:SetText(string.sub(newText, 1, -4)) -- remove trailing |r and newline
		end
	end
end

-- Hooking function with safety checks
local function HookTooltip()
	if not isTooltipHooked and not InCombatLockdown() and not GameTooltip:IsForbidden() then
		isTooltipHooked = true

		GameTooltip:HookScript("OnUpdate", function(self)
			if IsRelevantTooltip(self) and not InCombatLockdown() then
				UpdateTooltip(self)
			end
		end)

		GameTooltip:HookScript("OnShow", function(self)
			if IsRelevantTooltip(self) and not InCombatLockdown() then
				UpdateTooltip(self)
			end
		end)
	end
end

-- Main function to set up node info
function Module:CreateNodeInfo()
	if not C["Tooltip"].ShowNodeInfo then
		return
	end

	UpdateTradeSkillsIfNeeded()

	-- Hook the tooltip methods
	HookTooltip()

	-- Register chat event filter
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SKILL", SkillChatFilter)

	-- Register for skill changes
	K:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateTradeSkillsIfNeeded)
	K:RegisterEvent("LEARNED_SPELL_IN_TAB", UpdateTradeSkillsIfNeeded)
end
