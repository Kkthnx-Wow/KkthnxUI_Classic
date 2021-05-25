local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local dismountString = {
    [ERR_ATTACK_MOUNTED] = true,
    [ERR_NOT_WHILE_MOUNTED] = true,
    [ERR_TAXIPLAYERALREADYMOUNTED] = true,
    [SPELL_FAILED_NOT_MOUNTED] = true,
}

local shapeshiftString = {
    [ERR_CANT_INTERACT_SHAPESHIFTED] = true,
    [ERR_EMBLEMERROR_NOTABARDGEOSET] = true,
    [ERR_MOUNT_SHAPESHIFTED] = true,
    [ERR_NOT_WHILE_SHAPESHIFTED] = true,
    [ERR_NO_ITEMS_WHILE_SHAPESHIFTED] = true,
    [ERR_TAXIPLAYERSHAPESHIFTED] = true,
    [SPELL_FAILED_NOT_SHAPESHIFT] = true,
    [SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED] = true,
    [SPELL_NOT_SHAPESHIFTED] = true,
}

local function SetupAutoDismount(_, ...)
    local _, msg = ...
    if dismountString[msg] then
        Dismount()
    elseif shapeshiftString[msg] then
        if GetShapeshiftForm(true) > 0 then
            CancelShapeshiftForm()
        end
    end
end

function Module:CreateAutoDismount()
	K:RegisterEvent("UI_ERROR_MESSAGE", SetupAutoDismount)
end