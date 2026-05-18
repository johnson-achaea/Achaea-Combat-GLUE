--[[
    GLUE Trigger: Nausea (Obviously)
    Pattern: Target doubles over, vomiting violently
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add nausea affliction
GLUE.state.PruneStatesWithoutAffliction("nausea")
