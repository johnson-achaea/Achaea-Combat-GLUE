--[[
    GLUE Trigger: Infestation
    Pattern: You sense through your malignant connection to your infestation that X has been cursed with Y
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
local affliction = matches[3]

if not GLUE.IsTarget(targetName) then return end

-- Add the affliction detected via infestation
GLUE.state.AddAffliction(affliction)
