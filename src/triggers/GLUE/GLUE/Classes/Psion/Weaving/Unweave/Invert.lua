if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

local fromType = matches[3]
local toType   = matches[4]
local aff1 = "unweaving" .. fromType
local aff2 = "unweaving" .. toType

for _, state in ipairs(GLUE.state.states) do
    local has1 = state.affs[aff1]
    local has2 = state.affs[aff2]
    state.affs[aff1] = has2
    state.affs[aff2] = has1
end

GLUE.psion.StopUnweaveTick(fromType)
GLUE.psion.StartUnweaveTick(toType)

GLUE.state.Optimize()
