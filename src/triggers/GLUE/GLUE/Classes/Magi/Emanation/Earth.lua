-- Pattern: ^The might of elemental Earth thrumming within your bones, you point .+ at (\w+) and an intangible wave of power strikes forth to smite \w+\.$
if not GLUE or not GLUE.magi then return end
GLUE.magi.resonance.Earth = 0
if GLUE.IsTarget(matches[2]) then
    GLUE.state.AddAffliction("calcifiedhead")
end
