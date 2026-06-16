--[[
    G.L.U.E. Cure Priorities & Generic Tiered Cure Handler
    Priority tables for passive, tree, and any future tiered cure methods.
    Lower tier number = higher priority (cured first).
]]--

GLUE = GLUE or {}
GLUE.affs = GLUE.affs or {}
GLUE.cure = GLUE.cure or {}

-- Explicit priority tables: aff → tier (1 = highest, 2 = lower, etc.)
GLUE.affs.cure_priority = {
    passive = {
        -- Tier 0: always cured before anything else
        voyria          = 0,
        -- Tier 1: standard passive-curable affs + unweavingspirit
        timeloop        = 1, parasite       = 1, retribution    = 1, shadowmadness  = 1,
        depression      = 1, pyramides      = 1, itching        = 1, crushedthroat  = 1,
        stuttering      = 1, addiction      = 1, agoraphobia    = 1,
        anorexia        = 1, asthma         = 1, claustrophobia = 1, clumsiness     = 1,
        confusion       = 1, brokenleftarm  = 1, brokenrightarm = 1, brokenleftleg  = 1,
        brokenrightleg  = 1, darkshade      = 1, deadening      = 1, dementia       = 1,
        disloyalty      = 1, disrupt        = 1, dizziness      = 1, epilepsy       = 1,
        generosity      = 1, haemophilia    = 1, hallucinations = 1, healthleech    = 1,
        hellsight       = 1, hypersomnia    = 1, hypochondria   = 1, impatience     = 1,
        lethargy        = 1, loneliness     = 1, lovers         = 1, manaleech      = 1,
        masochism       = 1, nausea         = 1, pacifism       = 1, paranoia       = 1,
        recklessness    = 1, scytherus      = 1, selarnia       = 1, sensitivity    = 1,
        shyness         = 1, slickness      = 1, stupidity      = 1, weariness      = 1,
        vertigo         = 1, tension        = 1, pressure       = 1, mycalium       = 1,
        sandfever       = 1, rebbies        = 1, flushings      = 1, unweavingspirit = 1,
        paralysis       = 1, frozen         = 1, shivering      = 1,
        -- Tier 2: stacks (lower priority)
        torntendon      = 2, skullfracture  = 2, wristfracture  = 2, crackedrib     = 2,
        melancholic     = 2, choleric       = 2,
        phlegmatic      = 2, sanguine       = 2, burning        = 2,
    },
    tree = {
        blackout = 0,
        -- Tier 1: all standard tree-curable affs
        crushedthroat   = 1, stuttering     = 1, itching        = 1, aeon           = 1,
        healthleech     = 1, haemophilia    = 1, clumsiness     = 1,
        paranoia        = 1, vertigo        = 1, agoraphobia    = 1, dizziness      = 1,
        claustrophobia  = 1, recklessness   = 1, epilepsy       = 1, addiction      = 1,
        stupidity       = 1, scytherus      = 1, slickness      = 1, generosity     = 1,
        justice         = 1, pacifism       = 1, confusion      = 1, voyria         = 1,
        weariness       = 1, hallucinations = 1, disloyalty     = 1, lethargy       = 1,
        shyness         = 1, sensitivity    = 1, asthma         = 1, brokenleftarm  = 1,
        brokenrightarm  = 1, brokenleftleg  = 1, brokenrightleg = 1, darkshade      = 1,
        impatience      = 1, anorexia       = 1, loneliness     = 1, hypochondria   = 1,
        selarnia        = 1, frozen         = 1, airdisrupt     = 1, earthdisrupt   = 1,
        firedisrupt     = 1, spiritdisrupt  = 1, waterdisrupt   = 1, hellsight      = 1,
        nausea          = 1, lovers         = 1, parasite       = 1, depression     = 1,
        timeloop        = 1, manaleech      = 1, tension        = 1, tenderskin     = 1,
        spiritburn      = 1, pyramides      = 1, sandfever      = 1, fratricide     = 1,
        unweavingspirit = 1, shivering      = 1,
        -- Tier 2:  stacks (lower priority)
        torntendon      = 2, skullfracture  = 2, wristfracture  = 2, crackedrib     = 2,
        melancholic     = 2, choleric       = 2,
        phlegmatic      = 2, sanguine       = 2, burning        = 2,
    },
    expunge = {
        impatience = 0,
        -- Tier 1: all focus-curable affs
        stuttering      = 1, lovers         = 1, agoraphobia    = 1, anorexia       = 1,
        claustrophobia  = 1, confusion      = 1, dizziness      = 1, epilepsy       = 1,
        generosity      = 1, loneliness     = 1, masochism      = 1, pacifism       = 1,
        recklessness    = 1, shyness        = 1, stupidity      = 1, vertigo        = 1,
        airdisrupt      = 1, firedisrupt    = 1, waterdisrupt   = 1, paranoia       = 1,
        dementia        = 1, hallucinations = 1,
    },
}

