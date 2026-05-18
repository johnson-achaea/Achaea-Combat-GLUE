if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

GLUE.state.AddAffliction("depression")
GLUE.state.AddAffliction("nausea")
GLUE.state.AddAffliction("hypochondria")
GLUE.state.AddAffliction("anorexia")
GLUE.state.AddAffliction("masochism")
