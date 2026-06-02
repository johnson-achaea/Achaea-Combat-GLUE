-- Pattern: ^Blood erupts from the (\w+) arm of ([\w'\-]+) in a crimson spray\.$
-- matches[2] = arm side, matches[3] = target name
if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[3]) then return end

GLUE.state.AddAffliction("impatience")
GLUE.state.AddAffliction("stupidity")
GLUE.state.AddAffliction("slickness")

GLUE.bard.OnHit()
