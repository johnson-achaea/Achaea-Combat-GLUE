--[[
    GLUE Trigger: Opponent Used Focus
    Pattern: ^A look of extreme focus crosses the face of ([\w'\-]+)\.$

    Captures when target uses focus to cure mental afflictions
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

-- Extract the name from matches
local targetName = matches[2]

-- Only process if this is our target
if not GLUE.IsTarget(targetName) then return end

-- Process focus cure
GLUE.cure.Focus()
