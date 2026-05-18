--[[
    G.L.U.E. Huff State Pruner
    Registered as a huff callback. Each tick:
      1. Optimizes (deduplicates) states.
      2. Applies exponential-decay penalties to implausible states:
           penalty = exp(-DECAY_K * (timeFree - GRACE))
         Multiple independent rules compound multiplicatively.
      3. Renormalizes. Computes ESS = 1/Σ(w²).
      4. If ESS < N/2, hard-prunes states below PRUNE_THRESHOLD
         and renormalizes again.

    Penalty rules (all require the relevant balance to have been free
    for more than GRACE seconds — i.e., the target had time to cure):

      A) Single-aff state: penalized by the worst (longest-free) cure
         method available for that aff. Tree is excluded — targets may
         hold tree intentionally.

      B) Herb aff present, no anorexia, herb balance free.
      C) Focus aff present, no impatience, focus balance free.
      D) Smoke aff present, no asthma, smoke balance free.

    Rules B/C/D compound; rule A is used for single-aff states instead.
]]--

local GRACE   = .5  -- seconds after balance recovery before penalty starts
local DECAY_K = 0.5  -- exp decay rate: penalty = exp(-DECAY_K * overtime)

-- Lookup tables built lazily on first tick (AfflictionMaps loads first).
local herbSet  = nil   -- aff → true for all herb-curable affs
local focusSet = nil   -- aff → true for all focus-curable affs
local smokeSet = nil   -- aff → true for all smoke-curable affs
local cureOf   = nil   -- aff → { herb=true, focus=true, smoke=true, tree=true }

local function buildTables()
    herbSet  = {}
    focusSet = {}
    smokeSet = {}
    cureOf   = {}

    local function mark(aff, method)
        herbSet[aff]  = herbSet[aff]  or (method == "herb")
        focusSet[aff] = focusSet[aff] or (method == "focus")
        smokeSet[aff] = smokeSet[aff] or (method == "smoke")
        cureOf[aff]   = cureOf[aff] or {}
        cureOf[aff][method] = true
    end

    for _, affList in pairs(GLUE.affs.herbs) do
        for _, aff in ipairs(affList) do mark(aff, "herb") end
    end
    for _, aff in ipairs(GLUE.affs.focus) do mark(aff, "focus") end
    for _, aff in ipairs(GLUE.affs.smoke) do mark(aff, "smoke") end
    -- tree intentionally excluded: targets may hold tree for strategic reasons
end

local PRUNE_THRESHOLD = 0.01

-- Returns a penalty multiplier in (0, 1]: 1.0 = no penalty.
-- Single-aff states use rule A only; multi-aff states use rules B/C/D,
-- compounding independently (multiply) for each firing rule.
local function computePenalty(state, herbFree, focusFree, smokeFree)
    local affs    = state.affs
    local penalty = 1.0

    local count = 0
    local only  = nil
    for aff in pairs(affs) do
        if aff ~= "prone" then
            count = count + 1
            only  = aff
        end
    end

    -- Rule A: single-aff state — penalise by the longest-free cure method.
    if count == 1 and only then
        local methods = cureOf[only]
        if methods then
            local overtime = 0
            if methods.herb  and herbFree  > GRACE then overtime = math.max(overtime, herbFree  - GRACE) end
            if methods.focus and focusFree > GRACE then overtime = math.max(overtime, focusFree - GRACE) end
            if methods.smoke and smokeFree > GRACE then overtime = math.max(overtime, smokeFree - GRACE) end
            if overtime > 0 then penalty = math.exp(-DECAY_K * overtime) end
        end
        return penalty
    end

    -- Rule B: herb aff present, no anorexia, herb balance free.
    if not affs.anorexia and herbFree > GRACE then
        for aff in pairs(affs) do
            if herbSet[aff] then
                penalty = penalty * math.exp(-DECAY_K * (herbFree - GRACE))
                break
            end
        end
    end

    -- Rule C: focus aff present, no impatience, focus balance free.
    if not affs.impatience and focusFree > GRACE then
        for aff in pairs(affs) do
            if focusSet[aff] then
                penalty = penalty * math.exp(-DECAY_K * (focusFree - GRACE))
                break
            end
        end
    end

    -- Rule D: smoke aff present, no asthma, smoke balance free.
    if not affs.asthma and smokeFree > GRACE then
        for aff in pairs(affs) do
            if smokeSet[aff] then
                penalty = penalty * math.exp(-DECAY_K * (smokeFree - GRACE))
                break
            end
        end
    end

    return penalty
end

local lastPassiveCure = 0
local lastRestoreCure = 0
local lastMendCure    = 0
local PASSIVE_INTERVAL = 2.0
local RESTORE_INTERVAL = 4.0
local MEND_INTERVAL    = 1.0

-- Priority: left leg > right leg > torso > head > left arm > right arm
-- Within each limb: most severe first (mangled > damaged)
local restoreOrder = {
    "mangledleftleg",  "damagedleftleg",
    "mangledrightleg", "damagedrightleg",
    "serioustrauma",   "mildtrauma",
    "mangledhead",     "damagedhead",
    "mangledleftarm",  "damagedleftarm",
    "mangledrightarm", "damagedrightarm",
}

