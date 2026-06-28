-- Pattern: ^You flick out with the point of .+, song blessed steel singing a keening note towards \w+\.$
if not GLUE or not GLUE.bard then return end

local pos = GLUE.bard.position
if pos == "front" then
    GLUE.state.EnsureAffliction("crescendo")
elseif pos == "side" then
    GLUE.state.EnsureAffliction("earworm")
elseif pos == "back" then
    GLUE.state.EnsureAffliction("crescendo")
    GLUE.state.EnsureAffliction("earworm")
end

GLUE.bard.OnHit()
