-- Pattern: ^You bleed off residual power from your connection with the Elemental Plane of Earth, directing it in an unfocussed blast of arcane might at (\w+)\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("paralysis")
