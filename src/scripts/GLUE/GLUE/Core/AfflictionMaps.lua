--[[
    G.L.U.E. Affliction Maps
    Defines all afflictions and their cure methods
]]--

GLUE = GLUE or {}
GLUE.affs = GLUE.affs or {}

-- Master list of all afflictions
GLUE.affs.list = {
    -- Mental afflictions
    addiction = true,
    agoraphobia = true,
    amnesia = true,
    anorexia = true,
    claustrophobia = true,
    confusion = true,
    dementia = true,
    depression = true,
    dizziness = true,
    epilepsy = true,
    generosity = true,
    hallucinations = true,
    hypersomnia = true,
    hypochondria = true,
    impatience = true,
    justice = true,
    loneliness = true,
    lovers = true,
    masochism = true,
    pacifism = true,
    paranoia = true,
    recklessness = true,
    shyness = true,
    stupidity = true,
    vertigo = true,

    -- Physical afflictions
    asthma = true,
    clumsiness = true,
    darkshade = true,
    haemophilia = true,
    healthleech = true,
    lethargy = true,
    nausea = true,
    paralysis = true,
    parasite = true,
    scytherus = true,
    sensitivity = true,
    slickness = true,
    weariness = true,
    prone     = true,

    -- Limb affs (mending cures - 1s salve balance)
    brokenleftarm = true,
    brokenrightarm = true,
    brokenleftleg = true,
    brokenrightleg = true,

    -- Limb breaks (restoration cures - 4s restore balance)
    damagedleftarm = true,
    damagedrightarm = true,
    damagedleftleg = true,
    damagedrightleg = true,
    damagedhead = true,
    mangledleftarm = true,
    mangledrightarm = true,
    mangledleftleg = true,
    mangledrightleg = true,
    mangledhead = true,
    mildtrauma = true,
    serioustrauma = true,

    -- Salve afflictions
    aflame = true,
    calcifiedhead = true,
    calcifiedtorso = true,
    crushedthroat = true,
    frozen = true,
    frostbite = true,
    hypothermia = true,
    itching = true,
    selarnia = true,
    shivering = true,
    stuttering = true,

    -- Special afflictions
    aeon = true,
    blind = true,
    deaf = true,
    deadening = true,
    disloyalty = true,
    hellsight = true,
    manaleech = true,
    tension = true,
    timeloop = true,
    voyria = true,

    -- Pariah specific
    flushings = true,
    fulminated = true,
    pyramides = true,
    sandfever = true,

    -- Air Lord specific
    pressure = true,

    -- Psion specific
    blackout = true,
    unweavingbody = true,
    unweavingmind = true,
    unweavingspirit = true,
    mindravaged = true,
    lightbinds = true,
    entangled = true,
    bloodfire = true,

    -- Dragon specific
    bound = true,
    enmeshed = true,

    -- Other
    fratricide = true,
    retribution = true,
    shadowmadness = true,
    spiritburn = true,
    tenderskin = true,

    -- Stacking afflictions (can exceed 1 stack)
    melancholic = true,
    choleric = true,
    phlegmatic = true,
    sanguine = true,
    horror = true,
    pyre = true,
    burning = true,
    torntendon = true,
    skullfracture = true,
    wristfracture = true,
    crackedrib = true,
    crescendo = true,
}

-- Afflictions that can stack beyond 1 (all others are capped at 1).
GLUE.affs.stackable = {
    unweavingbody  = true,
    unweavingmind  = true,
    unweavingspirit = true,
    melancholic    = true,
    choleric       = true,
    phlegmatic     = true,
    sanguine       = true,
    horror         = true,
    pyre           = true,
    burning        = true,
    torntendon     = true,
    skullfracture  = true,
    wristfracture  = true,
    crackedrib     = true,
    pressure       = true,
    crescendo      = true,
}

