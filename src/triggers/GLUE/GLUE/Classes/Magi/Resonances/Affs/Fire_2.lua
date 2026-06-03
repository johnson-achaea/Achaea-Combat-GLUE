-- Pattern: ^You will that (\w+) should burn, and so \w+ does\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.ForEachState(function(state, addedAffs)
    if not state.affs.scalded then
        state.affs.scalded = 1
        addedAffs.scalded = true
    else
        state.affs.burning = (state.affs.burning or 0) + 1
        addedAffs.burning = true
    end
end)
