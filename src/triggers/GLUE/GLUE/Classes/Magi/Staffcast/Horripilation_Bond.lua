-- Pattern: ^Even as the wave of cold dissipates, you retain control over the fluid and send it spinning through the air to bind (\w+) in a watery web\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("waterbonds")
