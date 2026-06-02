GLUE = GLUE or {}
GLUE.bard = GLUE.bard or {}

-- Current circling position relative to target: "front", "side", or "back"
GLUE.bard.position  = GLUE.bard.position  or "front"

-- Tempo cannot be observed in third-person; defaults to "none" (most conservative counts)
GLUE.bard.tempo     = GLUE.bard.tempo     or "none"

-- Grand crescendo level (0-5). 5 = finale available.
GLUE.bard.crescendo = GLUE.bard.crescendo or 0
GLUE.bard.canFinale = GLUE.bard.canFinale or false

-- Hits required per position at each tempo (mirrors AK Bard_position_tracker)
GLUE.bard.tempoTrack = {
    adagio   = { front = 4, side = 4, back = 3 },
    moderato = { front = 3, side = 2, back = 2 },
    allegro  = { front = 2, side = 1, back = 1 },
    none     = { front = 5, side = 2, back = 1 },
}

-- Hits remaining before the Bard advances to the next position
GLUE.bard.tempoHits = GLUE.bard.tempoHits
    or GLUE.bard.tempoTrack[GLUE.bard.tempo][GLUE.bard.position]

local positionCycle = { front = "side", side = "back", back = "front" }

-- Call after each observed blade hit on our target.
-- Decrements tempoHits, auto-advances position when exhausted, increments crescendo.
function GLUE.bard.OnHit()
    if GLUE.bard.tempoHits > 0 then
        GLUE.bard.tempoHits = GLUE.bard.tempoHits - 1
    end
    if GLUE.bard.tempoHits <= 0 then
        GLUE.bard.position  = positionCycle[GLUE.bard.position] or "front"
        GLUE.bard.tempoHits = GLUE.bard.tempoTrack[GLUE.bard.tempo][GLUE.bard.position]
    end
    if GLUE.bard.crescendo < 5 then
        GLUE.bard.crescendo = GLUE.bard.crescendo + 1
        if GLUE.bard.crescendo >= 5 then
            GLUE.bard.canFinale = true
        end
    end
end

-- Override position tracking (e.g. if position-change messages become visible)
function GLUE.bard.SetPosition(pos)
    GLUE.bard.position  = pos
    GLUE.bard.tempoHits = GLUE.bard.tempoTrack[GLUE.bard.tempo][pos]
end

-- Reset when target is cleared or circling is lost
function GLUE.bard.Reset()
    GLUE.bard.position  = "front"
    GLUE.bard.tempoHits = GLUE.bard.tempoTrack[GLUE.bard.tempo]["front"]
    GLUE.bard.crescendo = 0
    GLUE.bard.canFinale = false
end

-- Affliction → refrain name lookup (for offense scripts)
GLUE.bard.refrain = {
    paralysis   = "paean",
    dizziness   = "bhajan",
    addiction   = "gusheh",
    asthma      = "ode",
    slickness   = "ghazal",
    lethargy    = "elegy",
    sensitivity = "prosodion",
}

-- Returns a cecho-formatted string showing current position progress across all three phases.
-- Adapted from AK Bard_position_tracker positionDisplay().
function GLUE.bard.PositionDisplay()
    local track   = GLUE.bard.tempoTrack[GLUE.bard.tempo]
    local pos     = GLUE.bard.position
    local elapsed = track[pos] - GLUE.bard.tempoHits
    local ret     = "<b><ansi_red>"

    for i = 0, track.front - 1 do
        if pos == "front" and elapsed == i then
            ret = ret .. "[<white>X<ansi_red>]"
        else
            ret = ret .. "[ ]"
        end
    end

    ret = ret .. "<yellow>"
    for i = 0, track.side - 1 do
        if pos == "side" and elapsed == i then
            ret = ret .. "[<white>X<yellow>]"
        else
            ret = ret .. "[ ]"
        end
    end

    ret = ret .. "<green>"
    for i = 0, track.back - 1 do
        if pos == "back" and elapsed == i then
            ret = ret .. "[<white>X<green>]"
        else
            ret = ret .. "[ ]"
        end
    end

    return ret
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Bard state")
end
