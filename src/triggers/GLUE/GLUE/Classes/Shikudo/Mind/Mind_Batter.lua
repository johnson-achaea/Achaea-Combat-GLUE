--[[
    GLUE Trigger: Mind Batter
    Pattern: Thrust out and batter mind, making them reel
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Batter gives stupidity, epilepsy, and dizziness
GLUE.state.AddAffliction("stupidity")
GLUE.state.AddAffliction("epilepsy")
GLUE.state.AddAffliction("dizziness")
