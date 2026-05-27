--[[
    G.L.U.E. Defense Tracking
    Tracks target defenses (shield, rebounding, prismatic, etc.)

    Unlike afflictions, defenses are directly observable and don't require
    state-based uncertainty tracking.
]]--

GLUE = GLUE or {}
GLUE.defenses = GLUE.defenses or {}

-- Defense state for current target
GLUE.defenses.current = {
    shield = false,
    rebounding = false,
    curseward = false,
    reflection = false,
    prismatic = false,
    cloak = false,
    sileris = false,
    aria = false,
    hands = false,
    healing = false,
    breathing = false,
    speed = true,
    blind = true,
    deaf = true,
}

--[[
    Set a defense state
    @param defense (string) - The defense name
    @param state (boolean) - true if up, false if down
]]--
function GLUE.defenses.Set(defense, state)
    if not defense then return end

    if GLUE.defenses.current[defense] == nil then
        if GLUE.config.debug then
            cecho(string.format("\n<yellow>[GLUE]<reset> Unknown defense: %s", defense))
        end
        return
    end

    local oldState = GLUE.defenses.current[defense]
    GLUE.defenses.current[defense] = state

    if oldState ~= state then
        if GLUE.config.echos or GLUE.config.debug then
            local stateStr = state and "UP" or "DOWN"
            cecho(string.format("\n<cyan>[GLUE]<reset> Defense %s: %s", defense, stateStr))
        end
        if GLUE.OnDefenseChanged then GLUE.OnDefenseChanged(defense, state) end
    end

    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
end

--[[
    Check if a defense is up
    @param defense (string) - The defense name
    @return (boolean) - true if defense is up
]]--
function GLUE.defenses.Has(defense)
    if not defense then return false end
    return GLUE.defenses.current[defense] == true
end

--[[
    Reset all defenses (e.g., on target change or death)
]]--
function GLUE.defenses.Reset()
    for defense, _ in pairs(GLUE.defenses.current) do
        GLUE.defenses.current[defense] = false
    end
    GLUE.defenses.current.speed = true
    GLUE.defenses.current.blind = true
    GLUE.defenses.current.deaf  = true

    if GLUE.config.debug then
        cecho("\n<green>[GLUE]<reset> All defenses cleared")
    end

    -- Update display if callback exists
    if GLUE.UpdateDisplay then
        GLUE.UpdateDisplay()
    end
end

--[[
    Get all current defenses as a list
    @return (table) - Array of defense names that are currently up
]]--
function GLUE.defenses.GetActive()
    local active = {}
    for defense, state in pairs(GLUE.defenses.current) do
        if state then
            table.insert(active, defense)
        end
    end
    return active
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Defense Tracking")
end
