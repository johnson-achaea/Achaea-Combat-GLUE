--[[
    GLUE Trigger: Blindness
    Pattern: X blinks slowly, and begins to tremble
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add blindness affliction
GLUE.state.AddAffliction("blindness")
