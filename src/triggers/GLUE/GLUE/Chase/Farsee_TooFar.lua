if not GLUE or not GLUE.IsTarget then return end
if not GLUE.IsTarget(matches[2]) then return end

if callSense and pt then
  pt(matches[2] .. " is in " .. matches[3])
end

if not GLUE.chase or GLUE.chase.disabled then return end

local cities = { Mhaldor=true, Ashtan=true, Targossas=true, Cyrene=true, Eleusis=true }
if cities[matches[3]] then return end

expandAlias("goto " .. matches[3])
