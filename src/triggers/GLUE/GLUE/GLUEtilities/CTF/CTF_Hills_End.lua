disableTrigger("CTF Hill Line")
disableTrigger("CTF Hills End")

if not GLUE.ctf then return end

local plantedByArea = {}
for _, flag in ipairs(GLUE.ctf.flags or {}) do
    if flag.planted then
        plantedByArea[flag.area:lower()] = flag.id
    end
end

cecho("\n<white>CTF Hills\n")
cecho("<DarkSlateGrey>-----------------------------------------\n")

for i, hillName in ipairs(GLUE.ctf.hills or {}) do
    local results = mmp.searchRoom(hillName)
    if not results or not next(results) then
        cecho(string.format("<red>%d. %s <DarkSlateGrey>(not in mapper)\n", i, hillName))
    else
        local roomID = next(results)
        local areaID   = getRoomArea(roomID)
        local areaName = (mmp.areatabler and mmp.areatabler[areaID]) or "unknown"
        local flag     = plantedByArea[areaName:lower()]

        if flag then
            cecho(string.format("<yellow>* <white>%s <DarkSlateGrey>(%s) <yellow>[%s]", hillName, areaName, flag))
        else
            cecho(string.format("  <white>%s <DarkSlateGrey>(%s)", hillName, areaName))
        end
        cechoLink(" <green>[walk]\n", "mmp.gotoRoom(" .. roomID .. ")", "Go to " .. hillName, true)
    end
end
