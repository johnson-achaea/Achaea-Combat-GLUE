--[[
    GLUE Trigger: Ruku (Slickness)
    Pattern: Staff cracks across ribs, sweat breaking out
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Ruku gives slickness
GLUE.state.AddAffliction("slickness")
