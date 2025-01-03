local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

-- Function to build buffs to thank for
local function BuildBuffsToThank(spellList)
	local buffsToThank = {}
	for _, spellID in ipairs(spellList) do
		local spellName = GetSpellInfo(spellID)
		if spellName then
			buffsToThank[spellName] = true
		end
	end

	return buffsToThank
end

local spellList = {
	-- Druid
	1126, -- Mark of the Wild

	-- Mage
	1459, -- Arcane Intellect

	-- Priest
	1243, -- Power Word: Fortitude

	-- Paladin
	19740, -- Blessing of Might
	19742, -- Blessing of Wisdom
	20217, -- Blessing of Kings

	-- Warlock
	5697, -- Unending Breath
}

local buffsToThank = BuildBuffsToThank(spellList)

-- Create a table to track cooldowns for each caster
local lastThanked = {}

function Module:SetupAutoBuffThanks()
	-- Get combat log details
	local _, subEvent, _, _, sourceName, _, _, _, destName, _, _, spellID = CombatLogGetCurrentEventInfo()

	-- Ensure the destination is exactly the player and the event is relevant
	if destName == K.Name and (subEvent == "SPELL_CAST_SUCCESS" or subEvent == "SPELL_AURA_APPLIED") then
		-- Fetch the buff name
		local spellName = GetSpellInfo(spellID)

		-- Check if the spell is in our thank list
		if buffsToThank[spellName] then
			-- Get the current time
			local currentTime = GetTime()

			-- Check if we have already thanked this player within the cooldown period
			if not lastThanked[sourceName] or (currentTime - lastThanked[sourceName]) > 60 then
				-- Randomize the delay between 1-2 seconds
				local delay = math.random(1, 20) / 10 -- Generates 1.0 to 2.0 seconds

				-- Delay the thank-you emote
				C_Timer.After(delay, function()
					-- print("Thanking", sourceName, "for buff", spellName, "(Spell ID:", spellID, ")", "after", delay, "seconds")
					DoEmote("THANK", sourceName)
				end)

				-- Update the cooldown tracker
				lastThanked[sourceName] = currentTime
			else
				-- print("Cooldown active. Not thanking", sourceName)
			end
		else
			-- -- Spell is not in the thank list
			-- print("Buff not in the thank list!")
			-- print("Source:", sourceName, "Buff:", spellName, "(Spell ID:", spellID, ")")
			-- print("Consider adding this buff to your thank list. Tell the developer.")
		end
	end
end

function Module:CreateAutoBuffThanks()
	if C["Automation"].BuffThanks then
		K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.SetupAutoBuffThanks)
	else
		K:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Module.SetupAutoBuffThanks)
	end
end
