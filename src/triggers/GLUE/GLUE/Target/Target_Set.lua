--[[
    GLUE Trigger: Target Set
    Pattern: "Your target is now: (name) (an adventurer)"

    Handles target switching with state persistence
]]--

if not GLUE or not GLUE.target then return end

local targetName = matches[2]

if not targetName then return end

-- Switch to new target (saves old, loads new)
GLUE.target.SetTarget(targetName)
