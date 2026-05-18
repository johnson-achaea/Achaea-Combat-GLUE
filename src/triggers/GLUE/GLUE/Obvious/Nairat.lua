--[[
    GLUE Trigger: Nairat
    Pattern: Ethereal bonds flash forth to bind X as their gaze falls upon a nairat rune
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add nairat affliction (likely entanglement or binding)
GLUE.state.AddAffliction("entangled")
