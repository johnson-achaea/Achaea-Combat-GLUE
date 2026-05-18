if not GLUE.util.foozle or not GLUE.util.foozle.active then return end
table.insert(GLUE.util.foozle.items, {
    num    = tonumber(matches[2]),
    name   = matches[3],
    points = tonumber(matches[4]),
    found  = matches[5],
})
