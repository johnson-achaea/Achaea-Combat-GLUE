-- Pattern: ^You summon up a flurry of icicles to slash at (\w+) in a shower of freezing daggers\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("stuttering")
