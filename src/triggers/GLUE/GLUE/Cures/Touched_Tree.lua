--[[
    GLUE Trigger: Opponent Touched Tree
    Pattern: ^(\w+) touches a tree of life tattoo\.$ (multiline with 1 line spacer)

    This is a multiline trigger that captures:
    Line 1: Name touching tree
    Line 2: (spacer)
    Line 3: Any cure message that follows
]]--

if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end

-- Extract the name from matches
local targetName = multimatches[1][2]

-- Only process if this is our target
if not GLUE.IsTarget(targetName) then return end

GLUE.util.PruneWith("paralysis")
-- Process tree tattoo cure
GLUE.cure.Tree()
