if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

if GLUE.dragon.curseSent then
    GLUE.state.AddAffliction(GLUE.dragon.curseSent)
    GLUE.dragon.curseSent = nil
end
