--[[
    GLUE Trigger: Weapon Venoms Wiped
    Patterns:
      - ^Being careful not to poison yourself, you wipe off all the venoms from (.+)\.$
      - ^You carefully wipe the venoms from your claws\.$

    Clears all venoms from a weapon when wiped
]]--

if not GLUE or not GLUE.venoms then return end

-- Extract weapon from matches
-- For claws pattern, matches[2] will be nil, so use "claws"
local weapon = matches[2] or "claws"

-- Clear all venoms from this weapon
GLUE.venoms.on_weapons[weapon] = {}
