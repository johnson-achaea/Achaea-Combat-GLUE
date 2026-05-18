--[[
    GLUE Trigger: Awake (Obviously)
    Patterns showing target waking up
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Remove asleep affliction
GLUE.state.RemoveAffliction("asleep")
