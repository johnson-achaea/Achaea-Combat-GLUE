--[[
    GLUE Trigger: Dispatch Failed
    Pattern: ^([\w'\-]+) is not sufficiently incapacitated for you to dispatch \w+\.$

    Dispatch requires prone + damagedhead + crushedthroat simultaneously.
    Failure proves the target does not currently have all three.
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

GLUE.state.PruneStates(function(state)
    return state.affs.prone and state.affs.damagedhead and state.affs.crushedthroat
end)
