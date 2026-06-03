-- Pattern: Turning to a crystalline golem you direct him to project a disruptive tone at a disorientation vibration.
if not GLUE or not GLUE.state then return end
GLUE.state.AddSmartAffliction({"prone", "dizziness"})
