-- Pattern: ^You flick out with the point of .+, song blessed steel singing a keening note towards \w+\.$
if not GLUE or not GLUE.bard then return end

if GLUE.bard.position == "side" or GLUE.bard.position == "back" then
    GLUE.state.AddAffliction("earworm")
    GLUE.state.AddAffliction("asthma")
end

GLUE.bard.OnHit()
