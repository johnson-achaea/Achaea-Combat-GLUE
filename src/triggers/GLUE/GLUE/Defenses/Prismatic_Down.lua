--[[
    GLUE Trigger: Prismatic Down
    Pattern: Target's prismatic barrier is destroyed
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

GLUE.defenses.Set("prismatic", false)
