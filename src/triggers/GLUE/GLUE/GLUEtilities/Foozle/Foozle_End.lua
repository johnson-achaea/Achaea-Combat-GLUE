if not GLUE.util.foozle or not GLUE.util.foozle.active then return end
GLUE.util.foozle.active = false

local items = GLUE.util.foozle.items
if not items or #items == 0 then return end

-- Find best room for each unfound item (whole-word priority, then closest by real path)
local waypoints = {}
for _, item in ipairs(items) do
    if item.found ~= "Yes" then
        local results = GLUE.util.itemDB.find(item.name)
        local best, bestDist = nil, math.huge
        for _, r in ipairs(results) do
            if r.wholeWord and getPath(mmp.currentroom, r.roomID) then
                local d = #speedWalkDir
                if d < bestDist then bestDist = d; best = r end
            end
        end
        if not best then
            for _, r in ipairs(results) do
                if not r.wholeWord and getPath(mmp.currentroom, r.roomID) then
                    local d = #speedWalkDir
                    if d < bestDist then bestDist = d; best = r end
                end
            end
        end
        table.insert(waypoints, { item = item, best = best })
    end
end

-- Nearest-neighbor TSP ordering using real pathfinding; cache leg distances for display
local ordered   = {}
local remaining = {}
for i, wp in ipairs(waypoints) do
    if wp.best then remaining[i] = wp end
end

local cursor = mmp.currentroom
while true do
    local bestIdx, bestDist = nil, math.huge
    for idx, wp in pairs(remaining) do
        if getPath(cursor, wp.best.roomID) then
            local d = #speedWalkDir
            if d < bestDist then bestDist = d; bestIdx = idx end
        end
    end
    if not bestIdx then break end
    remaining[bestIdx].legDist = bestDist
    table.insert(ordered, remaining[bestIdx])
    cursor = remaining[bestIdx].best.roomID
    remaining[bestIdx] = nil
end

-- Display
cecho("\n<yellow>[Foozle]<reset> Suggested route:")

for _, item in ipairs(items) do
    if item.found == "Yes" then
        cecho(string.format("\n  <green>[done]<reset> %d. <green>%s<reset> (%d pts)", item.num, item.name, item.points))
    end
end

local totalSteps = 0
for _, wp in ipairs(ordered) do
    local item     = wp.item
    local r        = wp.best
    local roomName = getRoomName(r.roomID) or tostring(r.roomID)
    local areaName = mmp.getAreaName(r.roomID) or ""
    local stepsStr = wp.legDist and tostring(wp.legDist) or "?"
    if wp.legDist then totalSteps = totalSteps + wp.legDist end
    cecho(string.format("\n  %d. <white>%s<reset> (%d pts) — <white>%s<reset> in <cyan>%s<reset>, %s (%s steps)  ",
        item.num, item.name, item.points, r.name, roomName, areaName, stepsStr))
    cechoLink("<cyan>[go]<reset>", string.format("mmp.gotoRoom(%d)", r.roomID), "Go to " .. roomName, true)
end

for _, wp in ipairs(waypoints) do
    if not wp.best then
        local item = wp.item
        cecho(string.format("\n  %d. <white>%s<reset> (%d pts) — <red>not in database<reset>", item.num, item.name, item.points))
    end
end

if #ordered > 0 then
    cecho(string.format("\n<yellow>[Foozle]<reset> Total route: ~%d steps across %d location(s).", totalSteps, #ordered))
end
