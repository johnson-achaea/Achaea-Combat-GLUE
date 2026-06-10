if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

-- Ignore if we didn't think they were prone (could be an illusion)
if not GLUE.state.HasAffliction("prone") then return end

-- Standing up while prone confirms no paralysis (paralysis prevents standing).
-- Only prune if paralysis isn't in every branch — pruning all states would be destructive.
if GLUE.state.HasAffliction("paralysis") and GLUE.state.GetProbability("paralysis") < 1 then
    GLUE.state.PruneStatesWithAffliction("paralysis")
end

GLUE.state.RemoveAffliction("prone")

if not inRet() and not curingPaused() then
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
