if not GLUE or not GLUE.cure then return end
if GLUE.illusionCheck() then return end
if not GLUE.target or GLUE.target.name == "" then return end

local nextLine = multimatches[2][1] or ""

if GLUE.CheckSpecialCure(nextLine) then return end

GLUE.cure.Passive()
