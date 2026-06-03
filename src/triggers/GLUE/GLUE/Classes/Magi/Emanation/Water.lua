-- Pattern: ^The might of elemental Water surging through your body, you make the slightest flick with .+\, and the hand of Sllshya descends as a freezing deluge to smash (\w+)\.$
if not GLUE or not GLUE.magi then return end
GLUE.magi.resonance.Water = 0
if GLUE.IsTarget(matches[2]) then
    GLUE.state.ApplyFreeze()
    GLUE.state.AddAffliction("stuttering")
end
