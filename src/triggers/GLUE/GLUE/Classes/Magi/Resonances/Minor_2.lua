-- Pattern: ^You are now minorly resonant with the Elemental Planes of (\w+) and (\w+)\.$
if not GLUE or not GLUE.magi then return end
GLUE.magi.resonance[matches[2]] = 1
GLUE.magi.resonance[matches[3]] = 1
