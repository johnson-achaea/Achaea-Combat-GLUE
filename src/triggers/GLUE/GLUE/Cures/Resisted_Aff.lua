--[[
    GLUE Trigger: Affliction Resisted
    Pattern: ^Gritting \w+ teeth, ([\w'\-]+) drives off the attempt to afflict \w+ with (\w+)\.$

    Fires when a target resists an affliction we attempted to deliver.
    Removes it from the call buffer (so it is never party-called) and
    compensates the HMM state as if the affliction was cured.

    Gated behind reportAffs so it only fires during our own attack window.
]]--

if not GLUE or not GLUE.IsTarget then return end
if not reportAffs then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

local aff = matches[3]:lower()

-- Remove from call buffer so it isn't reported to party.
for i = #affBuffer, 1, -1 do
    if affBuffer[i] == aff then
        table.remove(affBuffer, i)
        break
    end
end

GLUE.state.RemoveAffliction(aff)
