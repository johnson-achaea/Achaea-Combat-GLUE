--[[
    GLUE Trigger: Hiraku (Anorexia + Stuttering)
    Pattern: Staff smashes into face
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Hiraku gives anorexia and stuttering
GLUE.state.AddAffliction("anorexia")
GLUE.state.AddAffliction("stuttering")
