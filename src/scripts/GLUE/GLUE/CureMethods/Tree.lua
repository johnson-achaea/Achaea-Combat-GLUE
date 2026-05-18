--[[
    G.L.U.E. Tree Tattoo Cure Handler
    Delegates branching to GLUE.cure.ApplyTiered using the tree priority table.
    Priority is defined in Core/CurePriorities.lua.
]]--

GLUE = GLUE or {}
GLUE.cure = GLUE.cure or {}

function GLUE.cure.Tree()
    if GLUE.balance.tree == 1 then
        if GLUE.config.debug then
            cecho(string.format("\n<yellow>[GLUE]<reset> Ignored tree (on balance, %.1fs remaining)",
                GLUE.balance.TimeRemaining("tree")))
        end
        return
    end

    GLUE.balance.SetOffBalance("tree")

    -- Touching tree requires no paralysis
    GLUE.state.PruneStatesWithAffliction("paralysis")

    -- Must have had at least one tree-curable aff
    GLUE.state.PruneByAfflictions(GLUE.affs.tree, "none")

    if #GLUE.state.states == 0 then
        if GLUE.config.debug then
            cecho("\n<yellow>[GLUE]<reset> No states had curable affs for tree")
        end
        return
    end

    GLUE.cure.ApplyTiered(GLUE.affs.cure_priority.tree)
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Tree Cure Handler")
end
