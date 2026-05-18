--[[
    GLUE Trigger: Weapon Attack Missed
    Patterns: Various dodge/parry/miss messages

    Clears pending weapon attacks when the attack doesn't connect.
]]--

if not GLUE or not GLUE.venoms then return end

-- Clear pending attacks (no venoms applied)
GLUE.venoms.ClearPending()

-- Disable both confirmation triggers
disableTrigger("GLUE Confirmed Hit")
disableTrigger("GLUE Attack Missed")
