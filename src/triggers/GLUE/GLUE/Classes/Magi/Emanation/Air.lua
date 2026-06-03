-- Pattern: ^You sweep .+ over your head and a great wind rises\, picking up (\w+) and dashing them violently about before casting them back to the ground\.$
if not GLUE or not GLUE.magi then return end
GLUE.magi.resonance.Air = 0
if GLUE.IsTarget(matches[2]) then
    GLUE.state.AddAffliction("paralysis")
    GLUE.state.AddSmartAffliction({"dizziness", "asthma"})
end
