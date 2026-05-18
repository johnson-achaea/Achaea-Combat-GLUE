GLUE = GLUE or {}
GLUE.util = GLUE.util or {}

GLUE.util.exploration = GLUE.util.exploration or {
    enabled       = false,
    autoExplore   = false,
    explored      = {},   -- list of area names marked complete
    exploring     = false,
    roomsToExplore = {},
    areaProgress  = {},   -- area name → remaining room list (persists across area switches)
    targetRoom    = nil,  -- room we're currently navigating to (auto-explore only)
    _handlerID    = nil,
}

local ET = GLUE.util.exploration
ET.areaProgress = ET.areaProgress or {}

local function savePath()
    return getMudletHomeDir() .. "/glue_exploration"
end

local function echo(text)
    cecho("\n<yellow>[Exploration]<reset> " .. text)
end

function GLUE.util.exploration.saveStuff()
    table.save(savePath(), ET.explored)
end

function GLUE.util.exploration.loadStuff()
    if not io.exists(savePath()) then
        echo("No saved exploration data found.")
        ET.explored = {}
    else
        ET.explored = {}
        table.load(savePath(), ET.explored)
        echo("Loaded exploration data.")
    end
end

function GLUE.util.exploration.unexploredAreas()
    local fullAreas   = getAreaTable()
    local trimmedAreas = {}
    for name in pairs(fullAreas) do
        local lower = name:lower()
        if not lower:find("unnamed") and not lower:find("subdivision")
        and not table.contains(ET.explored, mmp.cleanAreaName(name)) then
            table.insert(trimmedAreas, mmp.cleanAreaName(name))
        end
    end
    return trimmedAreas
end

