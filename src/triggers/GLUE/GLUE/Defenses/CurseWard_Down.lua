--[[
    GLUE Trigger: CurseWard Down
    Pattern: Target's curseward is shattered
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

GLUE.defenses.Set("curseward", false)
