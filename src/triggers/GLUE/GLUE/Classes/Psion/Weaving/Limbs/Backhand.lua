if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("stupidity")
GLUE.state.AddAffliction("dizziness")
GLUE.state.AddBleedPerState(15, 15)
