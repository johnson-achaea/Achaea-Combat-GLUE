--[[
    G.L.U.E. Affliction prompt

]]--

GLUE.RegisterOnAfflictionCured("display", function(affliction)
    if GLUE.config.echos or GLUE.config.debug then
        local col = GLUE.affs and GLUE.affs.colorMap and GLUE.affs.colorMap[affliction] or "white"
        GLUE.queueEcho(string.format("\n<red>[GLUE]<reset> -%s%s<reset>", "<" .. col .. ">", affliction), "removed")
    end
end)

-- Per-limb display: worst state wins. broken=lowercase, damaged=UPPER, mangled=M+UPPER.
local limbGroups = {
  { broken="brokenleftleg",  damaged="damagedleftleg",  mangled="mangledleftleg",  abbrevs={"ll", "LL", "MLL"} },
  { broken="brokenrightleg", damaged="damagedrightleg", mangled="mangledrightleg", abbrevs={"rl", "RL", "MRL"} },
  { broken="brokenleftarm",  damaged="damagedleftarm",  mangled="mangledleftarm",  abbrevs={"la", "LA", "MLA"} },
  { broken="brokenrightarm", damaged="damagedrightarm", mangled="mangledrightarm", abbrevs={"ra", "RA", "MRA"} },
  {                          damaged="damagedhead",     mangled="mangledhead",     abbrevs={nil,  "H", "MH"} },
}
local limbAffSet = {}
for _, g in ipairs(limbGroups) do
  if g.broken  then limbAffSet[g.broken]  = true end
  if g.damaged then limbAffSet[g.damaged] = true end
  if g.mangled then limbAffSet[g.mangled] = true end
end

function getColoredGLUEAffs()
  if not GLUE or not GLUE.state or not GLUE.affs then return end
  local glueAffs = {}

  -- Limb affs: show only the worst state per limb, suppress lesser states.
  for _, g in ipairs(limbGroups) do
    local mangledProb = g.mangled and GLUE.state.GetProbability(g.mangled) or 0
    local damagedProb = g.damaged and GLUE.state.GetProbability(g.damaged) or 0
    local brokenProb  = g.broken  and GLUE.state.GetProbability(g.broken)  or 0

    local displayAff, displayAbbrev, displayProb
    if mangledProb >= 5 then
      displayAff, displayAbbrev, displayProb = g.mangled, g.abbrevs[3], mangledProb
    elseif damagedProb >= 5 then
      displayAff, displayAbbrev, displayProb = g.damaged, g.abbrevs[2], damagedProb
    elseif brokenProb >= 5 then
      displayAff, displayAbbrev, displayProb = g.broken,  g.abbrevs[1], brokenProb
    end

    if displayAff and displayAbbrev then
      local col = GLUE.affs.colorMap[displayAff] or "orange"
      if displayProb >= 99 then
        table.insert(glueAffs, "<" .. col .. ":black>" .. displayAbbrev)
      else
        table.insert(glueAffs, "<" .. col .. ":black>" .. displayAbbrev .. math.floor(displayProb))
      end
    end
  end

  -- All other affs (limb affs handled above).
  for aff in pairs(GLUE.affs.list) do
    if not limbAffSet[aff] then
      local prob = GLUE.state.GetProbability(aff)
      if prob >= 5 then
        local col  = GLUE.affs.colorMap[aff] or "cyan"
        local name = GLUE.integration.GetAfflictionAbbrev(aff)
        if GLUE.affs.stackable and GLUE.affs.stackable[aff] then
          local stacks = GLUE.state.GetMaxStacks(aff)
          if stacks > 1 then
            table.insert(glueAffs, "<" .. col .. ":black>" .. name .. "x" .. stacks)
          else
            table.insert(glueAffs, "<" .. col .. ":black>" .. name)
          end
        elseif prob >= 99 then
          table.insert(glueAffs, "<" .. col .. ":black>" .. name)
        else
          table.insert(glueAffs, "<" .. col .. ":black>" .. name .. math.floor(prob))
        end
      end
    end
  end

  local maxBleed = 0
  for _, state in ipairs(GLUE.state.states) do
    local b = state.bleed or 0
    if b > maxBleed then maxBleed = b end
  end
  if maxBleed > 0 then
    table.insert(glueAffs, "<red:black>bld:" .. maxBleed)
  end

  if #glueAffs > 0 then
    return table.concat(glueAffs, " ")
  end
  return ""
end

function echoColoredGLUEAffs()
  local s = getColoredGLUEAffs()
  if s and s ~= "" then
    cecho(s)
  end
end