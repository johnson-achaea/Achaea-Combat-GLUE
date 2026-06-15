if not GLUE or not GLUE.myBalance then return end

local duration = tonumber(matches[2])
if not duration then return end

local key = matches[1]:lower():find("equilibrium", 1, true) and "eq" or "balance"
local newFreeAt = os.clock() + duration

if (GLUE.myBalance.freeAt[key] or 0) < newFreeAt then
    GLUE.myBalance.freeAt[key] = newFreeAt
end
