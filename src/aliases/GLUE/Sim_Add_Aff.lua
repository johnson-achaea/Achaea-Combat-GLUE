if not GLUE or not GLUE.state then return end
local aff = matches[2]
local ok = GLUE.state.AddAffliction(aff)
if not ok then
    cecho("\n<red>[GLUE]<reset> Unknown affliction: " .. aff)
end
GLUE.FlushEchoBuffer()
