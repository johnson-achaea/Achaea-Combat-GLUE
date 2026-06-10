-- Pattern: ^Like a rising sun your blade moves from low to high, cutting across \w+'s (\w+) hip\.$
-- matches[2] = "left" or "right"
if not GLUE or not GLUE.bard then return end

local side = matches[2]
GLUE.limbs.AddHit(GLUE.target.name, side .. " leg", 20)
GLUE.limbs.AddHit(GLUE.target.name, "torso", 20)
GLUE.state.AddAfflictions({"prone", "asthma"})

GLUE.bard.OnHit()
