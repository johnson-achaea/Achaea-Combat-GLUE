GLUE = GLUE or {}
GLUE.affQueue = GLUE.affQueue or {}
GLUE.affQueue.pending = {}
GLUE.affQueue.active  = true

function GLUE.affQueue.Queue(fn)
    table.insert(GLUE.affQueue.pending, fn)
end

function GLUE.affQueue.CancelLast()
    if #GLUE.affQueue.pending > 0 then
        table.remove(GLUE.affQueue.pending)
    end
end

function GLUE.affQueue.Flush()
    GLUE.affQueue.active = false
    local pending = GLUE.affQueue.pending
    GLUE.affQueue.pending = {}
    for _, fn in ipairs(pending) do
        fn()
    end
    GLUE.affQueue.active = true
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Aff Queue")
end
