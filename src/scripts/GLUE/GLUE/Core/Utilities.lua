--[[
    G.L.U.E. Utility Functions
]]--

GLUE = GLUE or {}
GLUE.util = GLUE.util or {}

function GLUE.util.ShowStatus()
    local affList = GLUE.state.GetAfflictionList(0)

    if #affList == 0 then
        cecho("\n<green>[GLUE]<reset> No afflictions tracked")
        return
    end

    cecho(string.format("\n<green>[GLUE]<reset> %d states, tracked afflictions:", #GLUE.state.states))
    for _, entry in ipairs(affList) do
        cecho(string.format("\n  <cyan>%s<reset>: <yellow>%.1f%%<reset>",
            entry.affliction, entry.probability))
    end
end

function GLUE.util.ShowStates()
    cecho("\n<green>[GLUE]<reset> " .. GLUE.state.GetStatesSummary())
end

function GLUE.util.GetTopAfflictions(count)
    count = count or 5
    local affList = GLUE.state.GetAfflictionList(0)
    local result = {}
    for i = 1, math.min(count, #affList) do
        table.insert(result, affList[i])
    end
    return result
end

function GLUE.util.GetCurableAfflictions(cureMethod, herbOrLocation)
    local affsList = {}

    if cureMethod == "herb" and herbOrLocation then
        affsList = GLUE.affs.herbs[herbOrLocation] or {}
    elseif cureMethod == "smoke" then
        affsList = GLUE.affs.smoke
    elseif cureMethod == "focus" then
        affsList = GLUE.affs.focus
    elseif cureMethod == "tree" then
        affsList = GLUE.affs.tree
    elseif cureMethod == "salve" and herbOrLocation then
        affsList = GLUE.affs.salve[herbOrLocation] or {}
    elseif cureMethod == "restore" then
        affsList = GLUE.affs.restore
    end

    local result = {}
    for _, aff in ipairs(affsList) do
        local prob = GLUE.state.GetProbability(aff)
        if prob > 0 then
            table.insert(result, { affliction = aff, probability = prob })
        end
    end

    table.sort(result, function(a, b) return a.probability > b.probability end)
    return result
end

function GLUE.util.GetStats()
    local stats = {
        stateCount = #GLUE.state.states,
        afflictionCount = GLUE.state.CountAfflictions(0),
        highConfidence = GLUE.state.CountAfflictions(75),
        mediumConfidence = GLUE.state.CountAfflictions(25),
    }

    local totalAffs = 0
    for _, state in ipairs(GLUE.state.states) do
        local count = 0
        for _ in pairs(state.affs) do count = count + 1 end
        totalAffs = totalAffs + count
    end
    stats.avgAffsPerState = #GLUE.state.states > 0 and (totalAffs / #GLUE.state.states) or 0

    return stats
end

function GLUE.util.PruneWith(affliction)
    return GLUE.state.PruneStatesWithAffliction(affliction)
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Utility Functions")
end
