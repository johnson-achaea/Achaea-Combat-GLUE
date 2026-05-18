if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

-- Combusting blood confirms: haemophilia present and bleeding >= 150.
GLUE.state.PruneStatesWithoutAffliction("haemophilia")

local anyHighBleed = false
for _, state in ipairs(GLUE.state.states) do
    if (state.bleed or 0) >= 150 then anyHighBleed = true; break end
end

if anyHighBleed then
    GLUE.state.PruneStates(function(state)
        return (state.bleed or 0) < 150
    end)
else
    for _, state in ipairs(GLUE.state.states) do
        state.bleed = 150
    end
end

GLUE.state.AddAffliction("bloodfire")
