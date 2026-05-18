--[[
    GLUE Trigger: Paralysis
    Multiple patterns showing paralysis symptoms
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add paralysis affliction
GLUE.state.AddAffliction("paralysis")
