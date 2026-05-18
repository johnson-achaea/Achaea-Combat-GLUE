--[[
    GLUE Trigger: Weapon Hit Confirmed
    Pattern: Prompt (fires after attack message if no miss/dodge)

    Applies venoms from pending weapons when hit is confirmed.
    This trigger should be disabled by default and enabled by Attack triggers.
]]--

if not GLUE or not GLUE.venoms then return end

-- Process the hit - apply venoms from pending weapons
GLUE.venoms.ProcessHit()

-- Disable this trigger until next attack
disableTrigger("GLUE Confirmed Hit")

-- Disable miss detection (hit was confirmed)
disableTrigger("GLUE Attack Missed")
