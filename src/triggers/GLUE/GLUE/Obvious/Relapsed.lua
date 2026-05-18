--[[
    GLUE Trigger: Relapsed
    Pattern: X screams out in agony, struck by the effects of a vicious venom
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Track relapse effect - venom reactivation
-- Exact affliction depends on which venom relapsed
