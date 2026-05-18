if not GLUE or not GLUE.cure then return end
local input = matches[2]

local herbShorthands = {
    ["kelp"]       = "piece of kelp",
    ["lobelia"]    = "lobelia seed",
    ["ash"]        = "prickly ash bark",
    ["bellwort"]   = "bellwort flower",
    ["goldenseal"] = "goldenseal root",
    ["bloodroot"]  = "bloodroot leaf",
    ["ginseng"]    = "ginseng root",
    ["rage"]       = "rage",
    ["hawthorn"]   = "hawthorn berry",
    ["bayberry"]   = "bayberry bark",
    ["pear"]       = "prickly pear",
}

if input == "passive" then
    GLUE.cure.Passive()
elseif input == "tree" then
    GLUE.cure.Tree()
elseif input == "focus" then
    GLUE.cure.Focus()
elseif input == "smoke" then
    GLUE.cure.Smoke()
else
    local herb = input:match("^eat%s+(.+)$")
    local salveLocation = input:match("^salve%s+(.+)$")
    if herb then
        local fullName = herbShorthands[herb] or herb
        GLUE.cure.Herb(fullName)
    elseif salveLocation then
        GLUE.cure.Salve(salveLocation)
    else
        cecho("\n<red>[GLUE]<reset> Usage: gcure passive|tree|focus|smoke|eat <herb>|salve <location>")
        return
    end
end
GLUE.FlushEchoBuffer()
