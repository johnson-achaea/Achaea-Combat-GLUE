--[[
    GLUE Trigger: Slickness Lost (Obviously)
    Pattern: The protective coating covering the skin of X sloughs off
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = multimatches[2][2]
if not GLUE.IsTarget(targetName) then return end

-- Remove slickness affliction
GLUE.state.PruneStatesWithoutAffliction("slickness")