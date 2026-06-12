--[[
    G.L.U.E. Target Management
    Handles target switching. Limb damage persists naturally in GLUE.limbs.damage[name]
    and timers continue running across switches. Affs are always reset fresh.
]]--

GLUE = GLUE or {}
GLUE.target = GLUE.target or {}

-- Adjust health/mana percentages by delta (0.0–1.0). Only updates if a value already exists.
function GLUE.target.AdjustVitals(healthDelta, manaDelta)
    if healthDelta and GLUE.target.healthPercent then
        GLUE.target.healthPercent = math.min(1, math.max(0, GLUE.target.healthPercent + healthDelta))
        if GLUE.target.healthMax then
            GLUE.target.health = math.floor(GLUE.target.healthPercent * GLUE.target.healthMax)
        end
    end
    if manaDelta and GLUE.target.manaPercent then
        GLUE.target.manaPercent = math.min(1, math.max(0, GLUE.target.manaPercent + manaDelta))
        if GLUE.target.manaMax then
            GLUE.target.mana = math.floor(GLUE.target.manaPercent * GLUE.target.manaMax)
        end
    end
    if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
end

function GLUE.target.SetTarget(name)
    if not name or name == "" then
        if GLUE.config.debug then
            cecho("\n<red>[GLUE]<reset> Invalid target name")
        end
        return
    end

    if name == GLUE.target.name then return end

    GLUE.target.name = name

    if GLUE.killRestoreTimers then GLUE.killRestoreTimers() end
    GLUE.state.ResetTimedAfflictions()
    GLUE.state.states = {{
        affs            = {},
        prob            = 1.0,
        salve_time      = 0,
        restore_time    = 0,
        pending_restore = nil,
    }}

    GLUE.cure.afterHerb = nil

    if GLUE.balance and GLUE.balance.ResetAll then
        GLUE.balance.ResetAll()
    end

    if GLUE.defenses and GLUE.defenses.Reset then
        GLUE.defenses.Reset()
    end

    if GLUE.UpdateDisplay then
        GLUE.UpdateDisplay()
    end

    if GLUE.config.echos or GLUE.config.debug then
        cecho(string.format("\n<green>[GLUE]<reset> Target set to: %s", name))
    end
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Target Management")
end
