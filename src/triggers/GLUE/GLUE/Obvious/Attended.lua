--[[
    GLUE Trigger: Attended
    Pattern: X glows with an emerald hue and snaps their fingers at Y
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Track attended action
-- Exact effect depends on game mechanics
