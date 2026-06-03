-- Pattern: ^You click your fingers and lightning strikes from the air to smite (\w+)\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddSmartAffliction({"fulminated", "epilepsy", "paralysis"})
