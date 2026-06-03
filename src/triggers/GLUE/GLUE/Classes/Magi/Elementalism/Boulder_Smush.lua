-- Pattern: ^One of the boulders smashes into the (\w+) (\w+) of (\w+) with a sickening crack\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[4]) then return end
GLUE.state.AddAffliction("broken" .. matches[2] .. matches[3])
