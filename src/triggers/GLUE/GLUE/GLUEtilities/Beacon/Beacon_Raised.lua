local raiser      = matches[2]
local roomName    = matches[3]
local currentArea = getRoomArea(mmp.currentroom)

local ids = GLUE.util.getRoomIDsByName(roomName, currentArea)

if #ids == 0 then
    cecho(string.format("\n<yellow>[Beacon]<reset> %s raised a beacon at <white>%s<reset> (room not found in current area)", raiser, roomName))
    return
end

if #ids == 1 then
    cechoLink(
        string.format("\n<yellow>[Beacon]<reset> %s raised a beacon at <white>%s<reset> [<cyan>goto<reset>]", raiser, roomName),
        string.format("mmp.gotoRoom(%d)", ids[1]),
        string.format("Go to %s", roomName),
        true
    )
else
    GLUE.util._beaconSearch = function()
        GLUE.util.searchRooms(ids,
            function(g)
                local items = g and g.Char and g.Char.Items and g.Char.Items.List and g.Char.Items.List.items
                if not items then return false end
                for _, item in ipairs(items) do
                    if item.name and item.name:lower():find("beacon") then return true end
                end
                return false
            end,
            function(roomID)
                cecho(string.format("\n<yellow>[Beacon]<reset> Found beacon at #%d", roomID))
            end,
            function()
                cecho("\n<yellow>[Beacon]<reset> Beacon not found.")
            end
        )
    end

    cechoLink(
        string.format("\n<yellow>[Beacon]<reset> %s raised a beacon at <white>%s<reset> [<cyan>search<reset>]", raiser, roomName),
        "GLUE.util._beaconSearch()",
        string.format("Search for beacon in %s", roomName),
        true
    )
end
