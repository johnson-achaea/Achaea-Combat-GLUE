--[[
    GLUE Trigger: Epilepsy
    Pattern: X begins to jerk and shake violently, foaming at the mouth
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add epilepsy affliction
GLUE.state.PruneStatesWithoutAffliction("epilepsy")
