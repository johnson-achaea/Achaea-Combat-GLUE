--[[
    G.L.U.E. Salve Cure Handler (State-Based)
    Handles state branching when target applies salves
]]--

GLUE = GLUE or {}
GLUE.cure = GLUE.cure or {}

--[[
    Process salve application using state-based tracking
    @param location (string) - Where the salve was applied (e.g., "body", "arms", "legs")

    Logic:
    1. If they applied salve, they don't have slickness (can't apply salve with slickness)
    2. If they applied salve, they must have had at least one salve-curable aff for that location
    3. Branch states based on which salve-curable aff was cured
]]--
function GLUE.cure.Salve(location)
    if not location then return end

    -- Check if we have this location in our database
    local affsList = GLUE.affs.salve[location]
    if not affsList then
        if GLUE.config.debug then
            cecho("\n<red>[GLUE]<reset> Unknown salve location: " .. location)
        end
        return
    end

    -- Check if they're on salve balance - if so, applying does nothing
    if GLUE.balance.salve == 1 then
        if GLUE.config.debug then
            cecho(string.format("\n<yellow>[GLUE]<reset> Ignored salve (on balance, %.1fs remaining)",
                GLUE.balance.TimeRemaining("salve")))
        end
        return
    end

    -- Mark salve balance as used
    GLUE.balance.SetOffBalance("salve")

    -- PRUNING 1: If they applied salve, they don't have slickness
    GLUE.state.PruneStatesWithAffliction("bloodfire")
    GLUE.state.PruneStatesWithAffliction("slickness")

    -- Arms/legs: limb damage is tracked deterministically in the flat table.
    -- Restoration (damaged/mangled) is handled after 4s by RestorationComplete.
    -- Mending (broken) cures immediately — apply to all states uniformly.
    if location == "arms" or location == "legs" then
        local limbPairs = location == "arms"
            and {"left arm", "right arm"}
            or  {"left leg", "right leg"}

        for _, limb in ipairs(limbPairs) do
            local damage = GLUE.limbs.GetDamage(GLUE.target.name, limb)
            local suffix  = limb:gsub(" ", "")
            if damage > 100 then
                -- Restoration (damaged/mangled): RestorationComplete handles after 4s
                break
            elseif GLUE.state.HasAffliction("broken" .. suffix) then
                -- Mending: broken limb. Flat damage is always 0 at this stage
                -- (it is reset when damaged/mangled is cured, not when broken is).
                GLUE.state.RemoveAffliction("broken" .. suffix)
                if GLUE.config.debug then
                    cecho(string.format("\n<green>[GLUE Salve]<reset> Mend: %s cured", limb))
                end
                break
            end
        end
        return
    else
        -- For other locations, branch for all possibilities
        local newStates = {}

        for _, state in ipairs(GLUE.state.states) do
            local curableInState = {}
            for _, aff in ipairs(affsList) do
                if state.affs[aff] and not GLUE.affs.restore_downgrade[aff] then
                    table.insert(curableInState, aff)
                end
            end

            -- For chained affs (e.g. freeze chain), only keep the highest-priority
            -- chain member so the cure is deterministic rather than branched.
            for _, chain in pairs(GLUE.affs.salve_chains or {}) do
                local chainIdx = {}
                for i, aff in ipairs(chain) do chainIdx[aff] = i end
                local bestIdx = nil
                for _, aff in ipairs(curableInState) do
                    local i = chainIdx[aff]
                    if i and (not bestIdx or i < bestIdx) then bestIdx = i end
                end
                if bestIdx then
                    local filtered = {}
                    for _, aff in ipairs(curableInState) do
                        if not chainIdx[aff] or chainIdx[aff] == bestIdx then
                            table.insert(filtered, aff)
                        end
                    end
                    curableInState = filtered
                end
            end

            local baseProb = state.prob or 1
            local wasteWeight = GLUE.config.wastePenalty or 0.1

            if #curableInState == 0 then
                -- Salve applied but nothing curable in this state: penalize
                local s = GLUE.state.CopyState(state)
                s.prob = baseProb * wasteWeight
                table.insert(newStates, s)
            else
                -- Waste branch gets wastePenalty weight; each cure branch gets weight 1
                local totalWeight = #curableInState + wasteWeight
                local wasteState = GLUE.state.CopyState(state)
                wasteState.prob = baseProb * wasteWeight / totalWeight
                table.insert(newStates, wasteState)
                for _, curedAff in ipairs(curableInState) do
                    local cureState = GLUE.state.CopyState(state)
                    cureState.affs[curedAff] = nil
                    cureState.prob = baseProb / totalWeight
                    table.insert(newStates, cureState)
                end
                if GLUE.config.debug then
                    if #curableInState == 1 then
                        GLUE.queueEcho(string.format("\n<green>[GLUE]<reset> Cured %s", curableInState[1]), "cured")
                    else
                        GLUE.queueEcho(string.format("\n<cyan>[GLUE]<reset> Branched salve cure: %d possibilities",
                            #curableInState), "branched")
                    end
                end
            end
        end

        GLUE.state.states = newStates
    end

    GLUE.state.Optimize()
end

--[[
    Process restoration salve completion (silent, no message)
    Called after 4s when restoration salve completes

    Downgrades limb break afflictions by one level:
    mangled → damaged, damaged → broken, serioustrauma → mildtrauma → cured
    Also updates flat limb damage tracking via GLUE.limbs.HandleRestorationCure
]]--
function GLUE.cure.RestorationComplete(location, apply_id)
    if GLUE.config.debug then
        cecho(string.format("\n<green>[GLUE RestorationComplete]<reset> %s (%d states)", location, #GLUE.state.states))
    end

    -- Only resolve states carrying this specific apply_id.
    -- Iterate the ordered salve list so left-side limbs are always picked first.
    local anyResolved = false
    for _, state in ipairs(GLUE.state.states) do
        if state.pending_restore
            and state.pending_restore.location == location
            and state.pending_restore.apply_id == apply_id
        then
            anyResolved = true
            state.pending_restore = nil
            local affsList = GLUE.affs.salve[location]
            for _, aff in ipairs(affsList or {}) do
                if state.affs[aff] and GLUE.affs.restore_downgrade[aff] ~= nil then
                    local newAff = GLUE.affs.restore_downgrade[aff]
                    state.affs[aff] = nil
                    if newAff ~= "" then
                        state.affs[newAff] = 1
                    end
                    break
                end
            end
        end
    end

    -- Only update flat limb damage if at least one restoration branch was actually resolved.
    -- If all surviving states were mend branches (no pending_restore), flat damage stays put.
    if anyResolved and GLUE.limbs and GLUE.limbs.HandleRestorationCure and GLUE.target.name ~= "" then
        GLUE.limbs.HandleRestorationCure(GLUE.target.name, location)
    end

    GLUE.state.Optimize()

    if GLUE.UpdateDisplay then
        GLUE.UpdateDisplay()
    end
end

--[[
    Process blue energy message (Restored trigger)
    Blue energy only appears when curing broken limbs - cures all 4 broken limbs completely
]]--
function GLUE.cure.Restore()
    local curedLimbs = {
        "brokenleftarm",
        "brokenrightarm",
        "brokenleftleg",
        "brokenrightleg"
    }

    for _, aff in ipairs(curedLimbs) do
        GLUE.state.RemoveAffliction(aff)
    end

    if GLUE.config.debug then
        cecho("\n<green>[GLUE]<reset> Blue energy - all broken limbs cured")
    end

    if GLUE.UpdateDisplay then
        GLUE.UpdateDisplay()
    end
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Salve Cure Handler (State-Based)")
end
