--[[
    GLUE Trigger: Opponent Applied Salve
    Pattern: ^([\w'\-]+) takes some (?:balm|salve) from a vial and rubs it on \w+ ([\w'\-]+)\.$

    Forks each state into mending and/or restoration branches based on which
    balances are available in that state's history. One timer per apply resolves
    restoration branches keyed by apply_id.

    Balance durations come from GLUE.balance.durations (salve / restore).
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
local location   = matches[3]

if not GLUE.IsTarget(targetName) then return end

local affsList = GLUE.affs.salve[location]
if not affsList then
    if GLUE.config.debug then
        cecho("\n<red>[GLUE]<reset> Unknown salve location: " .. location)
    end
    return
end

local now = os.clock()

-- Gate: the game enforces a single shared salve balance across all locations.
-- Ignore triggers that fire within the salve balance window of the last processed apply.
GLUE.salve_lastApplyAt = GLUE.salve_lastApplyAt or 0
if now - GLUE.salve_lastApplyAt < GLUE.balance.durations.salve then
    if GLUE.config.debug then
        cecho(string.format("\n<yellow>[GLUE]<reset> Ignored rapid salve (%.2fs since last)", now - GLUE.salve_lastApplyAt))
    end
    return
end
GLUE.salve_lastApplyAt = now

-- Seeing a salve apply proves slickness/bloodfire are absent.
GLUE.state.PruneStatesWithAffliction("bloodfire")
GLUE.state.PruneStatesWithAffliction("slickness")
local apply_id         = now
-- Known fake appliers are expected to mend with nothing — don't penalise empty mend branches.
local isFaker          = GLUE.isFakeApplier and GLUE.isFakeApplier(targetName)
local emptyMendPenalty = isFaker and 1.0 or GLUE.config.wastePenalty

-- Cure the first mending aff for this location within a single state.
-- Returns true if something was cured.
local function applyMending(state, loc)
    local limbPairs = loc == "arms" and {"left arm", "right arm"}
                   or loc == "legs" and {"left leg", "right leg"}
                   or {}
    for _, limb in ipairs(limbPairs) do
        local suffix = limb:gsub(" ", "")
        if state.affs["broken" .. suffix] then
            state.affs["broken" .. suffix] = nil
            return true
        end
    end
    -- Non-limb: first mending aff in salve list
    for _, aff in ipairs(GLUE.affs.salve[loc] or {}) do
        if not GLUE.affs.restore_downgrade[aff] and state.affs[aff] then
            state.affs[aff] = nil
            return true
        end
    end
    return false
end

local newStates = {}

for _, state in ipairs(GLUE.state.states) do
    local salveElapsed   = now - (state.salve_time   or 0)
    local restoreElapsed = now - (state.restore_time  or 0)

    local canMend    = salveElapsed   >= GLUE.balance.durations.salve
    local canRestore = restoreElapsed >= GLUE.balance.durations.restore and not state.pending_restore

    if not canMend and not canRestore then
        -- Apply is impossible given this state's balance history — waste penalty.
        local s   = GLUE.state.CopyState(state)
        s.prob    = (state.prob or 1) * GLUE.config.wastePenalty
        table.insert(newStates, s)

    elseif canMend and canRestore then
        -- Ambiguous: fork into mending branch and restoration branch.
        local halfProb = (state.prob or 1) * 0.5

        local mBranch       = GLUE.state.CopyState(state)
        mBranch.salve_time  = now
        local mended        = applyMending(mBranch, location)
        if not mended then mBranch.has_fake_apply = true end
        mBranch.prob        = mended and halfProb or (halfProb * emptyMendPenalty)

        local rBranch                  = GLUE.state.CopyState(state)
        rBranch.restore_time           = now
        rBranch.pending_restore        = { location = location, apply_id = apply_id }
        rBranch.prob                   = halfProb

        table.insert(newStates, mBranch)
        table.insert(newStates, rBranch)

    elseif canMend then
        local s          = GLUE.state.CopyState(state)
        s.salve_time     = now
        local mended     = applyMending(s, location)
        if not mended then s.has_fake_apply = true end
        s.prob           = mended and (state.prob or 1) or ((state.prob or 1) * emptyMendPenalty)
        table.insert(newStates, s)

    else
        -- Only restoration is possible.
        local s                  = GLUE.state.CopyState(state)
        s.restore_time           = now
        s.pending_restore        = { location = location, apply_id = apply_id }
        table.insert(newStates, s)
    end
end

GLUE.state.states = newStates
GLUE.state.Normalize()
GLUE.state.Optimize()

if GLUE.OnStateUpdate  then GLUE.OnStateUpdate()  end
if GLUE.UpdateDisplay  then GLUE.UpdateDisplay()   end

-- One timer per apply: resolves all restoration branches carrying this apply_id.
local timerId
timerId = tempTimer(GLUE.balance.durations.restore, function()
    GLUE.cure.RestorationComplete(location, apply_id)
    -- Remove from tracking table
    if GLUE.restore_timers then
        for i, id in ipairs(GLUE.restore_timers) do
            if id == timerId then table.remove(GLUE.restore_timers, i) break end
        end
    end
end)

GLUE.restore_timers = GLUE.restore_timers or {}
table.insert(GLUE.restore_timers, timerId)
