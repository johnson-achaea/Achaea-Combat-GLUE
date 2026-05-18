--[[
    G.L.U.E. Passive/Class Cure Handler
    Delegates to GLUE.cure.ApplyTiered using the passive priority table.
    Priority is defined in Core/CurePriorities.lua.
]]--

GLUE = GLUE or {}
GLUE.cure = GLUE.cure or {}

function GLUE.cure.Passive()
    GLUE.cure.ApplyTiered(GLUE.affs.cure_priority.passive)
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Passive Cure Handler")
end
