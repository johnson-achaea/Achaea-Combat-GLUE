--[[
    GLUE Trigger: Shield Down
    Pattern: Target's shield is destroyed or lowered
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

GLUE.defenses.Set("shield", false)
