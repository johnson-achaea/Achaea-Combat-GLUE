--[[
    GLUE Trigger: Mind Impatience
    Pattern: Fill mind with impatient feeling
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Mind impatience gives impatience
GLUE.state.AddAffliction("impatience")
