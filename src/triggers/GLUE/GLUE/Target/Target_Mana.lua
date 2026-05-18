if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

GLUE.target.mana    = tonumber(matches[3])
GLUE.target.manaMax = tonumber(matches[4])
GLUE.target.manaPercent = tonumber(matches[3])/tonumber(matches[4])

if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
