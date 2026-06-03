-- Pattern: ^You form a lash of fire, and send it to scorch the flesh of (\w+)\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("burning")
