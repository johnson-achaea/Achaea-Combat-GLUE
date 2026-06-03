-- Pattern: ^The eyes of (\w+) grow distant as \w+ observes the complex patterns\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("stupidity")
