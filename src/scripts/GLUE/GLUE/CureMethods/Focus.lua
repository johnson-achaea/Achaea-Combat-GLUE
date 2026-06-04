--[[
    G.L.U.E. Focus Cure Handler (State-Based)
    Handles state branching when target uses focus
]]--

GLUE = GLUE or {}
GLUE.cure = GLUE.cure or {}

--[[
    Process focus ability usage using state-based tracking
    Handles when the target uses focus to cure mental afflictions

    Logic:
    1. If they focused, they don't have impatience (can't focus with impatience)
    2. If they focused, they must have had at least one focus-curable aff
    3. Branch states based on which focus-curable aff was cured
]]--
function GLUE.cure.Focus()
    -- Check if they're on focus balance - if so, focusing does nothing
    if GLUE.balance.focus == 1 then
        if GLUE.config.debug then
            cecho(string.format("\n<yellow>[GLUE]<reset> Ignored focus (on balance, %.1fs remaining)",
                GLUE.balance.TimeRemaining("focus")))
        end
        return
    end

    -- Mark focus balance as used
    GLUE.balance.SetOffBalance("focus")

    -- PRUNING 1: If they focused, they don't have impatience
    GLUE.state.PruneStatesWithAffliction("impatience")

    -- BRANCHING: For each state, create branches for each possible cure
    -- States with no tracked focus-curable affs are preserved unchanged
    -- (a teammate may have given something we haven't tracked)
    local newStates = {}

    for _, state in ipairs(GLUE.state.states) do
        local curableInState = {}
        for _, aff in ipairs(GLUE.affs.focus) do
            if state.affs[aff] then
                table.insert(curableInState, aff)
            end
        end

        local wasted = (#curableInState == 0)
        local branches = {}

        if #curableInState == 0 then
            table.insert(branches, GLUE.state.CopyState(state))
        elseif #curableInState == 1 then
            local newState = GLUE.state.CopyState(state)
            newState.affs[curableInState[1]] = nil
            table.insert(branches, newState)
            if GLUE.config.echos or GLUE.config.debug then
                local _col = GLUE.affs and GLUE.affs.colorMap and GLUE.affs.colorMap[curableInState[1]] or "white"
                GLUE.queueEcho(string.format("\n<red>[GLUE]<reset> -%s%s<reset>", "<" .. _col .. ">", curableInState[1]), "removed")
            end
        else
            for _, curedAff in ipairs(curableInState) do
                local newState = GLUE.state.CopyState(state)
                newState.affs[curedAff] = nil
                table.insert(branches, newState)
            end
            if GLUE.config.echos or GLUE.config.debug then
                GLUE.queueEcho(string.format("\n<cyan>[GLUE]<reset> Focus: %s",
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

    -- Optimize state space if needed
    if #GLUE.state.states > GLUE.config.maxStates then
        GLUE.state.Optimize()
    elseif #GLUE.state.states > 10 then
        GLUE.state.Optimize()
    end

    -- Update display if callback exists
    if GLUE.UpdateDisplay then
        GLUE.UpdateDisplay()
    end
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Focus Cure Handler (State-Based)")
end
