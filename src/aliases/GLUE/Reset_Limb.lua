if not GLUE or not GLUE.target then return end
local t = GLUE.target.name
if not t or t == "" then cecho("\n<red>[GLUE]<reset> No target set.") return end

local limbMap = {
    ll  = "left leg",
    rl  = "right leg",
    la  = "left arm",
    ra  = "right arm",
    h   = "head",
    t   = "torso",
    all = "all",
}

local limb = limbMap[matches[2]]
if not limb then return end

if limb == "all" then
    GLUE.limbs.ResetAll(t)
else
    GLUE.limbs.ResetLimb(t, limb)
end
