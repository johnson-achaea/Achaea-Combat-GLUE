if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

table.insert(GLUE.state.states, { affs = {}, bleed = 0, prob = 1 })
GLUE.state.Normalize()
if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
