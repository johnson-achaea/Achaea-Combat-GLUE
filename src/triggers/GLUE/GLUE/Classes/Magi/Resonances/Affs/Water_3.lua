-- Pattern: ^The might of Elemental Water suffusing you, you tear at the vital fluids which sustain the body of (\w+) with your will alone\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.AddSmartAffliction({"nausea", "anorexia"})
