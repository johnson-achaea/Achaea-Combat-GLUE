if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

GLUE.state.PruneStatesWithAffliction("weariness")
GLUE.state.PruneStatesWithAffliction("recklessness")

if GLUE.state.HasAffliction("prone") then
    GLUE.cure.Passive()
else
    GLUE.cure.Passive()
    GLUE.cure.Passive()
    GLUE.cure.Passive()
end
