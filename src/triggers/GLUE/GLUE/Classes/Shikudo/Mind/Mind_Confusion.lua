--[[
    GLUE Trigger: Mind Confusion
    Pattern: Direct powerful pulse, throwing mind into chaos
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Mind confusion gives confusion
GLUE.state.AddAffliction("confusion")
