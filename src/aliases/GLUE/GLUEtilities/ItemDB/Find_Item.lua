local roomName    = matches[2]
local itemSearch  = matches[3]:lower()
local currentArea = getRoomArea(mmp.currentroom)

local ids = GLUE.util.getRoomIDsByName(roomName, currentArea)
if #ids == 0 then
    cecho(string.format("\n<yellow>[Search]<reset> No rooms named <white>%s<reset> found in current area.", roomName))
    return
end

cecho(string.format("\n<yellow>[Search]<reset> Searching %d room(s) named <white>%s<reset> for <white>%s<reset>...", #ids, roomName, itemSearch))

GLUE.util.searchRooms(ids,
    function(g)
        local items = g and g.Char and g.Char.Items and g.Char.Items.List and g.Char.Items.List.items
        if not items then return false end
        for _, item in ipairs(items) do
            if item.name and item.name:lower():find(itemSearch, 1, true) then
                return true
            end
        end
        return false
    end,
    function(roomID)
        cecho(string.format("\n<yellow>[Search]<reset> Found <white>%s<reset> in room #%d.", matches[3], roomID))
    end,
    function()
        cecho(string.format("\n<yellow>[Search]<reset> <white>%s<reset> not found in any <white>%s<reset> room.", matches[3], roomName))
    end
)
