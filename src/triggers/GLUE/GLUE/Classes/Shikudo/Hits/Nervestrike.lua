--[[
    GLUE Trigger: Shikudo Nervestrike
    Pattern: ^You whip a .+ at the side of ([\w'\-]+)\'s neck\.$

    Nervestrike gives paralysis
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

-- Extract the name from matches
local targetName = matches[2]

-- Only process if this is our target
if not GLUE.IsTarget(targetName) then return end

-- Add paralysis
GLUE.state.AddAffliction("paralysis")

if GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Nervestrike - added paralysis")
end
