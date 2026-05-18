if not GLUE or not GLUE.IsTarget then return end
if not GLUE.IsTarget(matches[2]) then return end

for aff in matches[3]:gmatch("%S+") do
    GLUE.state.BranchAffliction(aff:gsub("[,.]", ""), 0.8)
end
