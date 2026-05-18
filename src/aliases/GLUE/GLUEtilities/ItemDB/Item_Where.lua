local key     = matches[2]:lower()
local results = GLUE.util.itemDB.find(key)

if #results == 0 then
    cecho(string.format("\n<yellow>[ItemDB]<reset> No known rooms for <white>%s<reset>.", matches[2]))
    return
end

for _, r in ipairs(results) do
    r.areaName = mmp.getAreaName(r.roomID) or tostring(r.areaID)
    r.dist     = getPath(mmp.currentroom, r.roomID) and #speedWalkDir or math.huge
end

local areas = {}
local areaOrder = {}
for _, r in ipairs(results) do
    if not areas[r.areaName] then
        areas[r.areaName] = { minWholeDist = math.huge, minDist = math.huge, hasWhole = false, rooms = {} }
        areaOrder[#areaOrder + 1] = r.areaName
    end
    local a = areas[r.areaName]
    a.rooms[#a.rooms + 1] = r
    if r.dist < a.minDist then a.minDist = r.dist end
    if r.wholeWord then
        a.hasWhole = true
        if r.dist < a.minWholeDist then a.minWholeDist = r.dist end
    end
end

table.sort(areaOrder, function(a, b)
    local wa, wb = areas[a].hasWhole, areas[b].hasWhole
    if wa ~= wb then return wa end
    local da = wa and areas[a].minWholeDist or areas[a].minDist
    local db = wb and areas[b].minWholeDist or areas[b].minDist
    return da < db
end)

cecho(string.format("\n<yellow>[ItemDB]<reset> Known locations for <white>%s<reset> (%d room(s)):", matches[2], #results))
for _, areaName in ipairs(areaOrder) do
    local group = areas[areaName]
    table.sort(group.rooms, function(a, b)
        if a.wholeWord ~= b.wholeWord then return a.wholeWord end
        return a.dist < b.dist
    end)
    cecho(string.format("\n<cyan>%s<reset>", areaName))
    for _, r in ipairs(group.rooms) do
        local roomName = getRoomName(r.roomID) or tostring(r.roomID)
        local distStr  = r.dist == math.huge and "?" or tostring(r.dist)
        cecho(string.format("\n  <white>%s<reset> in %s — %s steps  ", r.name, roomName, distStr))
        cechoLink("<cyan>[go]<reset>", string.format("mmp.gotoRoom(%d)", r.roomID), "Go to room " .. r.roomID, true)
    end
end
