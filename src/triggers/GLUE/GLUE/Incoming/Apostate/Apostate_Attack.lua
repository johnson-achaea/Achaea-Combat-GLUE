if not GLUE or not GLUE.incoming then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.incoming.OnAttack(1.9)
