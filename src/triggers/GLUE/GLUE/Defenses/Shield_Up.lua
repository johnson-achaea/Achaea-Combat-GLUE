--[[
    GLUE Trigger: Shield Up
    Pattern: Target raises a shield defense
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

local targetName = matches[2]
if not GLUE.IsTarget(targetName) then return end

if GLUE.state.HasAffliction("prone") then return end

GLUE.defenses.Set("shield", true)

if not inRet() then
    send("ql")
    if GLUE.qlTrig then killTrigger(GLUE.qlTrig) end
    GLUE.qlTrig = tempTrigger(GLUE.target.name, function()
        if line:find("sprawled on the floor", 1, true) then
            killTrigger(GLUE.qlTrig)
            GLUE.qlTrig = nil
            GLUE.state.AddAffliction("prone")
            GLUE.defenses.Set("shield", false)
        end
    end)
    tempTimer(1, function()
        if GLUE.qlTrig then
            killTrigger(GLUE.qlTrig)
            GLUE.qlTrig = nil
        end
    end)
end
