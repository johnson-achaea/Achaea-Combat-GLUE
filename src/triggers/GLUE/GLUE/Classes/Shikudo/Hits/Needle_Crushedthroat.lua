--[[
    GLUE Trigger: Needle (Crushed Throat)
    Pattern: Staff smashes into exposed throat
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Needle gives crushed throat
GLUE.state.AddAffliction("crushedthroat")
