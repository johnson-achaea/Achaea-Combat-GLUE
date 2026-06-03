-- Pattern: ^You are now majorly resonant with the Elemental Planes of (\w+) and (\w+)\.$
if not GLUE or not GLUE.magi then return end
GLUE.magi.resonance[matches[2]] = 3
GLUE.magi.resonance[matches[3]] = 3
