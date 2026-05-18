--[[
    GLUE Trigger: Hiru (Dizziness)
    Pattern: Staff connects to side of head
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Hiru gives dizziness
GLUE.state.AddAffliction("dizziness")
