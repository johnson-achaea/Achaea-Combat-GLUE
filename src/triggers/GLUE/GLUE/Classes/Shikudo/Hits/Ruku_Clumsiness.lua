--[[
    GLUE Trigger: Ruku (Clumsiness / Healthleech)
    Pattern: Staff cracks against arm

    Behavior:
    - Gives clumsiness first
    - If clumsiness already present, gives healthleech instead
    - At kata 10+, gives both (clumsiness then healthleech)
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Ruku gives clumsiness first, then healthleech if clumsiness already present
GLUE.state.AddSmartAffliction({"clumsiness", "healthleech"})

if shik and shik.kata and shik.kata > 10 then
    GLUE.state.AddAffliction("healthleech")
end
