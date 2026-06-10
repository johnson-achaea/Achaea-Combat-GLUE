if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

local uwtype = matches[3]
GLUE.psion.StartUnweaveTick(uwtype)

GLUE.affQueue.Queue(function()
    GLUE.state.AddAffliction("unweaving" .. uwtype)
    if uwtype == "body" then
        if GLUE.state.HasAffliction("unweavingmind") then
            GLUE.state.AddAffliction("prone")
        end
    elseif uwtype == "mind" then
        if GLUE.state.HasAffliction("unweavingbody") then
            GLUE.state.AddAffliction("prone")
        end
    elseif uwtype == "spirit" then
        GLUE.state.AddAffliction("prone")
    end
end)
