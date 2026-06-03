-- Pattern: ^You tap the Elemental Plane of Earth, summoning up a flurry of rocks to bombard (\w+)\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("clumsiness")
