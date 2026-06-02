-- Pattern: ^You dart out .+ in a lightning-fast jab to the (.+) of \w+\.$
-- matches[2] = body part
if not GLUE or not GLUE.bard then return end

local part = matches[2]
local pos  = GLUE.bard.position

if part == "torso" then
    if pos == "front" then
        GLUE.state.AddAffliction("nausea")
    elseif pos == "side" then
        GLUE.state.AddAffliction("asthma")
    elseif pos == "back" then
        GLUE.state.AddAffliction("anorexia")
    end
elseif part == "left arm" or part == "right arm" then
    if pos == "side" then
        GLUE.state.AddAffliction("clumsiness")
    elseif pos == "back" then
        GLUE.state.AddAffliction("weariness")
    end
end

GLUE.bard.OnHit()
