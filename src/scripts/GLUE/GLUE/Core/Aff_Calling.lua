function curingPaused()
  return GLUE.integration.IsCuringPaused()
end

function inRet()
  return GLUE.integration.IsTimeDistorted()
end

function pt(message)
  if curingPaused() or inRet() then return end
  if commsDisabled then
    send("say *CYRENE " .. message)
  else
    send("pt " .. message)
  end
end

function ptMulti(messagesToCall)
  if curingPaused() or inRet() then return end
  local stringToSend = ""
  for i = 1, #messagesToCall do
    local partyCall = "pt " .. messagesToCall[i] .. "|"
    stringToSend = stringToSend .. partyCall
  end
  send(stringToSend)
end

callAfflictions = callAfflictions or false
reportAffs = reportAffs or false

doNotCallAffs = {
  paralysis      = true,
  impatience     = true,
  prone          = true,
  damagedrightarm  = true,
  damagedleftarm   = true,
  damagedleftleg   = true,
  damagedrightleg  = true,
  mangledrightarm  = true,
  mangledleftarm   = true,
  mangledrightleg  = true,
  mangledleftleg   = true,
  damagedhead      = true,
  mangledhead      = true,
  mildtrauma       = true,
  serioustrauma    = true,
  concussion       = true,
  brokenrightarm   = true,
  brokenleftarm    = true,
  brokenrightleg   = true,
  brokenleftleg    = true,
}

affBuffer = {}

GLUE.OnAffGiven = function(aff)
  if callAfflictions
    and reportAffs
    and not GLUE.integration.IsTimeDistorted()
    and not doNotCallAffs[aff] then

      table.insert(affBuffer, aff)
  end
end

function flushAffBuffer()
  if #affBuffer == 0 then return end
  pt(target .. ": " .. table.concat(affBuffer, ", "))
  affBuffer = {}
end
