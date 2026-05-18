--[[
    GLUE Trigger: Paranoia
    Pattern: The raven dives at X and pulls up short, making them uneasy
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add paranoia affliction
GLUE.state.AddAffliction("paranoia")
