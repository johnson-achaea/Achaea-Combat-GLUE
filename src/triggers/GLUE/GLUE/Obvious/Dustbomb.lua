--[[
    GLUE Trigger: Dustbomb
    Pattern: You lob a dust bomb at the ground and watch it explode.
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

GLUE.state.AddAffliction("blackout")
tempTimer(4,function() GLUE.state.RemoveAffliction("blackout") end)