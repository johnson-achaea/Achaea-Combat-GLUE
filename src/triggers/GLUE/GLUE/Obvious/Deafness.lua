--[[
    GLUE Trigger: Deafness
    Multiple patterns showing deafness symptoms
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add deafness affliction
GLUE.state.AddAffliction("deafness")
