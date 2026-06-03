-- Pattern: ^The might of elemental Fire filling you like a scorching river, you lift .+ to point at (\w+) and unleash a stream of searing flame\.$
if not GLUE or not GLUE.magi then return end
GLUE.magi.resonance.Fire = 0
if GLUE.IsTarget(matches[2]) then
    GLUE.state.AddAffliction("burning")
end
