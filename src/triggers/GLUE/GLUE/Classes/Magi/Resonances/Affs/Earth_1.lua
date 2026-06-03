-- Pattern: ^A loud crack emanates from the (\w+) (\w+) of (\w+)\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[4]) then return end
GLUE.state.AddAffliction("broken" .. matches[2] .. matches[3])
