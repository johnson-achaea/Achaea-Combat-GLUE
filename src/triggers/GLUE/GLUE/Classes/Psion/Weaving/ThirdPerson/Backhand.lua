if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[3]) then return end
GLUE.limbs.AddHit(GLUE.target.name, "head", 28.1)
GLUE.state.AddAffliction("stupidity")
GLUE.state.AddAffliction("dizziness")
local r = GLUE.integration.IHaveDefense("rupturesight")
GLUE.state.AddBleedPerState(r and 20 or 15, r and 20 or 15)
