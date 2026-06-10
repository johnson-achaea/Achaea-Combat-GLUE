GLUE = GLUE or {}
GLUE.chase = GLUE.chase or {
    direction      = nil,   -- current chase direction
    fromRoom       = nil,   -- room ID we initiated the chase from
    toRoom         = nil,   -- room ID we're trying to chase into
    flying         = true,  -- whether target could be flying (reset each room)
    disabled       = true,  -- set false to enable chasing
    _handlerID        = nil,
    _playersHandlerID = nil,
    _squintDone       = false, -- whether we've already squinted this locate cycle
    _squintDir    = nil,   -- direction we squinted
    _squintTempID  = nil,  -- tempTrigger ID watching for target name in squint output
    _squintLines   = {},   -- lines collected during squint window for room-count
}

local C = GLUE.chase

local oppositeDir = {
    north = "south", south = "north",
    east  = "west",  west  = "east",
    northeast = "southwest", southwest = "northeast",
    northwest = "southeast", southeast = "northwest",
    up = "down", down = "up",
    ["in"] = "out", out = "in",
}

-- Build exits sorted by destination connectivity (most connected = most likely fled direction).
local function sortedExitDirs()
    local exits = getRoomExits(gmcp.Room.Info.num) or {}
    local dirs  = {}
    for dir, destID in pairs(exits) do
        local count = 0
        for _ in pairs(getRoomExits(destID) or {}) do count = count + 1 end
        dirs[#dirs + 1] = { dir = dir, count = count }
    end
    table.sort(dirs, function(a, b) return a.count > b.count end)
    local result = {}
    for _, d in ipairs(dirs) do result[#result + 1] = d.dir end
    return result
end


local function killSquintTrigger()
    if C._squintTempID then
        killTrigger(C._squintTempID)
        C._squintTempID = nil
    end
end

local function resetLocate()
    killSquintTrigger()
    C._squintDone = false
    C._squintDir  = nil
end

function GLUE.chase.BeginSquint(dir)
    if C.disabled or not (GLUE.target and GLUE.target.name) then return end
    C._squintDone  = true
    C._squintDir   = dir
    C._squintLines = {}
    enableTrigger("Squint Line Collector")
end


-- Progressively narrow target location: squint best exit → class locate.
-- SquintEnd() and observe triggers call back into this to advance the sequence.
function GLUE.chase.Locate()
    if C.disabled then return end
    -- Step 1: squint the most-connected exit once
    if not C._squintDone then
        local dirs = sortedExitDirs()
        if #dirs > 0 then
            send("squint " .. dirs[1])
            return
        end
    end

    -- Step 2: class-specific locate
    resetLocate()
    GLUE.chase.DoLocate(GLUE.target.name)
end

-- Called by the Squint_End trigger ("You can see no further.").
function GLUE.chase.SquintEnd()
    disableTrigger("Squint Line Collector")
    if C.disabled or not C._squintDir then return end

    local dir   = C._squintDir
    local lines = C._squintLines
    resetLocate()

    -- Scan collected lines for the target name
    local targetLine
    if GLUE.target and GLUE.target.name then
        for i, l in ipairs(lines) do
            if l:find(GLUE.target.name, 1, true) then
                targetLine = i
                break
            end
        end
    end

    if targetLine then
        local rooms  = math.ceil(targetLine / 2)
        local roomID = tonumber(gmcp.Room.Info.num)
        for _ = 1, rooms do
            local exits = getRoomExits(roomID) or {}
            if not exits[dir] then break end
            roomID = exits[dir]
        end
        -- Dash immediately rather than waiting for mapper path calculation
        C.toRoom = roomID
        GLUE.chase.FoundInDirection(dir)
        -- send("dash " .. dir .. " " .. rooms)
    else
        GLUE.chase.DoLocate(GLUE.target.name)
    end
end

-- Called by a squint/observe trigger when the target is spotted in a direction.
function GLUE.chase.FoundInDirection(direction)
    if C.disabled then return end
    resetLocate()
    GLUE.chase.SetDirection(GLUE.target.name, direction)
end


-- Set or clear the active chase direction.
function GLUE.chase.SetDirection(name, direction)
    if C.disabled then return end
    if name ~= GLUE.target.name then return end
    if direction == "here" then
        C.direction = nil
        C.fromRoom  = nil
        C.toRoom    = nil
    else
        C.direction = direction
        C.fromRoom  = tonumber(gmcp.Room.Info.num)
        C.toRoom    = nil  -- toRoom is only set by DoLocate navigation, not chase direction
    end
    resetLocate()
    if GLUE.OnChaseUpdated then GLUE.OnChaseUpdated() end
end

-- Called by a farsee/locate trigger once a destination room ID is known.
function GLUE.chase.SetDestination(roomID)
    if C.disabled then return end
    C.toRoom = tonumber(roomID)
    mmp.gotoRoom(C.toRoom)
end

-- Returns the movement prefix to prepend to an attack command, or nil if not chasing.
function GLUE.chase.GetPrefix()
    if C.disabled or not C.direction then return nil end
    local move = GLUE.integration.IsDirBlocked(C.direction) and ("leap " .. C.direction) or C.direction
    return move .. "/squint " .. C.direction
end

local function onRoomInfo()
    if C.disabled then return end
    C.flying = true
    local roomNum = tonumber(gmcp.Room.Info.num)

    -- Target found here — stop all chasing
    if GLUE.integration.IsTargetInRoom(GLUE.target.name) then
        C.direction = nil
        C.fromRoom  = nil
        C.toRoom    = nil
        resetLocate()
        if GLUE.OnChaseUpdated then GLUE.OnChaseUpdated() end
        return
    end

    -- Navigating to a DoLocate destination — wait until we arrive
    if C.toRoom then
        if C.fromRoom and C.fromRoom ~= roomNum then
            C.direction = nil
            C.fromRoom  = nil
        end
        if C.toRoom == roomNum then
            C.toRoom = nil
            tempTimer(0, function()
                if GLUE.integration.IsTargetInRoom(GLUE.target.name) then
                    C.direction = nil
                    C.fromRoom  = nil
                    resetLocate()
                    if GLUE.OnChaseUpdated then GLUE.OnChaseUpdated() end
                else
                    GLUE.chase.DoFlyingCheck(GLUE.target.name)
                end
            end)
        end
        return
    end

    -- Followed chase direction into this room — squint already in-flight from prefix
    if C.direction and (not GLUE.integration.IsTargetInRoom(GLUE.target.name)) then
        local exits = getRoomExits(roomNum) or {}
        local dir = C.direction
        C.direction = nil
        C.fromRoom  = nil
        if not exits[dir] then
            -- Exit gone — squint a random adjacent exit (not the way we came)
            local from = oppositeDir[dir]
            local candidates = {}
            for d in pairs(exits) do
                if d ~= from then candidates[#candidates + 1] = d end
            end
            if #candidates > 0 then
                send("squint " .. candidates[math.random(#candidates)])
            else
                GLUE.chase.DoLocate(GLUE.target.name)
            end
        end
        -- Exit exists: squint was sent with the move, Squint End will handle navigation
    end
end

local function onRoomPlayers()
    if C.disabled then return end
    if not (GLUE.target and GLUE.target.name) then return end
    if not GLUE.integration.IsTargetInRoom(GLUE.target.name) then return end
    C.direction = nil
    C.fromRoom  = nil
    C.toRoom    = nil
    resetLocate()
    if GLUE.OnChaseUpdated then GLUE.OnChaseUpdated() end
end

if C._handlerID then killAnonymousEventHandler(C._handlerID) end
C._handlerID = registerAnonymousEventHandler("gmcp.Room.Info", onRoomInfo)

if C._playersHandlerID then killAnonymousEventHandler(C._playersHandlerID) end
C._playersHandlerID = registerAnonymousEventHandler("gmcp.Room.Players", onRoomPlayers)

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Chase")
end
