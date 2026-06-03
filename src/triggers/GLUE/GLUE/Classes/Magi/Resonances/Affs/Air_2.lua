-- Pattern: ^A vicious wind rises, lashing and flaying at the body of (\w+) to leave \w+ sensitive and raw\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("sensitivity")