function GLUE.util.exploration.findNextArea()
    local toExplore = ET.unexploredAreas()
    if #toExplore == 0 then
        echo("All areas explored!")
        return
    end
    local nextArea = toExplore[math.random(1, #toExplore)]
    echo(string.format("There are <white>%d<reset> areas left to explore.", #toExplore))
    echo(string.format("Suggested next: <white>%s<reset>", nextArea))
end

function GLUE.util.exploration.exploredArea()
    if not table.contains(ET.explored, ET.exploring) then
        table.insert(ET.explored, ET.exploring)
        echo(string.format("Completed exploration of <white>%s<reset>!", ET.exploring))
        ET.areaProgress[ET.exploring] = nil
        ET.exploring      = false
        ET.roomsToExplore = {}
        ET.saveStuff()
    end
end

function GLUE.util.exploration.nextRoom()
    if not ET.enabled then return end
    local hasRooms = false
    for _ in pairs(ET.roomsToExplore or {}) do hasRooms = true; break end
    if not hasRooms then
        echo("No rooms queued — try picking a new area.")
        return
    end
    local cx, cy, cz = getRoomCoordinates(mmp.currentroom)
    local bestID, bestDist = nil, math.huge
    for roomID in pairs(ET.roomsToExplore) do
        if roomID ~= mmp.currentroom then
            if cx then
                local x, y, z = getRoomCoordinates(roomID)
                if x then
                    local d = (x - cx)^2 + (y - cy)^2 + ((z or 0) - (cz or 0))^2
                    if d < bestDist then bestDist = d; bestID = roomID end
                end
            else
                bestID = roomID; break
            end
        end
    end
    if bestID then
        ET.targetRoom = bestID
        mmp.gotoRoom(bestID)
    else
        echo("No unvisited rooms with coordinates found.")
    end
end

function GLUE.util.exploration.listAreas()
    local toExplore = ET.unexploredAreas()
    echo(string.format("Unexplored areas (<white>%d<reset>):\n", #toExplore))
    table.sort(toExplore)
    for _, area in ipairs(toExplore) do
        echo(" ")
        local r, g, b = unpack(color_table["green"])
        setTextFormat("", 0, 0, 0, r, g, b, false, true, false)
        echoLink("[+]", string.format([[ GLUE.util.exploration.areaCheck(%q) ]], area), "Mark " .. area .. " as explored", true)
        resetFormat()
        cecho("<DodgerBlue> - " .. area)
    end
    cecho("\n\n<green>Click [+] to manually mark an area as explored.\n")
end

function GLUE.util.exploration.showExplored()
    echo(string.format("Explored areas (<white>%d<reset>):\n", #ET.explored))
    local sorted = mmp.deepcopy(ET.explored)
    table.sort(sorted)
    for _, area in ipairs(sorted) do
        echo(" ")
        local r, g, b = unpack(color_table["red"])
        setTextFormat("", 0, 0, 0, r, g, b, false, true, false)
        echoLink("[-]", string.format([[ GLUE.util.exploration.areaUncheck(%q) ]], area), "Unmark " .. area, true)
        resetFormat()
        cecho("<DodgerBlue> - " .. area)
    end
    cecho("\n\n<green>Click [-] to remove an area from your explored list.\n")
end

function GLUE.util.exploration.areaCheck(area)
    if not table.contains(ET.explored, area) then
        table.insert(ET.explored, area)
        echo(string.format("Marked <white>%s<reset> as explored.", area))
        ET.saveStuff()
    end
end

function GLUE.util.exploration.areaUncheck(area)
    local idx = table.index_of(ET.explored, area)
    if idx then
        table.remove(ET.explored, idx)
        echo(string.format("Removed <white>%s<reset> from explored list.", area))
        ET.saveStuff()
    else
        echo(string.format("<white>%s<reset> is not in your explored list.", area))
    end
end

function GLUE.util.exploration.enteredRoom()
    if not ET.enabled then return end

    local areaList = ET.unexploredAreas()
    local area     = mmp.cleanAreaName(mmp.getAreaName(gmcp.Room.Info.num))

    if not table.contains(areaList, area) then return end

    if ET.exploring ~= area then
        ET.exploring = area
        if not ET.areaProgress[area] then
            local roomSet = {}
            for _, roomID in pairs(getAreaRooms(getRoomArea(mmp.currentroom))) do
                if type(roomID) == "number" then roomSet[roomID] = true end
            end
            ET.areaProgress[area] = roomSet
            echo(string.format("Beginning exploration of <white>%s<reset>!", area))
        else
            local count = 0
            for _ in pairs(ET.areaProgress[area]) do count = count + 1 end
            echo(string.format("Resuming exploration of <white>%s<reset> (%d rooms remaining).", area, count))
        end
        ET.roomsToExplore = ET.areaProgress[area]
    end

    ET.roomsToExplore[tonumber(gmcp.Room.Info.num)] = nil

    local remaining = 0
    for _ in pairs(ET.roomsToExplore) do remaining = remaining + 1 end

    if remaining > 0 then
        echo(string.format("Rooms remaining in <white>%s<reset>: <white>%d<reset>", area, remaining))
        local arrivedAtTarget = ET.targetRoom == nil or tonumber(gmcp.Room.Info.num) == ET.targetRoom
        if ET.autoExplore and arrivedAtTarget then GLUE.util.exploration.nextRoom() end
    else
        ET.exploredArea()
    end
end

function GLUE.util.exploration.toggleAuto()
    ET.autoExplore = not ET.autoExplore
    if ET.autoExplore then
        echo("Auto-explore <green>on<reset>. Moving to next room automatically.")
        GLUE.util.exploration.nextRoom()
    else
        echo("Auto-explore <red>off<reset>.")
    end
end

function GLUE.util.exploration.enable()
    if ET.enabled then return end
    ET.enabled = true
    if ET._handlerID then killAnonymousEventHandler(ET._handlerID) end
    ET._handlerID = registerAnonymousEventHandler("gmcp.Room.Info", function()
        GLUE.util.exploration.enteredRoom()
    end)
    ET.loadStuff()
    send("ql", false)
    echo("Exploration tracking <green>enabled<reset>.")
end

function GLUE.util.exploration.disable()
    if not ET.enabled then return end
    ET.enabled = false
    if ET._handlerID then
        killAnonymousEventHandler(ET._handlerID)
        ET._handlerID = nil
    end
    echo("Exploration tracking <red>disabled<reset>.")
end

function GLUE.util.exploration.toggle()
    if ET.enabled then
        ET.disable()
    else
        ET.enable()
    end
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Exploration")
end
