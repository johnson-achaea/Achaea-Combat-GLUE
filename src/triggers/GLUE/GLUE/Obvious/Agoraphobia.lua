--[[
    GLUE Trigger: Agoraphobia
    Pattern: X is gripped with fear, staring out with terrified eyes
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add agoraphobia affliction
GLUE.state.PruneStatesWithoutAffliction("agoraphobia")
