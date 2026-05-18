if not GLUE or not GLUE.config then return end
GLUE.config.debug = not GLUE.config.debug
cecho(string.format("\n<cyan>[GLUE]<reset> Debug: %s<reset>", GLUE.config.debug and "<green>ON" or "<red>OFF"))
