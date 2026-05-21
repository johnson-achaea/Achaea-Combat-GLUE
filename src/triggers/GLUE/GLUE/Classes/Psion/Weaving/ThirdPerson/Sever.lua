if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[4]) then return end
local limb = matches[3] .. " arm"
GLUE.limbs.AddHit(GLUE.target.name, limb, 28.1)
GLUE.state.AddAffliction("clumsiness")
local r = GLUE.integration.IHaveDefense("rupturesight")
GLUE.state.AddBleedPerState(r and 59 or 45, r and 59 or 45)
