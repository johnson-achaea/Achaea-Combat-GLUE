if not GLUE or not GLUE.target or GLUE.target.name == "" then return end
if GLUE.illusionCheck() then return end

if GLUE.defenses.Has("deaf") then
    GLUE.defenses.Set("deaf", false)
else
    GLUE.state.AddAffliction("sensitivity")
end