-- Herb to affliction mappings
GLUE.affs.herbs = {
    -- Kelp cures
    ["piece of kelp"] = {"asthma", "clumsiness", "sensitivity", "weariness", "healthleech", "parasite"},
    ["aurum flake"] = {"asthma", "clumsiness", "sensitivity", "weariness", "healthleech", "parasite"},

    -- Lobelia cures
    ["lobelia seed"] = {"hypochondria", "fratricide", "tenderskin", "spiritburn", "agoraphobia", "claustrophobia", "loneliness", "masochism", "recklessness", "vertigo", "spiritdisrupt", "airdisrupt", "earthdisrupt", "firedisrupt", "waterdisrupt"},
    ["argentum flake"] = {"hypochondria", "fratricide", "tenderskin", "spiritburn", "agoraphobia", "claustrophobia", "loneliness", "masochism", "recklessness", "vertigo", "spiritdisrupt", "airdisrupt", "earthdisrupt", "firedisrupt", "waterdisrupt"},

    -- Ash cures
    ["prickly ash bark"] = {"confusion", "dementia", "hallucinations", "hypersomnia", "paranoia"},
    ["stannum flake"] = {"confusion", "dementia", "hallucinations", "hypersomnia", "paranoia"},

    -- Bellwort cures
    ["bellwort flower"] = {"timeloop", "generosity", "pacifism", "justice", "lovers"},
    ["cuprum flake"] = {"timeloop", "generosity", "pacifism", "justice", "lovers"},

    -- Goldenseal cures
    ["goldenseal root"] = {"fulminated", "sandfever", "dizziness", "epilepsy", "impatience", "shyness", "stupidity", "depression"},
    ["plumbum flake"] = {"fulminated", "sandfever", "dizziness", "epilepsy", "impatience", "shyness", "stupidity", "depression"},

    -- Bloodroot cures
    ["bloodroot leaf"] = {"pyramides", "paralysis", "slickness"},
    ["magnesium chip"] = {"pyramides", "paralysis", "slickness"},

    -- Ginseng cures
    ["ginseng root"] = {"flushings", "addiction", "darkshade", "haemophilia", "lethargy", "nausea", "scytherus"},
    ["ferrum flake"] = {"flushings", "addiction", "darkshade", "haemophilia", "lethargy", "nausea", "scytherus"},

    -- Rage cures
    ["rage"] = {"generosity", "pacifism", "justice"},

    -- Pressure (Air Lord)
    ["prickly pear"] = {"pressure"},
    ["calcite mote"] = {"pressure"},
}

-- Herb name conversion (for parsing variations)
GLUE.affs.herbConversion = {
    ["aurum flake"] = "kelp",
    ["piece of kelp"] = "kelp",
    ["lobelia seed"] = "lobelia",
    ["argentum flake"] = "lobelia",
    ["prickly ash bark"] = "ash",
    ["stannum flake"] = "ash",
    ["bellwort flower"] = "bellwort",
    ["cuprum flake"] = "bellwort",
    ["goldenseal root"] = "goldenseal",
    ["plumbum flake"] = "goldenseal",
    ["bloodroot leaf"] = "bloodroot",
    ["magnesium chip"] = "bloodroot",
    ["ginseng root"] = "ginseng",
    ["ferrum flake"] = "ginseng",
    ["rage"] = "rage",
    ["hawthorn berry"] = "hawthorn",
    ["calamine crystal"] = "hawthorn",
    ["bayberry bark"] = "bayberry",
    ["arsenic pellet"] = "bayberry",
    ["prickly pear"] = "pear",
    ["calcite mote"] = "pear",
}

-- Smoke cures
GLUE.affs.smoke = {
    "deadening",
    "disloyalty",
    "slickness",
    "manaleech",
    "aeon",
    "hellsight",
    "tension",
}

-- Focus cures
GLUE.affs.focus = {
    "stuttering",
    "lovers",
    "agoraphobia",
    "anorexia",
    "claustrophobia",
    "confusion",
    "dizziness",
    "epilepsy",
    "generosity",
    "loneliness",
    "masochism",
    "pacifism",
    "recklessness",
    "shyness",
    "stupidity",
    "vertigo",
    "airdisrupt",
    "firedisrupt",
    "waterdisrupt",
    "paranoia",
    "dementia",
    "hallucinations",
}

-- Tree tattoo cures (cures almost everything)
GLUE.affs.tree = {
    "crushedthroat",
    "stuttering",
    "itching",
    "aeon",
    "healthleech",
    "haemophilia",
    "clumsiness",
    "aflame",
    "paranoia",
    "vertigo",
    "agoraphobia",
    "dizziness",
    "claustrophobia",
    "recklessness",
    "epilepsy",
    "addiction",
    "stupidity",
    "scytherus",
    "slickness",
    "generosity",
    "justice",
    "pacifism",
    "confusion",
    "voyria",
    "weariness",
    "hallucinations",
    "disloyalty",
    "lethargy",
    "shyness",
    "sensitivity",
    "asthma",
    "brokenleftarm",
    "brokenrightarm",
    "brokenleftleg",
    "brokenrightleg",
    "darkshade",
    "impatience",
    "anorexia",
    "loneliness",
    "hypochondria",
    "selarnia",
    "frozen",
    "airdisrupt",
    "earthdisrupt",
    "firedisrupt",
    "spiritdisrupt",
    "waterdisrupt",
    "hellsight",
    "nausea",
    "lovers",
    "parasite",
    "depression",
    "timeloop",
    "manaleech",
    "tension",
    "tenderskin",
    "spiritburn",
    "pyramides",
    "sandfever",
    "fratricide",
    "unweavingspirit",
    "unweavingmind",
    "unweavingbody",
}

