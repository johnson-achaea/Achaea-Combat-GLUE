if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[3]) then return end

local headDamage = GLUE.limbs.GetDamage(GLUE.target.name, "head") or 0
GLUE.limbs.AddHit(GLUE.target.name, "head", 28.1)

GLUE.state.ForEachState(function(state, added)
    local wasProne = state.affs.prone
    state.affs.prone = 1
    added.prone = true
    if state.affs.stupidity or wasProne or headDamage > 75 then
        state.affs.impatience = 1
        added.impatience = true
    else
        state.affs.stupidity = 1
        added.stupidity = true
    end
end)
GLUE.state.AddBleedPerState(15, 15)
