-- Pattern: ^The incandescent might of Elemental Fire filling you, you command (\w+) to burn from within\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.ForEachState(function(state, addedAffs)
    if not state.affs.blisters then
        state.affs.blisters = 1
        addedAffs.blisters = true
    else
        state.affs.burning = (state.affs.burning or 0) + 1
        addedAffs.burning = true
    end
end)
