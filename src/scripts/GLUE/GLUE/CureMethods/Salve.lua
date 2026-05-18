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
            elseif damage > 0 or GLUE.state.HasAffliction("broken" .. suffix) then
                -- Mending: broken limb (either flat table or aff state — restoration
                -- downgrades to broken while resetting flat damage to 0)
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

            -- Always include the fake-apply possibility (salve did nothing).
            local branches = {}
            table.insert(branches, GLUE.state.CopyState(state))

            if #curableInState == 1 then
                local newState = GLUE.state.CopyState(state)
                newState.affs[curableInState[1]] = nil
                table.insert(branches, newState)
                if GLUE.config.debug then
                    GLUE.queueEcho(string.format("\n<green>[GLUE]<reset> Cured %s", curableInState[1]))
                end
            elseif #curableInState > 1 then
                for _, curedAff in ipairs(curableInState) do
                    local newState = GLUE.state.CopyState(state)
                    newState.affs[curedAff] = nil
                    table.insert(branches, newState)
                end
                if GLUE.config.debug then
                    GLUE.queueEcho(string.format("\n<cyan>[GLUE]<reset> Branched salve cure: %d possibilities",
                        #curableInState))
                end
            end

            local branchProb = (state.prob or 1) / #branches
            for _, s in ipairs(branches) do
                s.prob = branchProb
                table.insert(newStates, s)
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
function GLUE.cure.RestorationComplete(location)
    if GLUE.config.debug then
        cecho(string.format("\n<green>[GLUE RestorationComplete]<reset> %s (%d states)", location, #GLUE.state.states))
    end

    -- Downgrade restoration afflictions in all states
    for _, state in ipairs(GLUE.state.states) do
        local toDowngrade = {}
        local affsList = GLUE.affs.salve[location]

        for currentAff, _ in pairs(state.affs) do
            if GLUE.affs.restore_downgrade[currentAff] then
                if affsList and table.contains(affsList, currentAff) then
                    local newAff = GLUE.affs.restore_downgrade[currentAff]
                    table.insert(toDowngrade, {old = currentAff, new = newAff})
                end
            end
        end

        for _, change in ipairs(toDowngrade) do
            state.affs[change.old] = nil
            if change.new and change.new ~= "" then
                state.affs[change.new] = 1
            end
        end
    end

    -- Update flat limb damage tracking
    if GLUE.limbs and GLUE.limbs.HandleRestorationCure and GLUE.target.name ~= "" then
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
