--[[
    G.L.U.E. Smoke Cure Handler (State-Based)
    Handles state branching/pruning when target smokes

    Unweavingspirit is handled here as a stack decrement (min 1).
    Smoked.lua catches the full-cure confirmation message (fires only at 0 stacks)
    and calls RemoveAffliction there instead; by the time this function runs,
    the target either cured a different aff or decremented spirit without fully
    clearing it.
]]--

GLUE = GLUE or {}
GLUE.cure = GLUE.cure or {}

function GLUE.cure.Smoke()
    if GLUE.balance.smoke == 1 then
        if GLUE.config.debug then
            cecho(string.format("\n<yellow>[GLUE]<reset> Ignored smoke (on balance, %.1fs remaining)",
                GLUE.balance.TimeRemaining("smoke")))
        end
        return
    end

    GLUE.balance.SetOffBalance("smoke")

    -- PRUNING 1: If they smoked, they don't have asthma
    GLUE.state.PruneStatesWithAffliction("asthma")

    if #GLUE.state.states == 0 then
        if GLUE.config.debug then
            cecho("\n<yellow>[GLUE]<reset> All states had asthma but they smoked")
        end
    end

    -- PRUNING 2: If no tracked states have smoke-curable affs, assume rebounding
    -- (unweavingspirit counts since smoke can decrement it)
    local anySmokeable = false
    for _, state in ipairs(GLUE.state.states) do
        if state.affs["unweavingspirit"] then
            anySmokeable = true
            break
        end
        for _, aff in ipairs(GLUE.affs.smoke) do
            if state.affs[aff] then
                anySmokeable = true
                break
            end
        end
        if anySmokeable then break end
    end

    if not anySmokeable then
        if GLUE.config.debug then
            cecho("\n<cyan>[GLUE]<reset> No smoke-curable affs tracked - assuming rebounding in 8.5s")
        end
        tempTimer(8.5, function()
            GLUE.defenses.Set("rebounding", true)
        end)
        return
    end

    -- BRANCHING: For each state, create branches for each possible cure
    local newStates = {}

    for _, state in ipairs(GLUE.state.states) do
        local curableInState = {}
        for _, aff in ipairs(GLUE.affs.smoke) do
            if state.affs[aff] then table.insert(curableInState, aff) end
        end
        local spiritStacks = state.affs["unweavingspirit"]
        local totalOptions = #curableInState + (spiritStacks and 1 or 0)

        local wasted = (totalOptions == 0)
        local branches = {}

        if totalOptions == 0 then
            table.insert(branches, GLUE.state.CopyState(state))

        elseif totalOptions == 1 and spiritStacks and #curableInState == 0 then
            local newState = GLUE.state.CopyState(state)
            newState.affs["unweavingspirit"] = math.max(spiritStacks - 1, 1)
            table.insert(branches, newState)
            if GLUE.config.echos or GLUE.config.debug then
                GLUE.queueEcho(string.format("\n<green>[GLUE]<reset> unweavingspirit -%d", 1))
            end

        elseif totalOptions == 1 then
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
            if spiritStacks then
                local newState = GLUE.state.CopyState(state)
                newState.affs["unweavingspirit"] = math.max(spiritStacks - 1, 1)
                table.insert(branches, newState)
            end
            local options = {}
            for _, a in ipairs(curableInState) do table.insert(options, a) end
            if spiritStacks then table.insert(options, "spirit-1") end
            if GLUE.config.echos or GLUE.config.debug then
                GLUE.queueEcho(string.format("\n<cyan>[GLUE]<reset> Smoke: %s", table.concat(options, "/")), "branched")
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
    cecho("\n<green>[GLUE]<reset> Loaded: Smoke Cure Handler (State-Based)")
end
