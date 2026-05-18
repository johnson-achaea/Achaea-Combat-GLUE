if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(multimatches[1][2]) then return end

if GLUE.balance.IsAvailable("shrug") then
    GLUE.state.PruneStatesWithAffliction("weariness")
    GLUE.balance.SetOffBalance("shrug")
end

local nextLine = multimatches[3][1] or ""
if GLUE.CheckSpecialCure(nextLine) then return end
GLUE.cure.Passive()
