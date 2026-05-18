GLUE = GLUE or {}
GLUE.dragon = GLUE.dragon or {}

-- Pending curse affliction (set when curse is cast, cleared when target convulses).
GLUE.dragon.curseSent = GLUE.dragon.curseSent or nil

-- Whether we are currently enmeshing the target.
GLUE.dragon.enmeshing = GLUE.dragon.enmeshing or false

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Dragon state")
end
