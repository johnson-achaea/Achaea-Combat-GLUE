-- Pattern: ^You are now majorly resonant with the Elemental Plane of (\w+)\.$
if not GLUE or not GLUE.magi then return end
GLUE.magi.resonance[matches[2]] = 3
