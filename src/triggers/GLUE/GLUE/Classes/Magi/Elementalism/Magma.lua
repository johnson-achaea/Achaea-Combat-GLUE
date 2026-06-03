-- Pattern: ^You weave fire and earth and bubbling magma boils into existence to wash over (\w+) in a skin\-melting tide\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("scalded")
