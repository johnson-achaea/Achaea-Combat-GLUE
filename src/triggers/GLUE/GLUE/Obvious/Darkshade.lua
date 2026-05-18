--[[
    GLUE Trigger: Darkshade (Obviously)
    Patterns showing darkshade affliction
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add darkshade affliction
GLUE.state.PruneStatesWithoutAffliction("darkshade")
