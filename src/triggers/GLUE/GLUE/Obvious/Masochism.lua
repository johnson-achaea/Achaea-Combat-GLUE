--[[
    GLUE Trigger: Masochism
    Multiple patterns showing masochism symptoms
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Add masochism affliction
GLUE.state.AddAffliction("masochism")
