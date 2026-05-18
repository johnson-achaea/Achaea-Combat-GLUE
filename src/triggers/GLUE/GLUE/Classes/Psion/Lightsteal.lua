if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

-- Lightsteal only blinds when target is prone
GLUE.state.ForEachState(function(state, added)
    if state.affs.prone then
        state.affs.blackout = (state.affs.blackout or 0) + 1
        added.blackout = true
    end
end)

-- Blindness from lightsteal is temporary (~10s)
tempTimer(10, function()
    if GLUE and GLUE.state then
        GLUE.state.RemoveAffliction("blackout")
    end
end)
