--[[
    G.L.U.E. Limb Tracking
    Tracks limb damage as a flat table separate from the state model
]]--

GLUE = GLUE or {}
GLUE.limbs = GLUE.limbs or {}

-- Limb names
GLUE.limbs.names = {"head", "torso", "left arm", "right arm", "left leg", "right leg"}

-- Flat damage table: GLUE.limbs.damage[targetName][limb] = damage%
GLUE.limbs.damage = GLUE.limbs.damage or {}

-- Auto-reset timers per target/limb
-- Structure: timers[name][limb] = {id = timerID, startTime = os.time()}
GLUE.limbs.timers = GLUE.limbs.timers or {}

--[[
    Add limb damage for a target
    Automatically delivers broken/mangled afflictions when crossing thresholds
]]--
function GLUE.limbs.AddHit(name, limb, amount)
    name = name:lower():title()

    GLUE.limbs.damage[name] = GLUE.limbs.damage[name] or {}
    GLUE.limbs.damage[name][limb] = GLUE.limbs.damage[name][limb] or 0

    local oldDamage = GLUE.limbs.damage[name][limb]
    local newDamage = oldDamage + amount
    GLUE.limbs.damage[name][limb] = newDamage

    -- Convert limb name to affliction suffix (e.g., "left arm" -> "leftarm")
    local limbSuffix = limb:gsub(" ", "")

    -- Check if we crossed the >200% threshold (mangled / serioustrauma)
    if oldDamage <= 200 and newDamage > 200 then
        if limb == "torso" then
            GLUE.state.AddAffliction("serioustrauma")
            GLUE.state.RemoveAffliction("mildtrauma")
        else
            GLUE.state.AddAffliction("mangled" .. limbSuffix)
            GLUE.state.RemoveAffliction("damaged" .. limbSuffix)
        end
        GLUE.limbs.damage[name][limb] = 200.1
        if GLUE.config.echos or GLUE.config.debug then
            local label = (limb == "torso") and "SERIOUS TRAUMA" or (limb:upper() .. " MANGLED")
            cecho(string.format("\n<red>--- %s! (>200%%) ---", label))
        end
    -- Check if we crossed the >100% threshold (damaged / mildtrauma)
    elseif oldDamage <= 100 and newDamage > 100 then
        if limb == "torso" then
            GLUE.state.AddAffliction("mildtrauma")
        else
            GLUE.state.AddAffliction("damaged" .. limbSuffix)
            GLUE.state.RemoveAffliction("broken" .. limbSuffix)
            if limb == "head" then
                GLUE.state.AddAffliction("stupidity")
            end
        end
        GLUE.limbs.damage[name][limb] = 100.1
        if GLUE.config.echos or GLUE.config.debug then
            local label = (limb == "torso") and "MILD TRAUMA" or (limb:upper() .. " DAMAGED")
            cecho(string.format("\n<red>--- %s! (>100%%) ---", label))
        end
    end

    -- Kill existing timer for this limb
    GLUE.limbs.timers[name] = GLUE.limbs.timers[name] or {}
    if GLUE.limbs.timers[name][limb] and GLUE.limbs.timers[name][limb].id then
        killTimer(GLUE.limbs.timers[name][limb].id)
    end

    -- Set 180s auto-reset timer
    local timerID = tempTimer(180, function()
        GLUE.limbs.ResetLimb(name, limb)
        GLUE.limbs.timers[name][limb] = nil
    end)

    GLUE.limbs.timers[name][limb] = {
        id = timerID,
        startTime = os.time()
    }

    if GLUE.config.debug then
        local color = newDamage > 100 and "<orange_red>" or "<yellow>"
        cecho(string.format(" %s(%.1f%%)%s", color, newDamage, color))
    end
end

--[[
    Reset a single limb's damage for a target
]]--
function GLUE.limbs.ResetLimb(name, limb)
    name = name:lower():title()

    local limbSuffix = limb:gsub(" ", "")
    local currentDamage = GLUE.limbs.damage[name] and GLUE.limbs.damage[name][limb] or 0

    if currentDamage > 200 then
        GLUE.limbs.damage[name][limb] = 100.1
        if limb == "torso" then
            GLUE.state.RemoveAffliction("serioustrauma")
            GLUE.state.AddAffliction("mildtrauma")
        else
            GLUE.state.RemoveAffliction("mangled" .. limbSuffix)
            GLUE.state.AddAffliction("damaged" .. limbSuffix)
        end
    else
        if GLUE.limbs.damage[name] then
            GLUE.limbs.damage[name][limb] = 0
        end
        if limb == "torso" then
            GLUE.state.RemoveAffliction("mildtrauma")
        else
            GLUE.state.RemoveAffliction("damaged" .. limbSuffix)
            GLUE.state.RemoveAffliction("broken" .. limbSuffix)
        end
    end

    if GLUE.config.echos or GLUE.config.debug then
        cecho(string.format("\n<cyan>[GLUE]<reset> Reset %s's %s", name, limb))
    end
end

