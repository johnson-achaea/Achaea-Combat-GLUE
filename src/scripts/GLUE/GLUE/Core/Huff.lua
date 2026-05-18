--[[
    G.L.U.E. Huff — 500ms heartbeat
    Modules register callbacks via GLUE.huff.Register(fn).
    All callbacks fire each tick in registration order.
    Start/stop with GLUE.huff.Start() / GLUE.huff.Stop().
]]--

GLUE = GLUE or {}
GLUE.huff = GLUE.huff or {}

-- Kill any timer from a previous script load before resetting state
if GLUE.huff.timerID then
    killTimer(GLUE.huff.timerID)
end

GLUE.huff.callbacks = {}
GLUE.huff.timerID   = nil

function GLUE.huff.Register(fn)
    table.insert(GLUE.huff.callbacks, fn)
end

function GLUE.huff.Tick()
    for _, fn in ipairs(GLUE.huff.callbacks) do
        fn()
    end
end

function GLUE.huff.Start()
    if GLUE.huff.timerID then return end
    GLUE.huff.timerID = tempTimer(0.5, function() GLUE.huff.Tick() end, true)
end

function GLUE.huff.Stop()
    if not GLUE.huff.timerID then return end
    killTimer(GLUE.huff.timerID)
    GLUE.huff.timerID = nil
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Huff (500ms heartbeat)")
end
