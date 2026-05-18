local planted = matches[2] == "*"
local id      = matches[3]
local area    = matches[4]
table.insert(GLUE.ctf.flags, { id = id, area = area, planted = planted })
