-- Pattern: ^With a flourish of .+ you step smoothly into \w+, your blade slicing at \w+ (.+)\.$
-- matches[2] = body part ("head", "left arm", "right arm")
if not GLUE or not GLUE.bard then return end

local part = matches[2]
local pos  = GLUE.bard.position

if part == "head" then
    if pos == "front" then
        if GLUE.state.GetProbability("clumsiness") < 100 then
            GLUE.state.AddAffliction("clumsiness")
        elseif GLUE.state.GetProbability("weariness") < 100 then
            GLUE.state.AddAffliction("weariness")
        else
            GLUE.state.AddAffliction("recklessness")
        end
    elseif pos == "side" then
        if GLUE.state.GetProbability("addiction") < 100 then
            GLUE.state.AddAffliction("addiction")
        elseif GLUE.state.GetProbability("generosity") < 100 then
            GLUE.state.AddAffliction("generosity")
        else
            GLUE.state.AddAffliction("confusion")
        end
    elseif pos == "back" then
        if GLUE.state.GetProbability("paralysis") < 100 then
            GLUE.state.AddAffliction("paralysis")
        elseif GLUE.state.GetProbability("generosity") < 100 then
            GLUE.state.AddAffliction("generosity")
        else
            GLUE.state.AddAffliction("diminished")
        end
    end
elseif part == "left arm" or part == "right arm" then
    if pos == "front" then
        if GLUE.state.GetProbability("clumsiness") < 100 then
            GLUE.state.AddAffliction("clumsiness")
        elseif GLUE.state.GetProbability("weariness") < 100 then
            GLUE.state.AddAffliction("weariness")
        else
            GLUE.state.AddAffliction("haemophilia")
        end
    elseif pos == "side" then
        if GLUE.state.GetProbability("weariness") < 100 then
            GLUE.state.AddAffliction("weariness")
        elseif GLUE.state.GetProbability("clumsiness") < 100 then
            GLUE.state.AddAffliction("clumsiness")
        else
            GLUE.state.AddAffliction("healthleech")
        end
    elseif pos == "back" then
        if GLUE.state.GetProbability("paralysis") < 100 then
            GLUE.state.AddAffliction("paralysis")
        elseif GLUE.state.GetProbability("healthleech") < 100 then
            GLUE.state.AddAffliction("healthleech")
        else
            GLUE.state.AddAffliction("sensitivity")
        end
    end
end

GLUE.bard.OnHit()
