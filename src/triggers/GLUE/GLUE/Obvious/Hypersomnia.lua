--[[
    GLUE Trigger: Hypersomnia
    Pattern: X suddenly appears tired all of a sudden
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add hypersomnia affliction
GLUE.state.AddAffliction("hypersomnia")
