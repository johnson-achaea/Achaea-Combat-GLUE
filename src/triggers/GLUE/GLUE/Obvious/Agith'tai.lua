--[[
    GLUE Trigger: Agith'tai
    Pattern: Your mental defences lash out against X
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

GLUE.state.AddAffliction(gmcp.Char.Afflictions.Add.name)