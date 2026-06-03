-- Patterns:
--   ^You sense your grand crescendo beginning to build about \w+\.$
--   ^You sense your grand performance drawing ever closer to a conclusion about \w+\.$
if not GLUE or not GLUE.state then return end

GLUE.state.AddAffliction("crescendo")

