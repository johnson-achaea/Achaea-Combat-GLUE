--[[
    GLUE.util.searchRooms
    Walks a list of room IDs in nearest-neighbour order, checking GMCP on
    arrival until a condition is met.

    Usage:
        GLUE.util.searchRooms(roomIDs, checkFn, onFound, onExhausted)

        roomIDs        — array of numeric room IDs to visit
        checkFn(gmcp) → bool  — return true when the target is found
        onFound(roomID)        — called with the room we stopped at
        onExhausted()          — called if every room was checked without success

    GLUE.util.getRoomIDsByName
    Returns an array of numeric room IDs whose name matches roomName,
    optionally restricted to a specific area.

    Usage:
        GLUE.util.getRoomIDsByName(roomName, areaID)

        roomName  — room name to search (passed to mmp.searchRoom)
        areaID    — (optional) restrict to rooms in this area
]]--

GLUE = GLUE or {}
GLUE.util = GLUE.util or {}

function GLUE.util.getRoomIDsByName(roomName, areaID)
    local results = mmp.searchRoom(roomName)
    local ids = {}
    for id in pairs(results or {}) do
        local numID = tonumber(id)
        local roomArea = getRoomArea(numID)
        if not areaID or (roomArea and roomArea == areaID) then
            ids[#ids + 1] = numID
        end
    end
    return ids
end

function GLUE.util.searchRooms(roomIDs, checkFn, onFound, onExhausted)
    if not roomIDs or #roomIDs == 0 then
        if onExhausted then onExhausted() end
        return
    end

    local unvisited = {}
    for _, id in ipairs(roomIDs) do
        unvisited[id] = true
    end

    -- Greedy nearest-neighbour: at each step pick the closest unvisited room
    -- by path length from the last chosen room.
    local ordered = {}
    local from = mmp.currentroom
    while next(unvisited) do
        local best, bestLen = nil, math.huge
        for id in pairs(unvisited) do
            if getPath(from, id) then
                local len = #speedWalkDir
                if len < bestLen then
                    bestLen = len
                    best    = id
                end
            end
        end
        if not best then break end
        ordered[#ordered + 1] = best
        unvisited[best] = nil
        from = best
    end

    if #ordered == 0 then
        if onExhausted then onExhausted() end
        return
    end

    local index     = 1
    local handlerID = nil

    local function visitNext()
        if index > #ordered then
            killAnonymousEventHandler(handlerID)
            if onExhausted then onExhausted() end
            return
        end
        mmp.gotoRoom(ordered[index])
        index = index + 1
    end

    handlerID = registerAnonymousEventHandler("mmapper arrived", function()
        -- Brief delay so GMCP room data has time to update.
        tempTimer(0.3, function()
            if checkFn(gmcp) then
                killAnonymousEventHandler(handlerID)
                if onFound then onFound(mmp.currentroom) end
            else
                visitNext()
            end
        end)
    end)

    -- If we are already standing in the first target room, check immediately.
    if ordered[1] == mmp.currentroom then
        tempTimer(0, function()
            if checkFn(gmcp) then
                killAnonymousEventHandler(handlerID)
                if onFound then onFound(mmp.currentroom) end
            else
                index = 2
                visitNext()
            end
        end)
    else
        visitNext()
    end
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: RoomSearch")
end
