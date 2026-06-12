--[[
    G.L.U.E. - Good Luck Understanding Everything
    Affliction Tracking System for Achaea

    A standalone affliction tracking system with no external dependencies.
    Uses STATE-BASED tracking to determine likelihood of afflictions.

    Each "state" represents a possible reality of what afflictions the target has.
    When uncertain events occur, states branch. When information is gained, states are pruned.
    Probability = (states with affliction) / (total states)
]]--

-- Initialize the GLUE namespace
GLUE = GLUE or {}

-- Version information
GLUE.version = "2.0.0"
GLUE.name = "Good Luck Understanding Everything"

-- Core configuration
GLUE.config = GLUE.config or {
    maxStates    = 500,   -- Maximum number of states before consolidation
    debug        = false, -- Enable verbose debug output (all state changes)
    echos        = true,  -- Show short aff/cure/limb change messages only
    wastePenalty = 0.4,   -- Probability multiplier for states where a cure had nothing to cure
    -- Echo collapsing: consecutive messages of the same category are shown individually
    -- up to the category's limit, then collapsed to first + "...+N more".
    -- Override per-category or set "general" as the fallback.
    -- Debug mode bypasses all collapsing.
    maxEchos = {
        general  = 3,  -- fallback for any categorized message type
        branched = 3,
        removed  = 3,
    },
}

-- Illusion suppression
GLUE.illusionActive = false

function GLUE.illusionCheck()
    return GLUE.illusionActive == true
end

-- Initialize core modules
GLUE.affs = GLUE.affs or {}      -- Affliction tracking
GLUE.cure = GLUE.cure or {}      -- Cure method handlers
GLUE.target = GLUE.target or {}  -- Target information
GLUE.util = GLUE.util or {}      -- Utility functions
GLUE.state = GLUE.state or {}    -- State management
GLUE.venoms = GLUE.venoms or {}  -- Venom tracking
GLUE.limbs = GLUE.limbs or {}    -- Limb damage tracking

--[[
    STATE STRUCTURE:
    Each state is a table containing:
    {
        affs = {affliction1 = true, affliction2 = true, ...},
        limbs = {
            targetName = {
                head = damage%,
                torso = damage%,
                ["left arm"] = damage%,
                ["right arm"] = damage%,
                ["left leg"] = damage%,
                ["right leg"] = damage%
            }
        }
    }
]]--

-- Array of all possible states
GLUE.state.states = GLUE.state.states or {}

-- Initialize target information
GLUE.target.name = GLUE.target.name or ""
GLUE.target.class = GLUE.target.class or ""

--[[
    Reset the affliction tracking system
    Creates a single initial state with no afflictions
    Also resets all cure balances
]]--
function GLUE.Reset()
    if GLUE.state.ResetTimedAfflictions then GLUE.state.ResetTimedAfflictions() end
    GLUE.state.states = {}

    -- Create initial state with no afflictions
    table.insert(GLUE.state.states, {
        affs            = {},
        prob            = 1.0,
        salve_time      = 0,
        restore_time    = 0,
        pending_restore = nil,
    })

    -- restore_timers are intentionally kept alive across aff state resets so that
    -- in-flight restorations can still update the flat limb damage table.
    -- They are killed by GLUE.killRestoreTimers() when limb damage is fully cleared.

    -- Assume full mana until the next observe
    GLUE.target.manaPercent = 100

    GLUE.cure.afterHerb = nil

    -- Reset all cure balances
    if GLUE.balance and GLUE.balance.ResetAll then
        GLUE.balance.ResetAll()
    end

    -- Reset defense tracking
    if GLUE.defenses and GLUE.defenses.Reset then
        GLUE.defenses.Reset()
    end

    -- Clear venom tracking
    if GLUE.venoms then
        GLUE.venoms.on_weapons = {}
        GLUE.venoms.pending_weapons = {}
    end

    -- Reset limb tracking for current target
    -- if GLUE.limbs and GLUE.limbs.ResetAll and GLUE.target.name ~= "" then
    --     GLUE.limbs.ResetAll(GLUE.target.name)
    -- end

    if GLUE.config.debug then
        cecho("\n<green>[GLUE]<reset> System reset complete - 1 state")
    end
end

--[[
    Soft reset - clears all states and creates fresh initial state
]]--
function GLUE.SoftReset()
    if GLUE.psion and GLUE.psion.StopUnweaveTick then
        GLUE.psion.StopUnweaveTick()
    end
    GLUE.Reset()
end

-- Kill all in-flight restoration timers. Called when limb damage is fully cleared
-- or when switching targets, NOT on plain aff-state resets.
function GLUE.killRestoreTimers()
    if GLUE.restore_timers then
        for _, id in ipairs(GLUE.restore_timers) do killTimer(id) end
    end
    GLUE.restore_timers = {}
end

-- Fake applier tracking (in-memory only) ------------------------------------

GLUE.fakeAppliers = GLUE.fakeAppliers or {}

function GLUE.recordFakeApplier(name)
    if not name or name == "" then return end
    local key = name:lower()
    if GLUE.fakeAppliers[key] then return end
    GLUE.fakeAppliers[key] = true
    if GLUE.config.echos or GLUE.config.debug then
        cecho(string.format("\n<yellow>[GLUE]<reset> Recorded fake applier: %s", name))
    end
end

function GLUE.isFakeApplier(name)
    if not name then return false end
    return GLUE.fakeAppliers[name:lower()] == true
end

-- Defer colorMap build so Legacy is guaranteed to be loaded first
tempTimer(25, function()
    if GLUE.affs and GLUE.affs.buildColorMap then
        GLUE.affs.buildColorMap()
    end
end)

-- Load confirmation message
cecho("\n<green>[<cyan>GLUE<green>]<white> Loaded: Good Luck Understanding Everything v" .. GLUE.version)
