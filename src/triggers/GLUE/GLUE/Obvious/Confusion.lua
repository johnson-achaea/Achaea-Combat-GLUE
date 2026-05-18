--[[
    GLUE Trigger: Confusion (Obviously)
    Pattern: Target looks about bemusedly
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add confusion affliction
GLUE.state.AddAffliction("confusion")
