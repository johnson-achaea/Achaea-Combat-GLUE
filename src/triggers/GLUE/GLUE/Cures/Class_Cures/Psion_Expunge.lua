if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = multimatches[1][2]
if not GLUE.IsTarget(targetName) then return end

local nextLine = multimatches[3][1] or ""

if GLUE.CheckSpecialCure(nextLine) then return end

GLUE.cure.ApplyTiered(GLUE.affs.cure_priority.expunge)
