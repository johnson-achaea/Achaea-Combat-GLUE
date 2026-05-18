--[[
    GLUE Trigger: Mickey
    Pattern: X pops a mickey into their mouth
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Track mickey consumption
-- This may cure afflictions, but exact effect depends on game mechanics
