-- Pattern: ^The might of Elemental Earth coursing through you, you smite (\w+) with the full force of your directed will\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("crackedrib")
