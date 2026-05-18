if not GLUE or not GLUE.limbs then return end
if GLUE.illusionCheck() then return end

local pct  = tonumber(matches.pct)
local name = matches.name
local limb = matches.limb

if not pct or not name or not limb then return end

GLUE.limbs.damage[name] = GLUE.limbs.damage[name] or {}
GLUE.limbs.damage[name][limb] = pct

if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
