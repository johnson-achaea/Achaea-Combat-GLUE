if not GLUE then return end
if GLUE.illusionCheck() then return end

GLUE.target.manaPercent = math.max(GLUE.target.manaPercent or 0.32, 0.32)

if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
