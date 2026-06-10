if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

local kataBonus = shik and shik.kata and shik.kata > 10
GLUE.affQueue.Queue(function()
    GLUE.state.AddSmartAffliction({"clumsiness", "healthleech"})
    if kataBonus then GLUE.state.AddAffliction("healthleech") end
end)
