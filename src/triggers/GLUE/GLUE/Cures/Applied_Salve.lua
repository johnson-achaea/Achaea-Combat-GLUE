--[[
    GLUE Trigger: Opponent Applied Salve
    Pattern: ^([\w'\-]+) takes some (?:balm|salve) from a vial and rubs it on \w+ ([\w'\-]+)\.$

    Captures when target applies a salve to a body location
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

-- Extract the name and location from matches
local targetName = matches[2]
local location = matches[3]

-- Only process if this is our target
if not GLUE.IsTarget(targetName) then return end

-- if they applied within the last second, ignore this one.
if not GLUE.balance.IsAvailable("salve") then
    if GLUE.config.debug then
        cecho("\n<red>[GLUE]<reset> Ignoring salve apply: " .. location)
    end
    return
end

-- Important: "applied salve" message is the same for both mending and restoration
-- We can't tell which it is, so we're going to make a naive assumption.
-- if a restoration aff is present for the limb, assume they are applying to it.

-- Don't process if we're already waiting on a restoration timer for this location
-- if GLUE.pending_restoration then
--     if GLUE.config.debug then
--         cecho(string.format("\n<yellow>[GLUE]<reset> Ignoring salve to %s (restoration timer active)", location))
--     end
--     return
-- end

-- Get the list of afflictions this location can cure
local affsList = GLUE.affs.salve[location]
if not affsList then
    if GLUE.config.debug then
        cecho("\n<red>[GLUE]<reset> Unknown salve location: " .. location)
    end
    return
end

-- Check what types of afflictions they could be curing
local has_mending = false
local has_restoration = false

for _, state in ipairs(GLUE.state.states) do
    for _, aff in ipairs(affsList) do
        if state.affs[aff] then
            if GLUE.affs.restore_downgrade[aff] then
                has_restoration = true
            else
                has_mending = true
            end
        end
    end
    if has_mending and has_restoration then break end
end

-- If they're on salve bal with a resto aff, assume this is a resto apply. It is not perfect.
-- later on in this project, this is a serious area for improvement. We can fork on the assumption of resto/mending
if has_restoration or (not has_mending) then
    GLUE.pending_restoration = true

    if GLUE.config.debug then
        cecho(string.format("\n<cyan>[GLUE]<reset> Restoration timer started for %s", location))
    end

    if GLUE.pending_restoration_timer and remainingTime(GLUE.pending_restoration_timer) then killTimer(GLUE.pending_restoration_timer) end

    GLUE.pending_restoration_timer = tempTimer(3.8, function()
        GLUE.cure.RestorationComplete(location)
        GLUE.pending_restoration = false
    end)
else
    -- handles mending affs
    GLUE.cure.Salve(location)
end
