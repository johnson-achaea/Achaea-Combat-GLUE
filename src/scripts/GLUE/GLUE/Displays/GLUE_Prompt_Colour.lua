--[[
    G.L.U.E. Affliction prompt

]]--

GLUE.RegisterOnAfflictionCured("display", function(affliction)
    if GLUE.config.echos or GLUE.config.debug then
        local col = GLUE.affs and GLUE.affs.colorMap and GLUE.affs.colorMap[affliction] or "white"
        GLUE.queueEcho(string.format("\n<red>[GLUE]<reset> -%s%s<reset>", "<" .. col .. ">", affliction))
    end
end)

function getColoredGLUEAffs()
  if not GLUE or not GLUE.state or not GLUE.affs then return end
  local glueAffs = {}
  for aff in pairs(GLUE.affs.list) do
    local prob = GLUE.state.GetProbability(aff)
    if prob >= 5 then
      local col  = GLUE.affs.colorMap[aff] or "cyan"
      local name = (Legacy.Curing.abbreviations and Legacy.Curing.abbreviations[aff]) or aff
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
  local maxBleed = 0
  for _, state in ipairs(GLUE.state.states) do
    local b = state.bleed or 0
    if b > maxBleed then maxBleed = b end
  end
  if maxBleed > 0 then
    table.insert(glueAffs, "<red:black>bld:" .. maxBleed)
  end

  if #glueAffs > 0 then
    echo("\n")
    cecho(table.concat(glueAffs, " "))
  end
end