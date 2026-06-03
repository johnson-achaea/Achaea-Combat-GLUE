-- Pattern: ^You send a spray of sparks to assault (\w+)\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("notemperance")