-- Build a new state with curedAff removed (or decremented if stacking),
-- plus any linked affs from GLUE.affs.curedWith.
local function buildCuredState(state, curedAff)
    local linked   = GLUE.affs.curedWith and GLUE.affs.curedWith[curedAff]
    local newState = GLUE.state.CopyState(state)
    if curedAff == "unweavingspirit" then
        local remaining = (state.affs[curedAff] or 1) - 1
        if remaining > 0 then newState.affs[curedAff] = remaining else newState.affs[curedAff] = nil end
    else
        newState.affs[curedAff] = nil
    end
    if linked then for a in pairs(linked) do newState.affs[a] = nil end end
    return newState
end

-- Generic tiered cure: resolve one cure event across all states using
-- the given priority table (aff → tier number, lower = higher priority).
-- Each state branches only on its highest-priority tier.
function GLUE.cure.ApplyTiered(priorityTable)
    local wasPresent = {}
    for _, state in ipairs(GLUE.state.states) do
        for aff in pairs(state.affs) do wasPresent[aff] = true end
    end

    local newStates = {}

    for _, state in ipairs(GLUE.state.states) do
        local bestTier = math.huge
        for aff in pairs(state.affs) do
            local t = priorityTable[aff]
            if t and t < bestTier then bestTier = t end
        end

        local wasted = (bestTier == math.huge)
        local branches = {}

        if bestTier == math.huge then
            table.insert(branches, GLUE.state.CopyState(state))
        else
            local curableInState = {}
            for aff in pairs(state.affs) do
                if priorityTable[aff] == bestTier then
                    table.insert(curableInState, aff)
                end
            end

            if #curableInState == 1 then
                table.insert(branches, buildCuredState(state, curableInState[1]))
                if GLUE.config.echos or GLUE.config.debug then
                    local _col = GLUE.affs and GLUE.affs.colorMap and GLUE.affs.colorMap[curableInState[1]] or "white"
                    GLUE.queueEcho(string.format("\n<red>[GLUE]<reset> -%s%s<reset>", "<" .. _col .. ">", curableInState[1]), "removed")
                end
            else
                for _, curedAff in ipairs(curableInState) do
                    table.insert(branches, buildCuredState(state, curedAff))
                end
                if GLUE.config.echos or GLUE.config.debug then
                    GLUE.queueEcho(string.format("\n<cyan>[GLUE]<reset> Branched cure (tier %d): %s",
                        bestTier, table.concat(curableInState, "/")), "branched")
                end
            end
        end

        local baseProb = (state.prob or 1)
        if wasted then baseProb = baseProb * (GLUE.config.wastePenalty or 0.1) end
        local branchProb = baseProb / #branches
        for _, s in ipairs(branches) do
            s.prob = branchProb
            table.insert(newStates, s)
        end
    end

    GLUE.state.states = newStates

    if GLUE.OnAfflictionCured then
        for aff in pairs(wasPresent) do
            if not GLUE.state.HasAffliction(aff) then
                GLUE.OnAfflictionCured(aff)
            end
        end
    end

    if #GLUE.state.states > GLUE.config.maxStates then
        GLUE.state.Optimize()
    elseif #GLUE.state.states > 10 then
        GLUE.state.Optimize()
    end

    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Cure Priorities & Tiered Handler")
end
