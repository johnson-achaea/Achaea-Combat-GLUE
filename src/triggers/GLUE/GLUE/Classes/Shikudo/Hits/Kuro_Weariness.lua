--[[
    GLUE Trigger: Kuro (Weariness / Lethargy)
    Pattern: Staff cracks across thigh

    Behavior:
    - Gives weariness first
    - If weariness already present, gives lethargy instead
    - At kata 10+, gives both (weariness then lethargy)
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Kuro gives weariness first, then lethargy if weariness already present
GLUE.state.AddSmartAffliction({"weariness", "lethargy"})

if shik and shik.kata and shik.kata > 10 then
    GLUE.state.AddAffliction("lethargy")
end
