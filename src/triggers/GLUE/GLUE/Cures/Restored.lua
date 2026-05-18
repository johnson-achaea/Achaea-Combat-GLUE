--[[
    GLUE Trigger: Opponent Applied Restoration
    Pattern: ^([\w'\-]+) crackles with blue energy that wreathes itself about \w+ limbs\.

    Captures when target's restoration salve completes healing
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

-- Extract the name from matches
local targetName = matches[2]

-- Only process if this is our target
if not GLUE.IsTarget(targetName) then return end

-- Clear any pending salve application (it was restoration, not mending)
GLUE.pending_salve = nil

-- Process restoration cure (cures all 4 limbs)
GLUE.cure.Restore()
