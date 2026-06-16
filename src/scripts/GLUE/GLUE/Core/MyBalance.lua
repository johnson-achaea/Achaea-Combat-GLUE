GLUE = GLUE or {}
GLUE.myBalance = GLUE.myBalance or {}
GLUE.myBalance.freeAt        = GLUE.myBalance.freeAt        or {}
GLUE.myBalance.lastDuration  = GLUE.myBalance.lastDuration  or {}

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
    return myReady <= theirHerb
end

-- True when the target will get exactly one herb eat between our upcoming attack
-- and the follow-up: our window end (myReady + nextDuration) falls within their
-- current herb cycle (theirHerb + herb balance).
-- overrideDuration sets the follow-up balance time; defaults to the larger of
-- the last recorded balance and eq durations.
function GLUE.myBalance.OneEatWindow(overrideDuration)
    if GLUE.state.HasAffliction("anorexia") then return true end
    local myReady   = math.max(GLUE.myBalance.TimeRemaining("balance"), GLUE.myBalance.TimeRemaining("eq"))
    local nextDur   = overrideDuration
                      or math.max(GLUE.myBalance.lastDuration["balance"] or 1,
                                  GLUE.myBalance.lastDuration["eq"]     or 1)
    local ourWindow = myReady + nextDur
    return (ourWindow) < (GLUE.balance.TimeRemaining("herb") + GLUE.balance.durations.herb) 
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: MyBalance")
end
