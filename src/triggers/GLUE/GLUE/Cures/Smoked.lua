if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

-- group 2 = standard pipe, group 3 = bone pipe (name appears mid-sentence)
local targetName = multimatches[1][2] ~= "" and multimatches[1][2] or multimatches[1][3]
if not GLUE.IsTarget(targetName) then return end

local nextLine = multimatches[3][1] or ""

-- Unweavingspirit fully cured (this message only appears at 0 stacks)
if string.find(nextLine, "seems suddenly unburdened, clarity reasserting itself upon") then
    GLUE.state.RemoveAffliction("unweavingspirit")
    GLUE.balance.SetOffBalance("smoke")
    GLUE.state.PruneStatesWithAffliction("asthma")
    return
elseif string.find(nextLine, "gives a sigh of relief") then
    GLUE.state.RemoveAffliction("earworm")
    -- GLUE.balance.SetOffBalance("smoke")
    -- GLUE.state.PruneStatesWithAffliction("asthma")
    return
end

GLUE.cure.Smoke()
