if not GLUE or not GLUE.IsTarget then return end
if GLUE.illusionCheck() then return end
if not GLUE.IsTarget(matches[3]) then return end

local side    = matches[2]  -- "left" or "right"
local broken  = "broken"  .. side .. "leg"

OppGainedAff(broken)

if #GLUE.state.states > 1 then GLUE.state.Optimize() end
if GLUE.UpdateDisplay then GLUE.UpdateDisplay() end
if GLUE.OnStateUpdate then GLUE.OnStateUpdate() end

local r = GLUE.integration.IHaveDefense("rupturesight")
GLUE.state.AddBleedPerState(r and 71 or 55, r and 71 or 55)
