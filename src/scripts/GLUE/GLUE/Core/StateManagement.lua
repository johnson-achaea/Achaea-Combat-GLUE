--[[
    G.L.U.E. State Management
    Functions for managing the state space
]]--

GLUE = GLUE or {}
GLUE.state = GLUE.state or {}

local function affColor(aff)
    local raw = GLUE.affs and GLUE.affs.colorMap and GLUE.affs.colorMap[aff]
    return raw and ("<" .. raw .. ">") or "<orange>"
end

local function capStack(aff, count)
    if GLUE.affs.stackable and GLUE.affs.stackable[aff] then return count end
    return math.min(count, 1)
end

function GLUE.state.CopyState(state)
    local copy = { affs = {}, bleed = state.bleed or 0 }
    for aff, count in pairs(state.affs) do copy.affs[aff] = count end
    if state.limbs then
        copy.limbs = {}
        for name, limbData in pairs(state.limbs) do
            copy.limbs[name] = {}
            for limb, damage in pairs(limbData) do copy.limbs[name][limb] = damage end
        end
    end
    copy.salve_time      = state.salve_time      or 0
    copy.restore_time    = state.restore_time    or 0
    copy.has_fake_apply  = state.has_fake_apply  or false
    if state.pending_restore then
        copy.pending_restore = { location = state.pending_restore.location, apply_id = state.pending_restore.apply_id }
    end
    return copy
end

-- ---------- TIMED AFFLICTIONS ----------
-- Afflictions with a known duration (e.g. lightbind, mindravaged).
-- Keyed by aff name; value is os.clock() expiry time.
GLUE.state.timedAffs = GLUE.state.timedAffs or {}

function GLUE.state.AddTimedAffliction(affliction, duration)
    GLUE.state.timedAffs[affliction] = os.clock() + duration
end

function GLUE.state.ClearTimedAffliction(affliction)
    GLUE.state.timedAffs[affliction] = nil
end

function GLUE.state.ResetTimedAfflictions()
    GLUE.state.timedAffs = {}
end

function GLUE.state.TickTimedAfflictions()
    local now = os.clock()
    for aff, expiresAt in pairs(GLUE.state.timedAffs) do
        if now >= expiresAt then
            GLUE.state.timedAffs[aff] = nil
            if GLUE.config and GLUE.config.debug then
                GLUE.queueEcho(string.format("\n<cyan>[GLUE]<reset> Timed aff expired: %s", aff))
            end
        end
    end
end

-- Echo buffer: deduplicate repeated messages, flushed on the prompt trigger.
local echoBuffer = {}
local echoSet    = {}

local function queueEcho(msg)
    if not echoSet[msg] then
        echoSet[msg] = true
        table.insert(echoBuffer, msg)
    end
end

GLUE.queueEcho = queueEcho

-- Keyed handler table for affliction-cured notifications.
-- Scripts register with a unique key; re-registration on reload overwrites (no chain buildup).
GLUE.onAfflictionCuredHandlers = GLUE.onAfflictionCuredHandlers or {}

function GLUE.RegisterOnAfflictionCured(key, fn)
    GLUE.onAfflictionCuredHandlers[key] = fn
end

function GLUE.OnAfflictionCured(affliction)
    for _, fn in pairs(GLUE.onAfflictionCuredHandlers) do
        fn(affliction)
    end
end

function GLUE.FlushEchoBuffer()
    for _, m in ipairs(echoBuffer) do cecho(m) end
    echoBuffer = {}
    echoSet    = {}
end

