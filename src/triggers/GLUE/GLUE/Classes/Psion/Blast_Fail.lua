if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

GLUE.state.PruneStates(function(state)
    local count = 0
    for _, aff in ipairs(blastRequiredAffs) do
        if state.affs[aff] then count = count + 1 end
    end
    if state.affs.unweavingmind then count = count + 1 end
    return count >= 3
end)
