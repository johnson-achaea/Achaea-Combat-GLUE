--[[
    GLUE Trigger: Apostate_Syphon
    Pattern: Multiline trigger for Apostate_Syphon cure
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = multimatches[1][2]
if not GLUE.IsTarget(targetName) then return end

local nextLine = multimatches[3][1] or ""

-- Check for special cure messages, return if one was found
if GLUE.CheckSpecialCure(nextLine) then
    return
end

-- Default to passive cure if no special message
GLUE.cure.Passive()
