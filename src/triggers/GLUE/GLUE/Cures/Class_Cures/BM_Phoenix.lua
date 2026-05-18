--[[
    GLUE Trigger: Blademaster Phoenix
    Pattern: BM uses phoenix (full reset)
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

-- Phoenix completely resets afflictions
GLUE.Reset()

if GLUE.config.debug then
    cecho("\n<yellow>[GLUE]<reset> Target used phoenix - full reset")
end
