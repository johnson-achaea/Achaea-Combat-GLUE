GLUE = GLUE or {}
GLUE.myBalance = GLUE.myBalance or {}
GLUE.myBalance.freeAt = GLUE.myBalance.freeAt or {}

-- Seconds until the given type ("balance" or "eq") is free.
function GLUE.myBalance.TimeRemaining(balType)
    local t = GLUE.myBalance.freeAt[balType] or 0
    return math.max(0, t - os.clock())
end

-- True if the given type is currently available.
function GLUE.myBalance.IsUp(balType)
    return GLUE.myBalance.TimeRemaining(balType) == 0
end

-- True if we will regain both balance and eq before the target's herb balance recovers.
-- Also true if the target has anorexia (they can't eat regardless of herb balance).
function GLUE.myBalance.BeforeHerb()
    if GLUE.state.HasAffliction("anorexia") then return true end
    local myReady   = math.max(GLUE.myBalance.TimeRemaining("balance"), GLUE.myBalance.TimeRemaining("eq"))
    local theirHerb = GLUE.balance.TimeRemaining("herb")
    return myReady < theirHerb
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: MyBalance")
end
