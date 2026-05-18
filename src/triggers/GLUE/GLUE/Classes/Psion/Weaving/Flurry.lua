if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

local n = tonumber(matches[3]) or 1
if n > 1 then
    GLUE.state.SetAfflictionStacks("unweavingspirit", n)
elseif GLUE.state.HasAffliction("unweavingspirit") then
    GLUE.state.SetAfflictionStacks("unweavingspirit", 1)
end