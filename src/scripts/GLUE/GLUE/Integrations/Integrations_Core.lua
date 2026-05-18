GLUE = GLUE or {}
GLUE.integration = GLUE.integration or {}

-- Returns true if the named player is present in the current room.
-- Override to use your own room tracking system instead of RA.
function GLUE.integration.IsTargetInRoom(name)
    local players = gmcp.Room and gmcp.Room.Players or {}
    for _, p in ipairs(players) do
        if p.name == name then return true end
    end
    if ra and ra.InRoom then
        for _, n in ipairs(ra.InRoom) do
            if n == name then return true end
        end
    end
    return true
end

-- Called when GLUE wants to register the target as present in the room.
-- Override if your room system needs to be notified.
function GLUE.integration.AddTargetToRoom(name)
    if ra and ra.InRoom then
        table.insert(ra.InRoom, name)
    end
end

-- Returns true if the given exit direction is wall-blocked.
-- Override to use your own wall/obstacle tracking.
function GLUE.integration.IsDirBlocked(dir)
    if not Legacy or not Legacy.Room or not Legacy.Room.Walls then return false end
    local walls = Legacy.Room.Walls
    local full  = Legacy.Room.directionTable and Legacy.Room.directionTable[dir] or dir
    return table.contains(walls.Ice,   dir)  or table.contains(walls.Ice,   full)
        or table.contains(walls.Stone, dir)  or table.contains(walls.Stone, full)
end

-- Returns the full direction name for an abbreviation (e.g. "n" -> "north").
-- Override to use your own direction mapping.
function GLUE.integration.ExpandDirection(dir)
    if Legacy and Legacy.Room and Legacy.Room.directionTable then
        return Legacy.Room.directionTable[dir] or dir
    end
    return dir
end

-- Returns true if your curing system is currently paused/off.
-- Override to integrate with your own curing system.
function GLUE.integration.IsCuringPaused()
    if not Legacy or not Legacy.Settings or not Legacy.Curing then return false end
    if Legacy.Settings.Curing.status ~= nil and Legacy.Settings.Curing.status == true then
        return false
    end
    return true
end

-- Returns true if aeon or retardation is active (suppresses cure calling).
-- Override to read from your own curing system.
function GLUE.integration.IsTimeDistorted()
    if not Legacy or not Legacy.Curing or not Legacy.Curing.Affs then return false end
    return Legacy.Curing.Affs.retardation or Legacy.Curing.Affs.aeon or false
end

-- Returns the display abbreviation for an affliction name.
-- Override to use your own abbreviation table.
function GLUE.integration.GetAfflictionAbbrev(aff)
    if Legacy and Legacy.Curing and Legacy.Curing.abbreviations then
        return Legacy.Curing.abbreviations[aff] or aff
    end
    return aff
end

-- Builds and returns a table of { [affliction] = color_string } for the prompt display.
-- Override to supply your own color map.
function GLUE.integration.BuildColorMap()
    if not (Legacy and Legacy.Curing and Legacy.Curing.cures) then return {} end
    local map = {}
    for c, t in pairs(Legacy.Curing.cures) do
        local col = Legacy.Settings.Curing.colors[c]
                    or Legacy.Settings.Curing.colors[c:lower()]
                    or "cyan"
        for _, a in pairs(t) do
            map[a:lower()] = col
        end
    end
    return map
end
