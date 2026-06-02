-- Pattern: ^Your feet move in (\w+) perfected, speeding each step within a new blade's song\.$
-- matches[2] = tempo ("adagio", "moderato", "allegro", "none")
if not GLUE or not GLUE.bard then return end
GLUE.bard.tempo = matches[2]
GLUE.bard.SetPosition("front")
