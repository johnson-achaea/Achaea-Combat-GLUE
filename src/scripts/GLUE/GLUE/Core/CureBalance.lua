--[[
    G.L.U.E. Cure Balance Tracking
    Tracks when target can use each cure method again

    Each cure has a balance time that must pass before it can be used again.
    If target tries to cure before balance is back, the cure does nothing.
]]--

GLUE = GLUE or {}
GLUE.balance = GLUE.balance or {}

--[[
    Cure balance durations (in seconds)
    These are the standard Achaea cure balance times
    Everything is dropped by .05 to account for some variance
]]--
GLUE.balance.durations = {
    herb = 1.3,      -- Eating herbs
    smoke = 1.3,     -- Smoking pipes
    salve = 0.8,     -- Applying salves
    focus = 2.3,     -- Using focus
    tree = 9.3,      -- Touching tree tattoo (also has 8.5s half-balance)
    sip = 4.3,       -- Drinking elixirs
    restore = 3.8,   -- Applying restoration salve
    shrug = 10.0,    -- Serpent shrug (cures weariness)
}

-- Timestamps (os.clock()) recording when each balance last became free after use.
-- nil = never used this session (treat as not yet earned free-time data).
GLUE.balance.freeAt = GLUE.balance.freeAt or {}

--[[
    Cure balance state
    0 = on balance
    1 = used (unavailable)
]]--
GLUE.balance.herb = 0
GLUE.balance.smoke = 0
GLUE.balance.salve = 0
GLUE.balance.focus = 0
GLUE.balance.tree = 0
GLUE.balance.sip = 0
GLUE.balance.restore = 0
GLUE.balance.shrug = 0
GLUE.balance.halftree = 0  -- Tree tattoo half-balance (8.5s)

--[[
    Timer IDs for tracking cure balances
    These are used to reset the balance flags when time expires
]]--
GLUE.balance.timers = {
    herb = nil,
    smoke = nil,
    salve = nil,
    focus = nil,
    tree = nil,
    halftree = nil,
    sip = nil,
    restore = nil,
    shrug = nil,
}

--[[
    Mark a cure as being off balance
    @param cureType (string) - The cure type (herb, smoke, salve, focus, tree, sip, restore)
]]--
function GLUE.balance.SetOffBalance(cureType)
    if not GLUE.balance.durations[cureType] then
        if GLUE.config.debug then
            cecho(string.format("\n<red>[GLUE]<reset> Unknown cure type: %s", cureType))
        end
        return
    end

    -- Kill existing timer if one exists
    if GLUE.balance.timers[cureType] then
        killTimer(GLUE.balance.timers[cureType])
    end

    -- Set balance to 1 (on balance)
    GLUE.balance[cureType] = 1

    -- Create timer to reset balance
    GLUE.balance.timers[cureType] = tempTimer(GLUE.balance.durations[cureType], function()
        GLUE.balance[cureType] = 0
        GLUE.balance.timers[cureType] = nil
        GLUE.balance.freeAt[cureType] = os.clock()

        if GLUE.config.debug then
            cecho(string.format("\n<green>[GLUE]<reset> %s balance recovered", cureType))
        end
    end)

    -- Special handling for tree tattoo (has half-balance at 8.5s)
    if cureType == "tree" then
        if GLUE.balance.timers.halftree then
            killTimer(GLUE.balance.timers.halftree)
        end

        GLUE.balance.halftree = 1

        GLUE.balance.timers.halftree = tempTimer(8.5, function()
            GLUE.balance.halftree = 0
            GLUE.balance.timers.halftree = nil

            if GLUE.config.debug then
                cecho("\n<green>[GLUE]<reset> tree half-balance recovered")
            end
        end)
    end

    if GLUE.config.debug then
        cecho(string.format("\n<cyan>[GLUE]<reset> %s balance used (%.1fs)",
            cureType, GLUE.balance.durations[cureType]))
    end
end

--[[
    Check if a cure is available (balance = 0)
    @param cureType (string) - The cure type to check
    @return (boolean) - true if available, false if on balance
]]--
function GLUE.balance.IsAvailable(cureType)
    return GLUE.balance[cureType] == 0
end

-- Returns how many seconds this balance has been free since its last recovery.
-- Returns 0 if currently on balance or never used this session.
function GLUE.balance.FreeFor(cureType)
    if GLUE.balance[cureType] == 1 then return 0 end
    local t = GLUE.balance.freeAt[cureType]
    if not t then return 0 end
    return os.clock() - t
end

--[[
    Get remaining time on a cure balance
    @param cureType (string) - The cure type to check
    @return (number) - Remaining time in seconds, or 0 if available
]]--
function GLUE.balance.TimeRemaining(cureType)
    if not GLUE.balance.timers[cureType] then
        return 0
    end

    local remaining = remainingTime(GLUE.balance.timers[cureType])
    return remaining or 0
end

--[[
    Reset all cure balances (used when target dies, leaves, etc.)
]]--
function GLUE.balance.ResetAll()
    -- Kill all timers
    for cureType, timerID in pairs(GLUE.balance.timers) do
        if timerID then
            killTimer(timerID)
        end
    end

    -- Reset all balances to 0
    GLUE.balance.herb = 0
    GLUE.balance.smoke = 0
    GLUE.balance.salve = 0
    GLUE.balance.focus = 0
    GLUE.balance.tree = 0
    GLUE.balance.sip = 0
    GLUE.balance.restore = 0
    GLUE.balance.shrug = 0
    GLUE.balance.halftree = 0

    -- Seed all balances as "free now" so pruning can begin immediately.
    local now = os.clock()
    GLUE.balance.freeAt = {
        herb    = now,
        smoke   = now,
        salve   = now,
        focus   = now,
        tree    = now,
        sip     = now,
        restore = now,
        shrug   = now,
    }

    -- Clear timer table
    GLUE.balance.timers = {
        herb = nil,
        smoke = nil,
        salve = nil,
        focus = nil,
        tree = nil,
        halftree = nil,
        sip = nil,
        restore = nil,
        shrug = nil,
    }

    if GLUE.config.debug then
        cecho("\n<green>[GLUE]<reset> All cure balances reset")
    end
end

--[[
    Get a display string showing all cure balance states
    Useful for debugging and display
    @return (string) - Status string showing all balances
]]--
function GLUE.balance.GetStatus()
    local status = {}

    for _, cureType in ipairs({"herb", "smoke", "salve", "focus", "tree"}) do
        local remaining = GLUE.balance.TimeRemaining(cureType)
        if remaining > 0 then
            table.insert(status, string.format("%s(%.1fs)", cureType, remaining))
        end
    end

    if #status == 0 then
        return "All balances available"
    else
        return "On balance: " .. table.concat(status, ", ")
    end
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Cure Balance Tracking")
end
