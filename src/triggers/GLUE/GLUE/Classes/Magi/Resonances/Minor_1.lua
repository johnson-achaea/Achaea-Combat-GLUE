-- Pattern: ^You are now minorly resonant with the Elemental Plane of (\w+)\.$
if not GLUE or not GLUE.magi then return end
GLUE.magi.resonance[matches[2]] = 1
