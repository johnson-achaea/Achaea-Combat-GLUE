if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

local uwtype = matches[3]
local aff = "unweaving" .. uwtype

GLUE.state.ForEachState(function(state, added)
    local current = state.affs[aff] or 0
    local new = math.max(current, 3)
    state.affs[aff] = new
    added[aff] = true
end)
