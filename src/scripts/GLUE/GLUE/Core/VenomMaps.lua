--[[
    G.L.U.E. Venom Maps
    Maps venom names to the afflictions they cause
]]--

GLUE = GLUE or {}
GLUE.venoms = GLUE.venoms or {}

-- Venom to affliction mapping
GLUE.venoms.map = {
    -- Standard venoms
    ["xentio"]         = "clumsiness",
    ["eurypteria"]     = "recklessness",
    ["kalmia"]         = "asthma",
    ["delphinium"]     = "sleep",
    ["digitalis"]      = "shyness",
    ["darkshade"]      = "darkshade",
    ["curare"]         = "paralysis",
    ["epteth"]         = "crippledarm",
    ["prefarar"]       = "sensitivity",
    ["monkshood"]      = "disloyalty",
    ["euphorbia"]      = "nausea",
    ["colocasia"]      = "deafblind",
    ["vernalius"]      = "weariness",
    ["epseth"]         = "crippledleg",
    ["larkspur"]       = "dizziness",
    ["slike"]          = "anorexia",
    ["notechis"]       = "haemophilia",
    ["vardrax"]        = "addiction",
    ["aconite"]        = "stupidity",
    ["selarnia"]       = "selarnia",
    ["gecko"]          = "slickness",
    ["scytherus"]      = "scytherus",
    ["voyria"]         = "voyria",

    -- Alchemist venoms
    ["pothealthleech"] = "healthleech",
    ["potloneliness"]  = "loneliness",
    ["potepilepsy"]    = "epilepsy",

    -- Paladin abilities
    ["torture"]        = "haemophilia",
    ["tormentone"]     = "healthleech",
    ["tormenttwo"]     = "confusion",
    ["exploit"]        = "weariness",
}

-- Track venoms on weapons (weapon name -> queue of venoms)
GLUE.venoms.on_weapons = {}

-- Track which weapons were used in last attack (cleared on hit confirmation)
GLUE.venoms.pending_weapons = {}

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Venom Maps")
end
