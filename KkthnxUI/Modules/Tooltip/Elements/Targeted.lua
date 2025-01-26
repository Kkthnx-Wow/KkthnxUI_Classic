local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Tooltip")

local wipe, tinsert, tconcat = table.wipe, table.insert, table.concat
local IsInGroup, IsInRaid, GetNumGroupMembers = IsInGroup, IsInRaid, GetNumGroupMembers
local UnitExists, UnitIsUnit, UnitIsDeadOrGhost, UnitName = UnitExists, UnitIsUnit, UnitIsDeadOrGhost, UnitName

local GameTooltip = GameTooltip
local targetTable = {}

function Module:ScanTargets()
	if not C["Tooltip"].TargetBy then
		return
	end

	if not IsInGroup() then
		return
	end

	local isInRaid = IsInRaid()
	local _, unit = self:GetUnit()
	if not UnitExists(unit) then
		return
	end

	wipe(targetTable)

	for i = 1, GetNumGroupMembers() do
		local member = (isInRaid and "raid" .. i or "party" .. i)
		if UnitIsUnit(unit, member .. "target") and not UnitIsUnit(member, "player") and not UnitIsDeadOrGhost(member) then
			local color = K.RGBToHex(K.UnitColor(member))
			local name = color .. UnitName(member) .. "|r"
			tinsert(targetTable, name)
		end
	end

	if #targetTable > 0 then
		local text = L["Targeted By"] .. K.InfoColor .. "(" .. #targetTable .. ")|r " .. tconcat(targetTable, ", ")
		GameTooltip:AddLine(text, nil, nil, nil, 1)
	end
end

function Module:CreateTargetedInfo()
	GameTooltip:HookScript("OnTooltipSetUnit", Module.ScanTargets)
end
