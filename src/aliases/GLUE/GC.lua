--[[
    GLUE Alias: gc
    Manual state garbage collection.
    Prunes all states below 25% probability.
    If none are below 25%, prunes the single lowest-probability state.
]]--

if not GLUE or not GLUE.state then return end

local THRESHOLD = 0.25
local states    = GLUE.state.states
local n         = #states

local wasPresent = {}
for _, s in ipairs(states) do
    for aff in pairs(s.affs) do wasPresent[aff] = true end
end

if n <= 1 then
    cecho("\n<yellow>[GLUE]<reset> GC: only one state, nothing to prune")
    return
end

local remaining = {}
local pruned    = 0
for _, state in ipairs(states) do
    if (state.prob or 0) >= THRESHOLD then
        table.insert(remaining, state)
    else
        pruned = pruned + 1
    end
end

if pruned > 0 and #remaining > 0 then
    GLUE.state.states = remaining
    GLUE.state.Normalize()
    cecho(string.format("\n<green>[GLUE]<reset> GC: pruned %d state%s below %d%% (%d remaining)",
        pruned, pruned == 1 and "" or "s", THRESHOLD * 100, #remaining))

elseif #remaining == 0 then
    -- All states are below threshold — keep the highest-probability one.
    local best = states[1]
    for _, s in ipairs(states) do
        if (s.prob or 0) > (best.prob or 0) then best = s end
    end
    GLUE.state.states = { best }
    GLUE.state.Normalize()
    cecho(string.format("\n<yellow>[GLUE]<reset> GC: all states below %d%%, kept highest (%.1f%%)",
        THRESHOLD * 100, (best.prob or 0) * 100))

else
    -- Nothing below threshold — prune the single lowest-probability state.
    local minIdx, minProb = 1, states[1].prob or 0
    for i = 2, n do
        local p = states[i].prob or 0
        if p < minProb then minIdx, minProb = i, p end
    end
    table.remove(GLUE.state.states, minIdx)
    GLUE.state.Normalize()
    cecho(string.format("\n<green>[GLUE]<reset> GC: pruned lowest state (%.1f%%) (%d remaining)",
        minProb * 100, n - 1))
end

if GLUE.OnAfflictionCured then
    local nowPresent = {}
    for _, s in ipairs(GLUE.state.states) do
        for aff in pairs(s.affs) do nowPresent[aff] = true end
    end
    for aff in pairs(wasPresent or {}) do
        if not nowPresent[aff] then GLUE.OnAfflictionCured(aff) end
    end
end

if GLUE.UpdateDisplay  then GLUE.UpdateDisplay()  end
if GLUE.OnStateUpdate  then GLUE.OnStateUpdate()  end
