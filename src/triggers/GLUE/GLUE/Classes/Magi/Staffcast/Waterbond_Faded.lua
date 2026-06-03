-- Pattern: ^The tendrils of water that bound (\w+) splash to the ground as the power sustaining them fades\.$
if not GLUE or not GLUE.state then return end
if not GLUE.IsTarget(matches[2]) then return end
GLUE.state.RemoveAffliction("waterbonds")
