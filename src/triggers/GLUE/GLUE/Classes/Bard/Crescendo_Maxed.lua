-- Pattern: ^You sense that your crescendo is at hand, and it is time to bring the performance that is \w+ to a close\.$
if not GLUE or not GLUE.state then return end

GLUE.state.SetAfflictionStacks("crescendo", 5)
