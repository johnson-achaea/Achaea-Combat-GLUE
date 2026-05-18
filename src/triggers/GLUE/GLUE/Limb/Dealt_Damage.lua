--[[
    GLUE Trigger: Limb Damage Dealt
    Patterns: Limb damage messages

    Tracks percentage damage dealt to opponent limbs
]]--

if not GLUE or not GLUE.limbs then return end
if GLUE.illusionCheck() then return end

local amount = tonumber(matches.amount)
local name = matches.name
local limb = matches.limb

if not amount or not name or not limb then return end

-- Add the hit
GLUE.limbs.AddHit(name, limb, amount)
