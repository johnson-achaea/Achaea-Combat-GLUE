GLUE.incoming = GLUE.incoming or {}

GLUE.incoming.targetLastAttacked  = 0
GLUE.incoming.targetBalanceFreeAt = 0
GLUE.incoming.clumsinessDiscount  = 0.65

function GLUE.incoming.IsOffBalance()
    return GLUE.incoming.targetBalanceFreeAt > os.clock()
end

function GLUE.incoming.TimeUntilBalance()
    return math.max(0, GLUE.incoming.targetBalanceFreeAt - os.clock())
end

local function recordAttack(balanceTime)
    local now = os.clock()
    GLUE.incoming.targetLastAttacked = now
    if balanceTime then
        GLUE.incoming.targetBalanceFreeAt = now + balanceTime
    end
    GLUE.state.PruneStatesWithAffliction("paralysis")
    GLUE.defenses.Set("shield", false)
end

-- Call when the target's attack lands.
--   balanceTime: optional seconds until the target regains attack balance.
function GLUE.incoming.OnAttack(balanceTime)
    if not GLUE.target or not GLUE.target.name then return end
    recordAttack(balanceTime)
    for _, state in ipairs(GLUE.state.states) do
        if state.affs and state.affs.clumsiness then
            state.prob = (state.prob or 0) * GLUE.incoming.clumsinessDiscount
        end
    end
    GLUE.state.Normalize()
    GLUE.state.Optimize()
end

-- Call when the target's attack explicitly fails due to clumsiness.
--   balanceTime: optional seconds until the target regains attack balance.
function GLUE.incoming.OnClumsinessMiss(balanceTime)
    if not GLUE.target or not GLUE.target.name then return end
    recordAttack(balanceTime)
    GLUE.state.PruneStatesWithoutAffliction("clumsiness")
end
