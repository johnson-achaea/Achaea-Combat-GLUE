if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = multimatches[1][2]
if not GLUE.IsTarget(targetName) then return end

local nextLine = multimatches[3][1] or ""

-- Fool 3p cures 3 affs; check specific cure for first, then apply 2 more passive cures.
if not GLUE.CheckSpecialCure(nextLine) then
    GLUE.cure.Passive()
end
GLUE.cure.Passive()
GLUE.cure.Passive()
