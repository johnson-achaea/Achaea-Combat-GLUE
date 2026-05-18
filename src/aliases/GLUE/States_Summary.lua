if not GLUE or not GLUE.state then return end
local states = GLUE.state.states
local total = #states
cecho(string.format("\n<cyan>[GLUE]<reset> States: <white>%d<reset>", total))
for i, state in ipairs(states) do
    if i > 10 then
        cecho(string.format("\n  <dark_grey>... and %d more<reset>", total - 10))
        break
    end
    local prob = state.prob or 0
    local pct = math.floor(prob * 100 + 0.5)
    local probCol = pct >= 50 and "green" or pct >= 25 and "yellow" or "red"
    local affs = {}
    for aff, _ in pairs(state.affs) do table.insert(affs, aff) end
    table.sort(affs)
    local affStr
    if #affs == 0 then
        affStr = "<dark_grey>none<reset>"
    else
        local colored = {}
        for _, aff in ipairs(affs) do
            local col = (GLUE.affs and GLUE.affs.colorMap and GLUE.affs.colorMap[aff]) or "white"
            table.insert(colored, string.format("<%s>%s<reset>", col, aff))
        end
        affStr = table.concat(colored, "<white>,<reset> ")
    end
    local bleedStr = (state.bleed and state.bleed > 0)
        and string.format(" <orange>bleed=%d<reset>", state.bleed) or ""
    cecho(string.format("\n  <white>%d<reset> [<%s>%d%%<reset>]%s %s",
        i, probCol, pct, bleedStr, affStr))
end
