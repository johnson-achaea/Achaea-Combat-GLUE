-- Pattern: ^You are now moderately resonant with the Elemental Planes of (\w+) and (\w+)\.$
if not GLUE or not GLUE.magi then return end
GLUE.magi.resonance[matches[2]] = 2
GLUE.magi.resonance[matches[3]] = 2
