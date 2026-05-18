if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[3]) then return end
local limb = matches[4] .. " arm"
GLUE.limbs.AddHit(GLUE.target.name, limb, 28.1)
GLUE.state.AddAffliction("weariness")
GLUE.state.AddBleedPerState(45, 45)