function GLUE.state.AddAffliction(affliction, addToRoom)
    if addToRoom == nil then addToRoom = true end
    if affliction == "sensitivity" and GLUE.defenses.Has("deaf") then
        GLUE.defenses.Set("deaf", false)
        return false
    end
    if not GLUE.affs.list[affliction] then
        if GLUE.config.debug then
            queueEcho("\n<red>[GLUE]<reset> Unknown affliction: " .. affliction)
        end
        return false
    end

    if addToRoom and GLUE.target.name and GLUE.target.name ~= "" then
        GLUE.integration.AddTargetToRoom(GLUE.target.name)
    end

    for _, state in ipairs(GLUE.state.states) do
        state.affs[affliction] = capStack(affliction, (state.affs[affliction] or 0) + 1)
    end

    if GLUE.config.echos or GLUE.config.debug then
        queueEcho("\n<green>[GLUE]<reset> +" .. affColor(affliction) .. affliction .. "<reset>")
    end

    if GLUE.OnAffGiven then GLUE.OnAffGiven(affliction) end
    if #GLUE.state.states > 1 then GLUE.state.Optimize() end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
    return true
end

function GLUE.state.HasAffliction(affliction)
    local expiresAt = GLUE.state.timedAffs[affliction]
    if expiresAt and os.clock() < expiresAt then return true end
    for _, state in ipairs(GLUE.state.states) do
        if state.affs[affliction] and (state.prob or 0) > 0.01 then return true end
    end
    return false
end

function GLUE.state.RemoveAfflictionStack(affliction)
    local removed = false
    for _, state in ipairs(GLUE.state.states) do
        if state.affs[affliction] then
            local remaining = state.affs[affliction] - 1
            state.affs[affliction] = remaining > 0 and remaining or nil
            removed = true
        end
    end
    if removed and GLUE.config.debug then
        queueEcho("\n<red>[GLUE]<reset> -" .. affColor(affliction) .. affliction .. "(1 stack)<reset>")
    end
    if not removed then return false end
    if GLUE.OnAfflictionCured then GLUE.OnAfflictionCured(affliction) end
    if #GLUE.state.states > 1 then GLUE.state.Optimize() end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
    return true
end

function GLUE.state.RemoveAffliction(affliction)
    local removed = false
    for _, state in ipairs(GLUE.state.states) do
        if state.affs[affliction] then
            state.affs[affliction] = nil
            if affliction == "haemophilia" then state.bleed = 0 end
            removed = true
        end
    end

    if removed and GLUE.config.debug then
        queueEcho("\n<red>[GLUE]<reset> -" .. affColor(affliction) .. affliction .. "<reset>")
    end

    if not removed then return false end
    if GLUE.OnAfflictionCured then GLUE.OnAfflictionCured(affliction) end
    if #GLUE.state.states > 1 then GLUE.state.Optimize() end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
    return true
end

function GLUE.state.AddBleed(amount)
    for _, state in ipairs(GLUE.state.states) do
        if state.affs.haemophilia then
            state.bleed = (state.bleed or 0) + amount
        else
            state.bleed = amount
        end
    end

    if GLUE.config.debug then
        queueEcho("\n<green>[GLUE]<reset> +<orange>bleed " .. amount .. "<reset>")
    end

    if #GLUE.state.states > 1 then GLUE.state.Optimize() end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
end

function GLUE.state.AddBleedPerState(standing, prone)
    for _, state in ipairs(GLUE.state.states) do
        local amount = state.affs.prone and prone or standing
        if state.affs.haemophilia then
            state.bleed = (state.bleed or 0) + amount
        else
            state.bleed = amount
        end
    end

    if GLUE.config.debug then
        queueEcho(string.format("\n<green>[GLUE]<reset> +<orange>bleed %d/%d<reset>", standing, prone))
    end

    if #GLUE.state.states > 1 then GLUE.state.Optimize() end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
end

function GLUE.state.GetMinStacks(affliction)
    if #GLUE.state.states == 0 then return 0 end
    local min = math.huge
    for _, state in ipairs(GLUE.state.states) do
        local n = state.affs[affliction] or 0
        if n < min then min = n end
    end
    return min == math.huge and 0 or min
end

