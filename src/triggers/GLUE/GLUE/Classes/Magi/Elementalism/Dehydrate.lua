-- Pattern: ^Weaving the elements of fire and water, you attempt to rip the excess water from the body of (\w+)\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("nausea")
GLUE.state.AddAffliction("weariness")
