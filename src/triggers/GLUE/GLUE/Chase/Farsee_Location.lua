if not GLUE.IsTarget or not GLUE.IsTarget(matches[2]) then return end

if callSense and pt then
  pt(matches[2] .. " is at " .. matches[3])
end

local roomName   = matches[3]
local results    = mmp.searchRoomExact(roomName)
local currentArea = getRoomArea(tonumber(gmcp.Room.Info.num))

local roomID
for id in pairs(results) do
    if getRoomArea(id) == currentArea then
        roomID = id
        break
    end
end

if not roomID then return end
GotoID = tonumber(roomID)

if not GLUE or not GLUE.chase or GLUE.chase.disabled then return end
GLUE.chase.SetDestination(roomID)
