GLUE = GLUE or {}
GLUE.util = GLUE.util or {}

GLUE.util.itemDB = GLUE.util.itemDB or {
    enabled          = false,
    data             = {},   -- item_name_lower → { [roomID] = areaID }
    _handlerID       = nil,
    _itemsHandlerID  = nil,
    excludePatterns  = {
        "^the corpse of ",
        "^a.* servitor",
        "a runic totem",
        "a runic knight",
        "a reticulated giraffe",
    },
}

local DB = GLUE.util.itemDB

local _staged = nil  -- items snapshot waiting for the next Room.Info to supply the room ID

local function dbPath()
    return getMudletHomeDir() .. "/glue_item_db.lua"
end

-- Char.Items.List fires before Room.Info in Achaea, so stage items here.
local function onItemsList()
    _staged = gmcp and gmcp.Char and gmcp.Char.Items
              and gmcp.Char.Items.List and gmcp.Char.Items.List.items
end

-- Room.Info fires after items; commit the staged snapshot to the now-known room ID.
local function onRoomInfo()
    local roomID = gmcp and gmcp.Room and gmcp.Room.Info and gmcp.Room.Info.num
    local items  = _staged
    _staged      = nil
    if not roomID or not items then return end
    local areaID = getRoomArea(roomID)
    if not areaID then return end
    local itemCount = 0
    for _, item in ipairs(items) do
        local name = item.name and item.name:lower()
        if name then
            if not DB.data[name] then DB.data[name] = {} end
            DB.data[name][roomID] = areaID
            itemCount = itemCount + 1
        end
    end
    if itemCount > 0 then
        cecho("\n<green>[ItemDB]<reset> Recorded " .. itemCount .. " items.")
    end
end

function GLUE.util.itemDB.enable()
    if DB.enabled then return end
    DB.enabled         = true
    DB._handlerID      = registerAnonymousEventHandler("gmcp.Room.Info", onRoomInfo)
    DB._itemsHandlerID = registerAnonymousEventHandler("gmcp.Char.Items.List", onItemsList)
    cecho("\n<yellow>[ItemDB]<reset> Tracking <green>enabled<reset>.")
end

function GLUE.util.itemDB.disable()
    if not DB.enabled then return end
    DB.enabled = false
    if DB._handlerID then
        killAnonymousEventHandler(DB._handlerID)
        DB._handlerID = nil
    end
    if DB._itemsHandlerID then
        killAnonymousEventHandler(DB._itemsHandlerID)
        DB._itemsHandlerID = nil
    end
    cecho("\n<yellow>[ItemDB]<reset> Tracking <red>disabled<reset>.")
end

function GLUE.util.itemDB.toggle()
    if DB.enabled then
        GLUE.util.itemDB.disable()
    else
        GLUE.util.itemDB.enable()
    end
end

-- Removes excluded-pattern names and any room ID that fails map validation:
--   roomID < 0  → area-sentinel left by the first bad import format
--   getRoomArea(roomID) ~= areaID  → sub-table index stored as roomID by the second bad format
function GLUE.util.itemDB.purge(tbl)
    local target  = tbl or DB.data
    local removed = 0
    for name, rooms in pairs(target) do
        local excluded = false
        for _, pattern in ipairs(DB.excludePatterns) do
            if name:find(pattern) then excluded = true; break end
        end
        if excluded then
            target[name] = nil
            removed = removed + 1
        else
            for roomID, areaID in pairs(rooms) do
                if roomID < 0 or getRoomArea(roomID) ~= areaID then
                    rooms[roomID] = nil
                    removed = removed + 1
                end
            end
            if not next(rooms) then target[name] = nil end
        end
    end
    return removed
end

function GLUE.util.itemDB.validate(tbl)
    local removed = GLUE.util.itemDB.purge(tbl)
    cecho(string.format("\n<yellow>[ItemDB]<reset> Validated: removed %d invalid room entries.", removed))
    return removed
end

function GLUE.util.itemDB.save()
    local path = dbPath()
    local merged = {}
    local existing = io.open(path, "r")
    if existing then
        existing:close()
        table.load(path, merged)
    end
    for name, rooms in pairs(DB.data) do
        if not merged[name] then merged[name] = {} end
        for roomID, areaID in pairs(rooms) do
            merged[name][roomID] = areaID
        end
    end
    local removed = GLUE.util.itemDB.purge(merged)
    DB.data = merged
    table.save(path, merged)
    local msg = string.format("\n<yellow>[ItemDB]<reset> Saved %d item(s).", table.size(merged))
    if removed > 0 then
        msg = msg .. string.format(" Purged %d excluded.", removed)
    end
    cecho(msg)
