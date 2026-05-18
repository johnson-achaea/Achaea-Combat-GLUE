--[[
    GLUE Trigger: Mind Paralysis
    Pattern: Reach out with mind and paralyse
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Mind paralysis gives paralysis
GLUE.state.AddAffliction("paralysis")
