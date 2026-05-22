GLUE = GLUE or {}
GLUE.psion = GLUE.psion or {}

-- Transcendence level (0-100%)
GLUE.psion.transcend = GLUE.psion.transcend or 0

-- Current prepared weapon modification (nil, "disruption", "laceration", etc.)
GLUE.psion.prepared = GLUE.psion.prepared or nil

-- Targets currently bound with golden lightbinds
GLUE.psion.lightbinds = GLUE.psion.lightbinds or {}

-- Active secondary tick timers per unweaving type (all three tick at 4s intervals)
GLUE.psion.unweaveTick = GLUE.psion.unweaveTick or {}

-- Start the repeating 4-second secondary tick for an unweaving type.
-- Rate-limited: if a timer is already running for this type, do nothing.
-- Increments the affliction stack each tick up to UNWEAVE_MAX_STACKS.
function GLUE.psion.StartUnweaveTick(uwtype)
    local affName = "unweaving" .. uwtype

    if GLUE.psion.unweaveTick[uwtype] then
        if GLUE.state.HasAffliction(affName) then return end
        killTimer(GLUE.psion.unweaveTick[uwtype])
        GLUE.psion.unweaveTick[uwtype] = nil
    end
    local function tick()
        if not GLUE.psion.unweaveTick[uwtype] then return end
        if not GLUE.state.HasAffliction(affName) then
            GLUE.psion.StopUnweaveTick(uwtype)
            return
        end
        for _, state in ipairs(GLUE.state.states) do
            if state.affs[affName] and state.affs[affName] < 2 then
                state.affs[affName] = state.affs[affName] + 1
            end
        end
        if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
        GLUE.psion.unweaveTick[uwtype] = tempTimer(4, tick)
    end

    GLUE.psion.unweaveTick[uwtype] = tempTimer(4, tick)
end

-- Stop the secondary tick for one type, or all types if uwtype is nil.
function GLUE.psion.StopUnweaveTick(uwtype)
    if uwtype then
        if GLUE.psion.unweaveTick[uwtype] then
            killTimer(GLUE.psion.unweaveTick[uwtype])
            GLUE.psion.unweaveTick[uwtype] = nil
        end
    else
        for _, id in pairs(GLUE.psion.unweaveTick) do
            killTimer(id)
        end
        GLUE.psion.unweaveTick = {}
    end
end

-- Stop ticks when an unweaving aff is confirmed cured.
GLUE.RegisterOnAfflictionCured("psion", function(affliction)
    if affliction == "unweavingmind" then
        GLUE.psion.StopUnweaveTick("mind")
    elseif affliction == "unweavingbody" then
        GLUE.psion.StopUnweaveTick("body")
    elseif affliction == "unweavingspirit" then
        GLUE.psion.StopUnweaveTick("spirit")
    end
end)

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Psion state")
end
