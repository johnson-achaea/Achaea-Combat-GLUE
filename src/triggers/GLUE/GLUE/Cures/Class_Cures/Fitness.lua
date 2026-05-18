--[[
    GLUE Trigger: Fitness
    Pattern: Fitness cures asthma specifically
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end
GLUE.util.PruneWith("weakness")

-- Fitness specifically cures asthma
GLUE.state.RemoveAffliction("asthma")

if GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Asthma cured by fitness")
end
