if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

GLUE.state.AddAffliction("nausea")

GLUE.state.ForEachState(function(state, added)
    if (state.bleed or 0) > 150 then
        state.affs.anorexia = 1
        added.anorexia = true
    end
end)
GLUE.state.AddBleedPerState(15, 15)
