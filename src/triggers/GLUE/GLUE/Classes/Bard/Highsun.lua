-- Pattern: ^With a flourish of .+ you step smoothly into \w+, your blade slicing at \w+ (.+)\.$
-- matches[2] = body part ("head", "left arm", "right arm")
if not GLUE or not GLUE.bard then return end

local part = matches[2]
local pos  = GLUE.bard.position

if part == "head" then
    if pos == "front" then
        GLUE.state.AddSmartAffliction({"clumsiness", "weariness", "recklessness"})
    elseif pos == "side" then
        GLUE.state.AddSmartAffliction({"addiction", "generosity", "confusion"})
    elseif pos == "back" then
        GLUE.state.AddSmartAffliction({"paralysis", "generosity", "diminished"})
    end
elseif part == "left arm" or part == "right arm" then
    if pos == "front" then
        GLUE.state.AddSmartAffliction({"clumsiness", "weariness", "haemophilia"})
    elseif pos == "side" then
        GLUE.state.AddSmartAffliction({"weariness", "clumsiness", "healthleech"})
    elseif pos == "back" then
        GLUE.state.AddSmartAffliction({"paralysis", "healthleech", "sensitivity"})
    end
end

GLUE.bard.OnHit()
