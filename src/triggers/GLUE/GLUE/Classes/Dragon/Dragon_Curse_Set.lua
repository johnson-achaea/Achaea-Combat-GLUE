if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
-- matches[2] = aff name, matches[3] = target name
if not GLUE.IsTarget(matches[3]) then return end

GLUE.dragon.curseSent = matches[2]
