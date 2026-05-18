if not GLUE or not GLUE.state then return end
if GLUE.illusionCheck() then return end

GLUE.state.PruneStates(function(state)
    return state.affs.haemophilia and (state.bleed or 0) > 150
end)
