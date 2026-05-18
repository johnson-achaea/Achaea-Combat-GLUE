if not GLUE or not GLUE.config then return end
GLUE.config.echos = not GLUE.config.echos
cecho(string.format("\n<cyan>[GLUE]<reset> Echos: %s<reset>", GLUE.config.echos and "<green>ON" or "<red>OFF"))
