-- Class-specific overrides for chase hooks.
-- Loaded after Chase.lua so these replace the default implementations.

function GLUE.chase.DoFlyingCheck(targetName)
    local class = gmcp.Char and gmcp.Char.Status and gmcp.Char.Status.class or ""
    if class == "Alchemist" then
        send("educe lead " .. targetName)
    elseif class == "Psion" then
        send("WEAVE LAUNCH " .. targetName .. "/touch tentacle " .. targetName)
    else
        send("touch tentacle " .. targetName)
    end
end

function GLUE.chase.DoLocate(targetName)
    local class = gmcp.Char and gmcp.Char.Status and gmcp.Char.Status.class or ""
    if class == "Alchemist" then
        send("ether seek " .. targetName)
    elseif class == "Monk" then
        send("mind sense " .. targetName)
    else
        send("farsee " .. targetName)
    end
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Chase Class Actions")
end
