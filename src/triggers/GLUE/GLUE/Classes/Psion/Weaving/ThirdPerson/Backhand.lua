if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[3]) then return end
GLUE.limbs.AddHit(GLUE.target.name, "head", 28.1)
local r = GLUE.integration.IHaveDefense("rupturesight")
GLUE.affQueue.Queue(function()
    GLUE.state.AddAffliction("stupidity")
    GLUE.state.AddAffliction("dizziness")
    GLUE.state.AddBleedPerState(r and 20 or 15, r and 20 or 15)
end)