--[[
    G.L.U.E. Target Checking
    Helper functions for checking if someone is the current target
]]--

GLUE = GLUE or {}
GLUE.target = GLUE.target or {}

--[[
    Check if a name matches the current target
    @param name (string) - The name to check
    @return (boolean) - true if this is the current target
]]--
function GLUE.IsTarget(name)
    if not name then return false end
    if not GLUE.target.name or GLUE.target.name == "" then return false end

    -- Case-insensitive comparison
    return name:lower() == GLUE.target.name:lower()
end

--[[
    Set the current target
    @param name (string) - The name of the new target
]]--
function GLUE.SetTarget(name)
    if not name then return end

    -- If switching targets, reset tracking
    if GLUE.target.name and GLUE.target.name ~= "" and GLUE.target.name:lower() ~= name:lower() then
        if GLUE.killRestoreTimers then GLUE.killRestoreTimers() end
        GLUE.Reset()
    end

    GLUE.target.name = name

    if GLUE.config.debug then
        cecho(string.format("\n<green>[GLUE]<reset> Target set to: %s", name))
    end
end

--[[
    Clear the current target
]]--
function GLUE.ClearTarget()
    if GLUE.killRestoreTimers then GLUE.killRestoreTimers() end
    GLUE.target.name = ""
    GLUE.target.class = ""
    GLUE.Reset()

    if GLUE.config.debug then
        cecho("\n<green>[GLUE]<reset> Target cleared")
    end
end

-- Pattern → affliction table for confirmed single-cure follow-up lines.
-- Add new entries here to extend without touching the function.
GLUE.specialCureMap = {
    { pattern = "The light behind the eyes of",                         aff = "unweavingmind"     },
    { pattern = "suddenly seems much more vital",                       aff = "unweavingbody"     },
    { pattern = "straightens, as if some great burden had been lifted", aff = "guilt"             },
    { pattern = "gives a sigh of relief%.",                             aff = "retribution"       },
    { pattern = "Lucidity returns to the eyes of",                      aff = "shadowmadness"     },
    { pattern = "ceases secreting slime%.",                             aff = "rebbies"           },
    { pattern = "violent trembling",                                    aff = "whisperingmadness" },
    { pattern = "nervous trembling",                                    aff = "mycalium"          },
    { pattern = "seems suddenly unburdened, clarity reasserting itself upon", aff = "unweavingspirit" },
}

function GLUE.CheckSpecialCure(line)
    if not line then return false end
    for _, entry in ipairs(GLUE.specialCureMap) do
        if string.find(line, entry.pattern) then
            GLUE.state.RemoveAffliction(entry.aff)
            return true
        end
    end
    return false
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Target Checking")
end
