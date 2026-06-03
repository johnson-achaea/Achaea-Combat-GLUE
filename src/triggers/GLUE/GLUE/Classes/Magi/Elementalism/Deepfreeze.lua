-- Patterns: deepfreeze cast messages (group spell, no target check)
if not GLUE or not GLUE.state then return end
GLUE.state.AddAffliction("deepfreeze")
