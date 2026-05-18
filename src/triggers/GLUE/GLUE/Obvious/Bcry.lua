--[[
    GLUE Trigger: Bcry
    Pattern: X falls to their knees and clutches their ears as the shaft of sound strikes Y
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Track Bcry (battle cry) effect
GLUE.state.PruneStatesWithoutAffliction("sensitivity")