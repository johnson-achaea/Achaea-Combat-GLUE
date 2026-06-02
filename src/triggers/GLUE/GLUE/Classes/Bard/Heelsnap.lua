-- Pattern: ^A .+ sings with a metallic song as you direct a deep cut toward \w+'s (\w+) leg\.$
-- matches[2] = "left" or "right"
if not GLUE or not GLUE.bard then return end

local side = matches[2]
local pos  = GLUE.bard.position

-- front position deals limb damage (not a tracked affliction)
if pos == "side" then
    if side == "left" then
        GLUE.state.AddAffliction("healthleech")
    elseif side == "right" then
        GLUE.state.AddAffliction("sensitivity")
    end
elseif pos == "back" then
    GLUE.state.AddAffliction("hamstring")
end

GLUE.bard.OnHit()
