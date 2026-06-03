-- Pattern: ^A dreadful pallor overcomes the features of (\w+)\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("healthleech")
