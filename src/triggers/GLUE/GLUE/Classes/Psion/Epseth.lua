if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
-- Pattern: [\w'\-]+ ducks low, \w+ blade slicing into the (left|right) (leg|arm) of (target)
-- matches[2]=side, matches[3]=part, matches[4]=targetName
if not GLUE.IsTarget(matches[4]) then return end

local limb = matches[2] .. " " .. matches[3]
GLUE.limbs.AddHit(GLUE.target.name, limb, 17)
