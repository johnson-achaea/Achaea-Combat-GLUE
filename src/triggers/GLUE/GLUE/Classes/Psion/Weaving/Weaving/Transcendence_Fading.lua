if not GLUE then return end
if GLUE.illusionCheck() then return end
GLUE.psion.transcend = tonumber(matches[2])
deleteLine()
cecho("<LightGoldenrod>\n " .. matches[2] .. "% Transcendance\n")