-- Mending (1s salve balance) — no torso/head broken state exists
local mendOrder = {
    "brokenleftleg", "brokenrightleg", "brokenleftarm", "brokenrightarm",
}

local function simulateRestore()
    for _, aff in ipairs(restoreOrder) do
        if GLUE.state.HasAffliction(aff) then
            local downgrade = GLUE.affs.restore_downgrade[aff]
            for _, state in ipairs(GLUE.state.states) do
                if state.affs[aff] then
                    state.affs[aff] = nil
                    if downgrade and downgrade ~= "" then
                        state.affs[downgrade] = 1
                    end
                end
            end
            if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
            if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end
            if GLUE.config.debug then
                cecho(string.format("\n<cyan>[GLUE Huff]<reset> Simulated restore: %s", aff))
            end
            return
        end
    end
end

local function simulateMend()
    for _, aff in ipairs(mendOrder) do
        if GLUE.state.HasAffliction(aff) then
            GLUE.state.RemoveAffliction(aff)
            if GLUE.config.debug then
                cecho(string.format("\n<cyan>[GLUE Huff]<reset> Simulated mend: %s", aff))
            end
            return
        end
    end
end

GLUE.huff.Register(function()
    if not herbSet then buildTables() end

    GLUE.state.TickTimedAfflictions()
    GLUE.state.Optimize()

    local hasAffs = false
    for _, state in ipairs(GLUE.state.states) do
        if next(state.affs) then hasAffs = true; break end
    end
    if not hasAffs then return end

    -- If the target is not in the room, we can't observe cures.
    -- Simulate a passive cure every 2s instead of pruning on balance timers.
    local targetInRoom = false
    if GLUE.target.name ~= "" and ra and ra.InRoom then
        for _, name in ipairs(ra.InRoom) do
            if name == GLUE.target.name then targetInRoom = true; break end
        end
    else
        targetInRoom = true
    end
    if not targetInRoom then
        GLUE.state.RemoveAffliction("prone")
        GLUE.state.RemoveAffliction("paralysis")
        local now = os.clock()
        if now - lastPassiveCure >= PASSIVE_INTERVAL then
            lastPassiveCure = now
            if GLUE.config.debug then
                cecho("\n<cyan>[GLUE Huff]<reset> Target not in room - simulating passive cure")
            end
            GLUE.cure.Passive()
        end
        if not GLUE.state.HasAffliction("slickness") and not GLUE.state.HasAffliction("bloodfire") then
            local needsRestore = false
            for _, aff in ipairs(restoreOrder) do
                if GLUE.state.HasAffliction(aff) then needsRestore = true; break end
            end
            if needsRestore and now - lastRestoreCure >= RESTORE_INTERVAL then
                lastRestoreCure = now
                simulateRestore()
            end

            local needsMend = false
            for _, aff in ipairs(mendOrder) do
                if GLUE.state.HasAffliction(aff) then needsMend = true; break end
            end
            if needsMend and now - lastMendCure >= MEND_INTERVAL then
                lastMendCure = now
                simulateMend()
            end
        end
        return
    end

    local herbFree  = GLUE.balance.FreeFor("herb")
    local focusFree = GLUE.balance.FreeFor("focus")
    local smokeFree = GLUE.balance.FreeFor("smoke")

    -- Step 1: Apply exponential-decay penalty to each implausible state.
    local anyPenalized = false
    for _, state in ipairs(GLUE.state.states) do
        local p = computePenalty(state, herbFree, focusFree, smokeFree)
        if p < 1.0 then
            state.prob = (state.prob or 1) * p
            anyPenalized = true
        end
    end

    if not anyPenalized then return end

    -- Step 2: Renormalize.
    GLUE.state.Normalize()

    -- Step 3: Compute ESS = 1/Σ(w²). Only hard-prune when ESS < N/2.
    local N      = #GLUE.state.states
    local sumSq  = 0
    for _, state in ipairs(GLUE.state.states) do
        local w = state.prob or 0
        sumSq = sumSq + w * w
    end
    local ess = sumSq > 0 and (1.0 / sumSq) or 0

    if ess >= N / 2 then return end

    -- Step 4: Hard-prune below threshold, fire OnAfflictionCured for newly-absent affs.
    local wasPresent = {}
    for _, state in ipairs(GLUE.state.states) do
        for aff in pairs(state.affs) do wasPresent[aff] = true end
    end

    local pruned    = false
    local remaining = {}
    for _, state in ipairs(GLUE.state.states) do
        if (state.prob or 0) >= PRUNE_THRESHOLD then
            table.insert(remaining, state)
        else
            pruned = true
            if GLUE.config.echos or GLUE.config.debug then
                local affNames = {}
                for aff in pairs(state.affs) do table.insert(affNames, aff) end
                GLUE.queueEcho(string.format("\n<red>[GLUE Huff]<reset> Pruned (%.0f%%): %s",
                    (state.prob or 0) * 100, table.concat(affNames, ", ")))
            end
        end
    end

    if pruned then
        GLUE.state.states = remaining
        GLUE.state.Normalize()
        if GLUE.OnAfflictionCured then
            for aff in pairs(wasPresent) do
                if not GLUE.state.HasAffliction(aff) then
                    GLUE.OnAfflictionCured(aff)
                end
            end
        end
    end
end)

GLUE.huff.Start()

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Huff State Pruner")
end
