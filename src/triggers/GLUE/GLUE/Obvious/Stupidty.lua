--[[
    GLUE Trigger: Stupidity (Obviously)
    Multiple patterns showing stupidity symptoms
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add stupidity affliction
GLUE.state.PruneStatesWithoutAffliction("stupidity")
