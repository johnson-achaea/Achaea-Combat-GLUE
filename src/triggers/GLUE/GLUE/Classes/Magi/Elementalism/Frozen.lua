-- Pattern: ^You raise a hand towards [\w'\-]+ and blast [\w'\-]+ with cold, frigid air\.$
if not GLUE or not GLUE.state then return end
GLUE.state.ApplyFreeze()