function GLUE.state.GetMaxStacks(affliction)
    if #GLUE.state.states == 0 then return 0 end
    local max = 0
    for _, state in ipairs(GLUE.state.states) do
        local n = state.affs[affliction] or 0
        if n > max then max = n end
    end
    return max
end

function GLUE.state.GetMinBleed()
    if #GLUE.state.states == 0 then return 0 end
    local min = math.huge
    for _, state in ipairs(GLUE.state.states) do
        local b = state.bleed or 0
        if b < min then min = b end
    end
    return min
end

-- For each state, adds the first affliction from the list that it doesn't already have.
function GLUE.state.AddSmartAffliction(afflictions)
    if not afflictions or #afflictions == 0 then
        if GLUE.config.debug then
            queueEcho("\n<yellow>[GLUE]<reset> AddSmartAffliction called with empty list")
        end
        return false
    end

    local addedAffs = {}
    for _, state in ipairs(GLUE.state.states) do
        for _, aff in ipairs(afflictions) do
            if not state.affs[aff] then
                state.affs[aff] = capStack(aff, (state.affs[aff] or 0) + 1)
                addedAffs[aff] = (addedAffs[aff] or 0) + 1
                break
            end
        end
    end

    if GLUE.config.debug then
        for aff, _ in pairs(addedAffs) do
            queueEcho("\n<green>[GLUE]<reset> +" .. affColor(aff) .. aff .. "<reset>")
        end
    end

    if #GLUE.state.states > 1 then GLUE.state.Optimize() end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
    return true
end

