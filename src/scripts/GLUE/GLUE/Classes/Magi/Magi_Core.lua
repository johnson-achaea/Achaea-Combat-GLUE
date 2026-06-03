GLUE = GLUE or {}
GLUE.magi = GLUE.magi or {}

GLUE.magi.resonance = GLUE.magi.resonance or {
    Fire  = 0,
    Water = 0,
    Earth = 0,
    Air   = 0,
}

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Magi state")
end
