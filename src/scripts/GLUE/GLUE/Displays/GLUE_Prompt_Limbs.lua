--[[
    G.L.U.E. Limb damage prompt segment
]]--

function GLUE.limbs.Prompt()
    if not GLUE.target or GLUE.target.name == "" then return "" end
    local ret = {}
    for _, limb in ipairs({"head", "torso", "left arm", "right arm", "left leg", "right leg"}) do
        local dmg = GLUE.limbs.GetDamage(GLUE.target.name, limb)
        local color = dmg > 100 and "<red>" or (dmg > 0 and "<orange>" or "<grey>")
        table.insert(ret, color .. math.floor(dmg))
    end
    return "<DimGrey>[" .. table.concat(ret, "<DimGrey>|") .. "<DimGrey>]"
end
