--[[
    GLUE Trigger: Trample
    Pattern: Target's limb is crushed by trample
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

local affGiven = "broken"..matches[3]..matches[4]
GLUE.state.AddAffliction("prone")
Glue.state.AddAffliction(affGiven)