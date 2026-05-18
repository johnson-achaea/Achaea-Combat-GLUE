--[[
    GLUE Trigger: Clumsiness
    Multiple patterns showing clumsiness symptoms
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add clumsiness affliction
GLUE.state.PruneStatesWithoutAffliction("clumsiness")
