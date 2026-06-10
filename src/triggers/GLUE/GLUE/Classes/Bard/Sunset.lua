-- Pattern: ^Blood erupts from the (\w+) arm of \w+ in a crimson spray\.$
-- matches[2] = arm side ("left"/"right")
if not GLUE or not GLUE.bard then return end

GLUE.limbs.AddHit(GLUE.target.name, matches[2] .. " arm", 20)
GLUE.limbs.AddHit(GLUE.target.name, "head", 20)
GLUE.state.AddAfflictions({"impatience", "stupidity", "slickness"})

GLUE.bard.OnHit()
