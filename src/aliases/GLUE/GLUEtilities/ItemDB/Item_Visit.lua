local key         = matches[2]:lower()
local results     = GLUE.util.itemDB.find(key)
local currentArea = getRoomArea(mmp.currentroom)

if #results == 0 then
    cecho(string.format("\n<yellow>[ItemDB]<reset> No known rooms for <white>%s<reset> in database.", matches[2]))
    return
end

local ids = {}
for _, r in ipairs(results) do
    if r.areaID == currentArea then
        ids[#ids + 1] = r.roomID
    end
end

if #ids == 0 then
    cecho(string.format("\n<yellow>[ItemDB]<reset> No known rooms for <white>%s<reset> in current area.", matches[2]))
    return
end

cecho(string.format("\n<yellow>[ItemDB]<reset> Searching %d known room(s) for <white>%s<reset>...", #ids, matches[2]))

GLUE.util.searchRooms(ids,
    function(g)
        local items = g and g.Char and g.Char.Items and g.Char.Items.List and g.Char.Items.List.items
        if not items then return false end
        for _, item in ipairs(items) do
            if item.name and item.name:lower():find(key, 1, true) then
                return true
            end
        end
        return false
    end,
    function(roomID)
        cecho(string.format("\n<yellow>[ItemDB]<reset> Found <white>%s<reset> in room #%d.", matches[2], roomID))
    end,
    function()
        cecho(string.format("\n<yellow>[ItemDB]<reset> <white>%s<reset> not found in any known room in current area.", matches[2]))
    end
)
