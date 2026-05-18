if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if targetName and targetName ~= "" then
  if not GLUE.IsTarget(targetName) then return end
end

GLUE.defenses.Set("shield", false)
GLUE.state.AddAffliction("prone")
