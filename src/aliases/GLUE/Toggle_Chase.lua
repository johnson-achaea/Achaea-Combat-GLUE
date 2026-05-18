if not GLUE or not GLUE.chase then return end
GLUE.chase.disabled = not GLUE.chase.disabled
if GLUE.chase.disabled then
    GLUE.chase.direction   = nil
    GLUE.chase.fromRoom    = nil
    GLUE.chase.toRoom      = nil
    GLUE.chase._locateStep = 0
    if GLUE.OnChaseUpdated then GLUE.OnChaseUpdated() end
end
cecho(string.format("\n<cyan>[GLUE]<reset> Chase: %s<reset>", GLUE.chase.disabled and "<red>OFF" or "<green>ON"))