-- Salve (apply) cures - includes both mending (1s) and restoration (4s) afflictions
GLUE.affs.salve = {
    ["body"] = {"torso", "itching", "anorexia", "frozen", "aflame", "selarnia"},
    ["skin"] = {"frostbite", "anorexia", "frozen", "selarnia"},
    ["torso"] = {"calcifiedtorso", "anorexia", "torso", "aflame", "hypothermia", "selarnia", "mildtrauma", "serioustrauma"},
    ["head"] = {"calcifiedhead", "stuttering", "head", "crushedthroat", "damagedhead", "mangledhead"},
    ["arms"] = {"brokenleftarm", "brokenrightarm", "damagedleftarm", "damagedrightarm", "mangledleftarm", "mangledrightarm"},
    ["legs"] = {"brokenleftleg", "brokenrightleg", "damagedleftleg", "damagedrightleg", "mangledleftleg", "mangledrightleg"},
    ["ears"] = {"head"},
}

-- Restoration salve progression (4s restore balance)
-- Maps current affliction to what it downgrades to
GLUE.affs.restore_downgrade = {
    -- Limbs: mangled → damaged
    mangledleftarm = "damagedleftarm",
    mangledrightarm = "damagedrightarm",
    mangledleftleg = "damagedleftleg",
    mangledrightleg = "damagedrightleg",
    mangledhead = "damagedhead",

    -- Limbs: damaged → broken (arms/legs only) or cured (head)
    damagedleftarm = "brokenleftarm",
    damagedrightarm = "brokenrightarm",
    damagedleftleg = "brokenleftleg",
    damagedrightleg = "brokenrightleg",
    damagedhead = "",  -- cured completely

    -- Torso: serioustrauma → mildtrauma → cured
    serioustrauma = "mildtrauma",
    mildtrauma = "",  -- cured completely
}

-- Affs removed together per-state when the key aff is cured (set-keyed for O(1) lookup).
GLUE.affs.curedWith = {
    haemophilia = { bloodfire = true },
}

-- All restoration-curable afflictions
GLUE.affs.restore_list = {
    "mangledleftarm", "mangledrightarm", "mangledleftleg", "mangledrightleg", "mangledhead",
    "damagedleftarm", "damagedrightarm", "damagedleftleg", "damagedrightleg", "damagedhead",
    "serioustrauma", "mildtrauma",
}

-- Passive cure affliction list (used by class abilities)
-- This is the comprehensive list of afflictions that can be cured by passive/class cures
GLUE.affs.passive_curable = {
    "timeloop",
    "parasite",
    "retribution",
    "shadowmadness",
    "depression",
    "pyramides",
    "itching",
    "crushedthroat",
    "stuttering",
    "addiction",
    "aflame",
    "agoraphobia",
    "anorexia",
    "asthma",
    "claustrophobia",
    "clumsiness",
    "confusion",
    "brokenleftarm",
    "brokenrightarm",
    "brokenleftleg",
    "brokenrightleg",
    "darkshade",
    "deadening",
    "dementia",
    "disloyalty",
    "disrupt",
    "dizziness",
    "epilepsy",
    "generosity",
    "haemophilia",
    "hallucinations",
    "healthleech",
    "hellsight",
    "hypersomnia",
    "hypochondria",
    "impatience",
    "lethargy",
    "loneliness",
    "lovers",
    "manaleech",
    "masochism",
    "nausea",
    "pacifism",
    "paranoia",
    "recklessness",
    "scytherus",
    "selarnia",
    "sensitivity",
    "shyness",
    "slickness",
    "stupidity",
    "weariness",
    "vertigo",
    "voyria",
    "tension",
    "pressure",
    "mycalium",
    "sandfever",
    "rebbies",
    "flushings",
    "paralysis"
}

GLUE.affs.colorMap = GLUE.affs.colorMap or {}

function GLUE.affs.buildColorMap()
    if not (Legacy and Legacy.Curing and Legacy.Curing.cures) then return end
    GLUE.affs.colorMap = {}
    for c, t in pairs(Legacy.Curing.cures) do
        local col = Legacy.Settings.Curing.colors[c]
                    or Legacy.Settings.Curing.colors[c:lower()]
                    or "cyan"
        for _, a in pairs(t) do
            GLUE.affs.colorMap[a:lower()] = col
        end
    end
end

GLUE.affs.buildColorMap()

-- Initialize all affliction scores to 0
for affliction, _ in pairs(GLUE.affs.list) do
    GLUE.affs.score = GLUE.affs.score or {}
    GLUE.affs.score[affliction] = GLUE.affs.score[affliction] or 0
end

if GLUE.config and GLUE.config.debug then
    cecho("\n<green>[GLUE]<reset> Loaded: Affliction Maps")
end
