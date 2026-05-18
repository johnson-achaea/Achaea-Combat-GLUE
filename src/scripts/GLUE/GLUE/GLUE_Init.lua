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
    maxStates = 500,     -- Maximum number of states before consolidation
    debug = false,        -- Enable verbose debug output (all state changes)
    echos = true,         -- Show short aff/cure/limb change messages only
    wastePenalty = 0.4,  -- Probability multiplier for states where a cure had nothing to cure
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
        affs = {},
        prob = 1.0,
    })

    -- Assume full mana until the next observe
    GLUE.target.manaPercent = 100

    -- Reset all cure balances
    if GLUE.balance and GLUE.balance.ResetAll then
        GLUE.balance.ResetAll()
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

-- Defer colorMap build so Legacy is guaranteed to be loaded first
tempTimer(25, function()
    if GLUE.affs and GLUE.affs.buildColorMap then
        GLUE.affs.buildColorMap()
    end
end)

-- Load confirmation message
cecho("\n<green>[<cyan>GLUE<green>]<white> Loaded: Good Luck Understanding Everything v" .. GLUE.version)