end

function GLUE.util.itemDB.load()
    local path = dbPath()
    local f = io.open(path, "r")
    if not f then
        cecho("\n<yellow>[ItemDB]<reset> No saved database found.")
        return
    end
    f:close()
    DB.data = {}
    table.load(path, DB.data)
    cecho(string.format("\n<yellow>[ItemDB]<reset> Loaded %d item(s).", table.size(DB.data)))
end

local function isWholeWord(name, key)
    return (" " .. name .. " "):find("[^%w]" .. key .. "[^%w]") ~= nil
end

-- Returns a list of {roomID, areaID, name}, whole-word matches first.
-- roomID may be negative (-(areaID)) for entries imported from external files,
-- meaning the item is known to exist somewhere in that area but no specific room.
function GLUE.util.itemDB.find(itemName)
    local key = itemName:lower()
    local results = {}
    for name, rooms in pairs(DB.data) do
        if name:find(key, 1, true) then
            local whole = isWholeWord(name, key)
            for roomID, areaID in pairs(rooms) do
                results[#results + 1] = { roomID = roomID, areaID = areaID, name = name, wholeWord = whole }
            end
        end
    end
    table.sort(results, function(a, b)
        if a.wholeWord ~= b.wholeWord then return a.wholeWord end
        return false
    end)
    return results
end

-- Imports items and denizens from externally-generated area databases into DB.data.
-- Entries without a known room are stored with key -(areaID) as a sentinel, meaning
-- "somewhere in this area." Item_Where displays these as area-only with no [go] link.
-- itemPath and denPath are absolute file paths; pass nil to skip either.
function GLUE.util.itemDB.importExternal(itemPath, denPath)
    local areaTable = getAreaTable()  -- { area_name = areaID }

    local function parseFile(path, label)
        local fn, err = loadfile(path)
        if not fn then
            cecho(string.format("\n<red>[ItemDB]<reset> Cannot load %s: %s", label, tostring(err)))
            return nil
        end
        local ok, data = pcall(fn)
        if not ok or type(data) ~= "table" then
            cecho(string.format("\n<red>[ItemDB]<reset> Cannot parse %s.", label))
            return nil
        end
        return data
    end

    local function mergeFile(raw, label)
        if not raw then return 0 end
        -- raw[1] = { db = {startIndex} }  raw[2] = area-name→table-index dir
        local meta    = raw[1]
        local dirIdx  = meta and meta["db"] and meta["db"][1]
        local areaDir = dirIdx and raw[dirIdx]
        if not areaDir then return 0 end

        local count = 0
        for areaName, idxWrap in pairs(areaDir) do
            local idx      = type(idxWrap) == "table" and idxWrap[1]
            local areaRows = idx and raw[idx]
            local areaID   = areaTable[areaName]

            if areaRows and areaID then
                for itemName, subIdxWrap in pairs(areaRows) do
                    -- subIdxWrap = {N} where raw[N] = {[1]=roomID, [2]=roomID, ...}
                    local subIdx   = type(subIdxWrap) == "table" and subIdxWrap[1]
                    local roomList = subIdx and raw[subIdx]
                    if roomList then
                        local lower = itemName:lower()
                        local skip  = false
                        for _, pat in ipairs(DB.excludePatterns) do
                            if lower:find(pat) then skip = true; break end
                        end
                        if not skip then
                            if not DB.data[lower] then DB.data[lower] = {} end
                            for _, roomID in ipairs(roomList) do
                                if not DB.data[lower][roomID] then
                                    DB.data[lower][roomID] = areaID
                                    count = count + 1
                                end
                            end
                        end
                    end
                end
            end
        end

        cecho(string.format("\n<yellow>[ItemDB]<reset> Merged %d new %s entries.", count, label))
        return count
    end

    mergeFile(parseFile(itemPath, "itemdb"), "item")
    mergeFile(parseFile(denPath,  "dendb"),  "denizen")
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: ItemDB")
end
