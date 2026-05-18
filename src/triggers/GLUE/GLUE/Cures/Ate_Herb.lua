--[[
    GLUE Trigger: Opponent Ate Herb
    Pattern: ^([\w'\-]+) eats (?:a|an|some) (.*)\.$ (multiline with 1 line spacer)

    This is a multiline trigger that captures:
    Line 1: Name and herb eaten
    Line 2: (spacer)
    Line 3: Any cure message that follows
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

-- Extract the name and herb from matches
local targetName = multimatches[1][2]
local herbEaten = multimatches[1][3]

-- Only process if this is our target
if not GLUE.IsTarget(targetName) then return end

-- Remove "withered " prefix if present
herbEaten = herbEaten:gsub("withered ", "")

-- Check for special cure messages on the next line
local nextLine = multimatches[3][1] or ""

if GLUE.CheckSpecialCure(nextLine) then return end

-- Items that use their own balance, not herb balance
if herbEaten:find("dolomite") or herbEaten:find("echinacea") then return end

if herbEaten:find("irid") or herbEaten:find("potash") then
    GLUE.target.AdjustVitals(0.08, 0.08)
    return
end

-- Hawthorn/calamine give deaf defense but don't use herb balance
if herbEaten:find("hawthorn") or herbEaten:find("calamine") then
    tempTimer(3.8, function() if GLUE and GLUE.defenses then GLUE.defenses.Set("deaf", true) end end)
    return
end

-- Bayberry/arsenic give blindness defense
if herbEaten:find("bayberry") or herbEaten:find("arsenic") then
     if GLUE and GLUE.defenses then GLUE.defenses.Set("blind", true) end
    return
end

-- Kola gives kola defense (faster herb eating)
if herbEaten:find("kola") then return end

-- Process the herb normally
GLUE.cure.Herb(herbEaten)
