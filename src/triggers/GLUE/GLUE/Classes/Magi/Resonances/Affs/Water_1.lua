-- Pattern: ^As you begin to tap your connection with the Elemental Plane of Water, you summon up a freezing wave to deluge (\w+)\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddAffliction("frostbite")
