--[[
    GLUE Trigger: Sapience - Apply Restoration/Mending
    Pattern: ^--> (\w+): apply (restoration|mending) to (\w+)

    Sapience reveals the exact command before the apply message fires.
    Cache the target+location so Applied_Salve can skip the ambiguous fork.
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[2]) then return end

local key      = matches[2]:lower()
local applyType = matches[3]
local location  = matches[4]:lower()

if applyType == "restoration" then
    GLUE.pendingRestoration = GLUE.pendingRestoration or {}
    GLUE.pendingRestoration[key] = location
else
    GLUE.pendingMending = GLUE.pendingMending or {}
    GLUE.pendingMending[key] = location
end
