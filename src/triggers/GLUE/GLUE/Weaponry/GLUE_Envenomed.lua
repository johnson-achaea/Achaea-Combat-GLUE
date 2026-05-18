--[[
    GLUE Trigger: Weapon Envenomed
    Patterns:
      - ^You rub some ([\w'\-]+) on (.*)\.$
      - ^You secrete ([\w'\-]+) and deftly bring (.*) to your mouth, letting the venom drip upon it\.$

    Tracks venoms applied to weapons
]]--

if not GLUE or not GLUE.venoms then return end

-- Extract venom and weapon from matches
local venom = matches[2]
local weapon = matches[3]

-- Normalize claw variants to a single key so dragon rend hits the same queue
if weapon and weapon:match("claw") then weapon = "claws" end

-- Add venom to weapon's queue
GLUE.venoms.AddToWeapon(venom, weapon)