function GLUE.state.PruneStates(condition)
    local originalCount = #GLUE.state.states

    local wasPresent = {}
    for _, state in ipairs(GLUE.state.states) do
        for aff in pairs(state.affs) do wasPresent[aff] = true end
    end

    local newStates = {}

    for _, state in ipairs(GLUE.state.states) do
        if not condition(state) then
            table.insert(newStates, state)
        end
    end

    if #newStates == 0 then
        newStates = { { affs = {}, bleed = 0, prob = 1 } }
        if GLUE.config.debug then
            queueEcho("\n<red>[GLUE]<reset> prune emptied states — reset to clean state")
        end
    end

    GLUE.state.states = newStates
    GLUE.state.Normalize()

    if GLUE.config.debug and #newStates < originalCount then
        queueEcho(string.format("\n<red>[GLUE]<reset> pruned %d", originalCount - #newStates))
    end

    -- Fire OnAfflictionCured for any aff that was present before but is now gone from all states.
    if GLUE.OnAfflictionCured then
        for aff in pairs(wasPresent) do
            if not GLUE.state.HasAffliction(aff) then
                GLUE.OnAfflictionCured(aff)
            end
        end
    end

    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
end

-- If the aff is in every state (or only one state exists), removes it directly.
-- Pruning when all states have the aff would empty the state list.
function GLUE.state.PruneStatesWithAffliction(affliction)
    if #GLUE.state.states == 1 or GLUE.state.GetProbability(affliction) >= 100 then
        GLUE.state.RemoveAffliction(affliction)
        return
    end

    GLUE.state.PruneStates(function(state)
        return state.affs[affliction] ~= nil
    end)
end

-- If only one state or aff is absent everywhere, adds instead of pruning.
function GLUE.state.PruneStatesWithoutAffliction(affliction)
    if #GLUE.state.states <= 1 or GLUE.state.GetProbability(affliction) == 0 then
        GLUE.state.AddAffliction(affliction)
    else
        GLUE.state.PruneStates(function(state)
            return state.affs[affliction] == nil
        end)
    end
end

function GLUE.state.PruneByAfflictions(afflictions, mode)
    mode = mode or "any"
    GLUE.state.PruneStates(function(state)
        if mode == "any" then
            for _, aff in ipairs(afflictions) do
                if state.affs[aff] then return true end
            end
            return false
        elseif mode == "all" then
            for _, aff in ipairs(afflictions) do
                if not state.affs[aff] then return false end
            end
            return true
        elseif mode == "none" then
            for _, aff in ipairs(afflictions) do
                if state.affs[aff] then return false end
            end
            return true
        end
        return false
    end)
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
end

local function generateStateHash(state)
    local affList = {}
    for aff, count in pairs(state.affs) do
        table.insert(affList, aff .. "=" .. count)
    end
    table.sort(affList)
    local pr = state.pending_restore
        and (state.pending_restore.location .. "@" .. tostring(state.pending_restore.apply_id))
        or "nil"
    return table.concat(affList, "|")
        .. ":bleed=" .. tostring(state.bleed or 0)
        .. ":st="    .. tostring(state.salve_time   or 0)
        .. ":rt="    .. tostring(state.restore_time  or 0)
        .. ":pr="    .. pr
end

-- Branches each state: states with the aff get weight probability, states without get (1-weight).
-- States that already have the aff are kept as-is (no branching needed).
function GLUE.state.BranchAffliction(affliction, weight)
    if not GLUE.affs.list[affliction] then return false end
    weight = weight or 0.8

    local newStates = {}
    for _, state in ipairs(GLUE.state.states) do
        if state.affs[affliction] then
            table.insert(newStates, state)
        else
            local p = state.prob or 0

            local withAff = GLUE.state.CopyState(state)
            withAff.prob = p * weight
            withAff.affs[affliction] = capStack(affliction, 1)

            local withoutAff = GLUE.state.CopyState(state)
            withoutAff.prob = p * (1 - weight)

            table.insert(newStates, withAff)
            table.insert(newStates, withoutAff)
        end
    end

    GLUE.state.states = newStates
    GLUE.state.Normalize()
    GLUE.state.Optimize()
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
    return true
end

function GLUE.state.Normalize()
    local total = 0
    for _, state in ipairs(GLUE.state.states) do
        total = total + (state.prob or 0)
    end
    if total > 0 then
        for _, state in ipairs(GLUE.state.states) do
            state.prob = (state.prob or 0) / total
        end
    end
end

function GLUE.state.RemoveDuplicates()
    local originalCount = #GLUE.state.states
    local seen     = {}   -- hash → true
    local byHash   = {}   -- hash → state reference in newStates
    local newStates = {}

    for _, state in ipairs(GLUE.state.states) do
        local hash = generateStateHash(state)
        if not seen[hash] then
            seen[hash]   = true
            byHash[hash] = state
            table.insert(newStates, state)
        else
            -- Merge probability into the already-kept equivalent state.
            byHash[hash].prob = (byHash[hash].prob or 0) + (state.prob or 0)
        end
    end

    GLUE.state.states = newStates
    local removed = originalCount - #newStates

    if removed > 0 and GLUE.config.debug then
        queueEcho(string.format("\n<yellow>[GLUE]<reset> deduped -%d", removed))
    end

    return removed
end

function GLUE.state.Optimize()
    if #GLUE.state.states > 1 then
        GLUE.state.RemoveDuplicates()
    end
    -- When fully resolved to one state, check for fake-apply history.
    if #GLUE.state.states == 1 and GLUE.state.states[1].has_fake_apply and GLUE.target.name then
        GLUE.recordFakeApplier(GLUE.target.name)
    end
end

function GLUE.state.GetProbability(affliction)
    local expiresAt = GLUE.state.timedAffs[affliction]
    if expiresAt and os.clock() < expiresAt then return 100 end
    local prob = 0
    for _, state in ipairs(GLUE.state.states) do
        if state.affs[affliction] then
            prob = prob + (state.prob or 0)
        end
    end
    return prob * 100
end

function GLUE.state.GetAfflictionList(threshold)
    threshold = threshold or 0
    local affProbs = {}
    for affliction, _ in pairs(GLUE.affs.list) do
        local prob = GLUE.state.GetProbability(affliction)
        if prob > threshold then
            table.insert(affProbs, { affliction = affliction, probability = prob })
        end
    end
    table.sort(affProbs, function(a, b) return a.probability > b.probability end)
    return affProbs
end

function GLUE.state.CountAfflictions(threshold)
    threshold = threshold or 0
    local count = 0
    for affliction, _ in pairs(GLUE.affs.list) do
        if GLUE.state.GetProbability(affliction) > threshold then count = count + 1 end
    end
    return count
end

-- Sets the exact stack count for affliction across every state.
-- Use when an attack tells you precisely how many stacks the target has.
function GLUE.state.SetAfflictionStacks(affliction, count)
    for _, state in ipairs(GLUE.state.states) do
        if count > 0 then
            state.affs[affliction] = count
        else
            state.affs[affliction] = nil
        end
    end
    if GLUE.config.debug then
        queueEcho("\n<green>[GLUE]<reset> =" .. affColor(affliction) .. affliction .. "x" .. count .. "<reset>")
    end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
end

-- Adds count stacks of affliction to every state (for multi-hit attacks like Flurry).
function GLUE.state.AddAfflictionStacks(affliction, count)
    if not GLUE.affs.list[affliction] then return false end
    for _, state in ipairs(GLUE.state.states) do
        state.affs[affliction] = capStack(affliction, (state.affs[affliction] or 0) + count)
    end
    if GLUE.config.debug then
        queueEcho("\n<green>[GLUE]<reset> +" .. affColor(affliction) .. affliction .. "x" .. count .. "<reset>")
    end
    if #GLUE.state.states > 1 then GLUE.state.Optimize() end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
    return true
end

-- For each state, raises the stack count to at least minCount (never lowers).
function GLUE.state.SetAfflictionMinStacks(affliction, minCount)
    for _, state in ipairs(GLUE.state.states) do
        if (state.affs[affliction] or 0) < minCount then
            state.affs[affliction] = minCount
        end
    end
    if GLUE.config.debug then
        queueEcho("\n<green>[GLUE]<reset> " .. affColor(affliction) .. affliction .. " min=" .. minCount .. "<reset>")
    end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
end

-- Runs fn(state, addedAffs) for each state.  fn should mark addedAffs[aff]=true for any
-- aff it places on a state so the debug echo reports them consistently.
function GLUE.state.ForEachState(fn)
    local addedAffs = {}
    for _, state in ipairs(GLUE.state.states) do
        fn(state, addedAffs)
    end
    -- Cap any non-stackable affs that the caller may have incremented directly
    for aff in pairs(addedAffs) do
        if not (GLUE.affs.stackable and GLUE.affs.stackable[aff]) then
            for _, state in ipairs(GLUE.state.states) do
                if state.affs[aff] and state.affs[aff] > 1 then
                    state.affs[aff] = 1
                end
            end
        end
    end
    if GLUE.config.debug then
        for aff in pairs(addedAffs) do
            queueEcho("\n<green>[GLUE]<reset> +" .. affColor(aff) .. aff .. "<reset>")
        end
    end
    if GLUE.OnAffGiven then
        for aff in pairs(addedAffs) do
            GLUE.OnAffGiven(aff)
        end
    end
    if #GLUE.state.states > 1 then GLUE.state.Optimize() end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
    if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
end

function GLUE.state.GetStatesSummary()
    local summary = string.format("Total states: %d\n", #GLUE.state.states)
    for i, state in ipairs(GLUE.state.states) do
        local affs = {}
        for aff, _ in pairs(state.affs) do table.insert(affs, aff) end
        table.sort(affs)
        summary = summary .. string.format("  State %d: bleed=%d [%s]\n",
            i, state.bleed or 0, table.concat(affs, ", "))
        if i >= 10 then
            summary = summary .. string.format("  ... and %d more states\n", #GLUE.state.states - 10)
            break
        end
    end
    return summary
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: State Management")
end
