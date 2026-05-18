--[[
    G.L.U.E. Weaponry Tracking
    Handles weapon venom tracking and application
]]--

GLUE = GLUE or {}
GLUE.cure = GLUE.cure or {}
GLUE.venoms = GLUE.venoms or {}

-- Add a venom to a weapon's queue
function GLUE.venoms.AddToWeapon(venom, weapon)
    -- Initialize weapon queue if needed
    GLUE.venoms.on_weapons[weapon] = GLUE.venoms.on_weapons[weapon] or {}

    -- Special handling for certain venoms that should go in specific positions
    local lockout = {"torture", "tormentone", "tormenttwo", "exploit"}

    if #GLUE.venoms.on_weapons[weapon] > 0 and table.contains(lockout, GLUE.venoms.on_weapons[weapon][1]) then
        -- If first venom is a lockout venom, insert at position 2
        table.insert(GLUE.venoms.on_weapons[weapon], 2, venom)
    else
        -- Normal insert at front of queue
        table.insert(GLUE.venoms.on_weapons[weapon], 1, venom)
    end

    if GLUE.config.debug then
        cecho(string.format("\n<cyan>[GLUE]<reset> Added %s to %s (queue: %d)", venom, weapon, #GLUE.venoms.on_weapons[weapon]))
    end
end

-- Record a weapon attack (weapon was used)
function GLUE.venoms.RecordAttack(weapon)
    GLUE.venoms.pending_weapons = GLUE.venoms.pending_weapons or {}
    table.insert(GLUE.venoms.pending_weapons, weapon)

    if GLUE.config.debug then
        cecho(string.format("\n<yellow>[GLUE]<reset> Attack recorded with %s", weapon))
    end
end

-- Process a confirmed hit (apply venoms from pending weapons)
function GLUE.venoms.ProcessHit()
    if not GLUE.venoms.pending_weapons or #GLUE.venoms.pending_weapons == 0 then
        return
    end

    local afflictions = {}

    -- Process each weapon that was used
    for _, weapon in ipairs(GLUE.venoms.pending_weapons) do
        GLUE.venoms.on_weapons[weapon] = GLUE.venoms.on_weapons[weapon] or {}

        -- Pop first venom from this weapon's queue
        if #GLUE.venoms.on_weapons[weapon] > 0 then
            local venom = table.remove(GLUE.venoms.on_weapons[weapon], 1)
            local affliction = GLUE.venoms.map[venom]

            if affliction then
                table.insert(afflictions, affliction)

                if GLUE.config.debug then
                    GLUE.queueEcho(string.format("\n<green>[GLUE]<reset> %s venom (%s) -> %s", weapon, venom, affliction))
                end
            end
        end
    end

    -- Clear pending weapons
    GLUE.venoms.pending_weapons = {}

    -- Apply all afflictions
    for _, aff in ipairs(afflictions) do
        GLUE.state.AddAffliction(aff)
    end

    if #afflictions > 0 and GLUE.config.debug then
        cecho(string.format("\n<green>[GLUE]<reset> Weapon hit - applied %d affliction(s)", #afflictions))
    end
end

-- Clear all pending attacks (for dodges, parries, etc.)
function GLUE.venoms.ClearPending()
    if GLUE.venoms.pending_weapons and #GLUE.venoms.pending_weapons > 0 then
        if GLUE.config.debug then
            cecho("\n<red>[GLUE]<reset> Attack missed - clearing pending weapons")
        end
        GLUE.venoms.pending_weapons = {}
    end
end