--[[
    Handle restoration salve completion (called after 4s)
    Downgrades limb afflictions by one level at the given area
]]--
function GLUE.limbs.HandleRestorationCure(name, area)
    name = name:lower():title()

    local limbMap = {
        head  = {"head"},
        torso = {"torso"},
        arms  = {"left arm", "right arm"},
        legs  = {"left leg", "right leg"},
    }

    local limbs = limbMap[area]
    if not limbs then return end

    -- Only cure ONE limb per restoration (left before right)
    for _, limb in ipairs(limbs) do
        local damage = GLUE.limbs.damage[name] and GLUE.limbs.damage[name][limb] or 0

        if damage > 100 then
            -- Clear the timer for this limb
            if GLUE.limbs.timers[name] and GLUE.limbs.timers[name][limb] and GLUE.limbs.timers[name][limb].id then
                killTimer(GLUE.limbs.timers[name][limb].id)
                GLUE.limbs.timers[name][limb] = nil
            end

            if damage > 200 then
                GLUE.limbs.damage[name][limb] = 100.1
                if GLUE.config.echos or GLUE.config.debug then
                    local label = (limb == "torso") and "serioustrauma→mildtrauma" or (limb .. " mangled→damaged")
                    cecho(string.format("\n<cyan>[GLUE]<reset> Resto: %s's %s", name, label))
                end
            else
                GLUE.limbs.damage[name][limb] = 0
                if GLUE.config.echos or GLUE.config.debug then
                    local label = (limb == "torso") and "mildtrauma→cured" or (limb .. " damaged→cured")
                    cecho(string.format("\n<cyan>[GLUE]<reset> Resto: %s's %s", name, label))
                end
            end

            -- Only cure one limb per restoration
            return
        end
    end
end

--[[
    Reset all limbs for a target
]]--
function GLUE.limbs.ResetAll(name)
    name = name:lower():title()

    -- Kill all in-flight restoration timers — limb damage is being fully cleared.
    if GLUE.killRestoreTimers then GLUE.killRestoreTimers() end

    GLUE.limbs.damage[name] = {}

    -- Clear all limb afflictions for this target from all states
    -- for _, limb in ipairs(GLUE.limbs.names) do
    --     local limbSuffix = limb:gsub(" ", "")
    --     GLUE.state.RemoveAffliction("damaged" .. limbSuffix)
    --     GLUE.state.RemoveAffliction("broken" .. limbSuffix)
    --     GLUE.state.RemoveAffliction("mangled" .. limbSuffix)
    -- end

    -- Clear all timers for this target
    if GLUE.limbs.timers[name] then
        for _, timerData in pairs(GLUE.limbs.timers[name]) do
            if timerData and timerData.id then
                killTimer(timerData.id)
            end
        end
        GLUE.limbs.timers[name] = {}
    end

    if GLUE.config.debug then
        cecho(string.format("\n<green>[GLUE]<reset> Reset all limbs for %s", name))
    end
end

--[[
    Query functions
]]--

function GLUE.limbs.GetDamage(name, limb)
    name = name:lower():title()
    return (GLUE.limbs.damage[name] and GLUE.limbs.damage[name][limb]) or 0
end

function GLUE.limbs.IsBroken(name, limb)
    return GLUE.limbs.GetDamage(name, limb) > 100
end

--[[
    Get timer data for a target (for saving when switching targets)
    @param name (string) - Target name
    @return (table) - {limb = {startTime = timestamp}}
]]--
function GLUE.limbs.GetTimerData(name)
    name = name:lower():title()
    local timerData = {}

    if GLUE.limbs.timers[name] then
        for limb, data in pairs(GLUE.limbs.timers[name]) do
            if data and data.startTime then
                timerData[limb] = {
                    startTime = data.startTime
                }
            end
        end
    end

    return timerData
end

--[[
    Restore timers for a target (when switching back within 3 minutes)
    @param name (string) - Target name
    @param timerData (table) - Timer data from GetTimerData
]]--
function GLUE.limbs.RestoreTimers(name, timerData)
    name = name:lower():title()
    if not timerData then return end

    GLUE.limbs.timers[name] = GLUE.limbs.timers[name] or {}

    local currentTime = os.time()

    for limb, data in pairs(timerData) do
        local elapsed = currentTime - data.startTime
        local remaining = 180 - elapsed

        if remaining > 0 then
            local timerID = tempTimer(remaining, function()
                GLUE.limbs.ResetLimb(name, limb)
                GLUE.limbs.timers[name][limb] = nil
            end)

            GLUE.limbs.timers[name][limb] = {
                id = timerID,
                startTime = data.startTime
            }

            if GLUE.config.debug then
                cecho(string.format("\n<cyan>[GLUE]<reset> Restored %s timer for %s (%ds remaining)",
                    limb, name, remaining))
            end
        end
    end
end

--[[
    Cancel all timers for a target (called when switching away)
    @param name (string) - Target name
]]--
function GLUE.limbs.CancelTimers(name)
    name = name:lower():title()

    if GLUE.limbs.timers[name] then
        for _, timerData in pairs(GLUE.limbs.timers[name]) do
            if timerData and timerData.id then
                killTimer(timerData.id)
            end
        end
    end
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Limb Tracking")
end
