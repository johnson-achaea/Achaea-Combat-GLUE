--[[
    GLUE Trigger: Rebounding Down
    Pattern: Target's rebounding is stripped
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

GLUE.defenses.Set("rebounding", false)
