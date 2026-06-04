--[[
    G.L.U.E. Herb Cure Handler (State-Based)
    Handles state branching/pruning when target eats herbs
]]--

GLUE = GLUE or {}
GLUE.cure = GLUE.cure or {}

--[[
    Process herb consumption using state-based tracking
    @param herbName (string) - The herb that was eaten (e.g., "piece of kelp", "goldenseal root")

    Logic:
    1. If they can't eat (have anorexia), prune all states without anorexia
    2. Find which tracked afflictions this herb could cure
    3. For each state, branch into N outcomes (one for each possible cure)

    Note: unweaving affs (unweavingmind, unweavingbody) are NOT in any herb cure list.
    Their cures are confirmed by specific game messages handled in Ate_Herb.lua,
    which gives certainty without branching.
]]--
function GLUE.cure.Herb(herbName)
    if not herbName then return end

    -- Check if they're on herb balance - if so, eating does nothing
    if GLUE.balance.herb == 1 then
        if GLUE.config.debug then
            cecho(string.format("\n<yellow>[GLUE]<reset> Ignored herb eat (on balance, %.1fs remaining)",
                GLUE.balance.TimeRemaining("herb")))
        end
        return
    end

    -- Check if we have this herb in our database
    local affsList = GLUE.affs.herbs[herbName]
    if not affsList then
        cecho("\n<red>[GLUE]<reset> Unknown herb: " .. herbName)
        return
    end

    -- Mark herb balance as used
    GLUE.balance.SetOffBalance("herb")

    -- PRUNING 1: If they ate something, they don't have anorexia
    GLUE.state.PruneStatesWithAffliction("anorexia")

    if #GLUE.state.states == 0 then
        if GLUE.config.debug then
            cecho("\n<yellow>[GLUE]<reset> No states had curable affs for " .. herbName)
        end
        return
    end

    -- BRANCHING: For each state, create branches for each possible cure
    local newStates = {}

    for _, state in ipairs(GLUE.state.states) do
        local curableInState = {}
        for _, aff in ipairs(affsList) do
            if state.affs[aff] then
                table.insert(curableInState, aff)
            end
        end

        local wasted = (#curableInState == 0)
        local branches = {}

        if #curableInState == 0 then
            table.insert(branches, GLUE.state.CopyState(state))
        elseif #curableInState == 1 then
            local curedAff = curableInState[1]
            local linked   = GLUE.affs.curedWith and GLUE.affs.curedWith[curedAff]
            local newState = GLUE.state.CopyState(state)
            newState.affs[curedAff] = nil
            if linked then for a in pairs(linked) do newState.affs[a] = nil end end
            table.insert(branches, newState)
            if GLUE.config.echos or GLUE.config.debug then
                local _col = GLUE.affs and GLUE.affs.colorMap and GLUE.affs.colorMap[curedAff] or "white"
                GLUE.queueEcho(string.format("\n<red>[GLUE]<reset> -%s%s<reset>", "<" .. _col .. ">", curedAff), "removed")
            end
        else
            for _, curedAff in ipairs(curableInState) do
                local linked   = GLUE.affs.curedWith and GLUE.affs.curedWith[curedAff]
                local newState = GLUE.state.CopyState(state)
                newState.affs[curedAff] = nil
                if linked then for a in pairs(linked) do newState.affs[a] = nil end end
                table.insert(branches, newState)
            end
            if GLUE.config.echos or GLUE.config.debug then
                GLUE.queueEcho(string.format("\n<cyan>[GLUE]<reset> Herb: %s",
                    table.concat(curableInState, "/")), "branched")
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

    if #GLUE.state.states > GLUE.config.maxStates then
        GLUE.state.Optimize()
    elseif #GLUE.state.states > 10 then
        GLUE.state.Optimize()
    end

    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Herb Cure Handler (State-Based)")
end
