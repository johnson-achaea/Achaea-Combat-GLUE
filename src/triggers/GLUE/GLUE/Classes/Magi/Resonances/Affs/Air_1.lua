-- Pattern: ^(\w+) clutches at \w+ throat as \w+ gasps for breath\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("asthma")
