--[[
    GLUE Trigger: Beez
    Pattern: The bees sting X into paralysis
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add paralysis affliction from bee stings
GLUE.state.AddAffliction("paralysis")
