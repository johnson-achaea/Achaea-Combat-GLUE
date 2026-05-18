--[[
    GLUE Trigger: Weapon Attack
    Patterns: Multiple weapon attack messages

    Records which weapon(s) were used in an attack.
    Actual venom application happens on hit confirmation (next prompt).
]]--

if not GLUE or not GLUE.venoms then return end

-- Extract weapon from matches
-- Most patterns capture the weapon in matches[2]
-- Patterns "You viciously lacerate" don't capture weapon (Sylvan abilities)
local weapon = matches[2]

-- Some patterns don't capture weapon, skip weapon tracking for those
if weapon and weapon ~= "" then
    -- Record this weapon was used in the attack
    GLUE.venoms.RecordAttack(weapon)

    -- Enable the hit confirmation trigger (fires on next prompt)
    enableTrigger("GLUE Confirmed Hit")

    -- Enable the miss detection trigger
    enableTrigger("GLUE Attack Missed")
end
