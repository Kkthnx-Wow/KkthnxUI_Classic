local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local MuteSoundFile = _G.MuteSoundFile
local UnmuteSoundFile = _G.UnmuteSoundFile

-- Website For Looking Up Sounds
-- https://wow.tools/

-- You Can Test Sounds With This Command In-Game
-- /run PlaySoundFile(2006030)

local muteSounds = {
    -- Notifaction Sound When Someone Comes Online?
    567518, -- sound/interface/friendjoin.ogg
}

function Module:CreateMuteSounds()
    for _, soundIDs in ipairs(muteSounds) do
        if C["Misc"].MuteSounds then
		    MuteSoundFile(soundIDs)
        else
            UnmuteSoundFile(soundIDs)
        end
	end
end