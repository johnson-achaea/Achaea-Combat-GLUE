# GLUE — Good Luck Understanding Everything

## Achaea Combat

Before talking about GLUE, we should talk about Achaean combat. Achaea is a RPG text game with PvP elements first created in 1997. In Achaean PvP combat, players give "afflictions" (or affs) to other players at a particular speed. The attack they use, the time it takes to attack, and their goal all vary based on the class of the player. Afflictions are cured off by various means, all of which have their own curing speed. Eating herbs, smoking herbs, focusing, using special class-based cures, etc.

Afflictions can be hindering, such as clumsiness, which gives a chance for the target to miss their attacks. Afflictions can build towards a kill of some sort, such as voyria, which kills in some time if not cured, or finally, afflictions can build towards a "lock" - a state where afflictions can no longer be cured. One example of a lock affliction is asthma, which prevents smoking. 

Where this gets interesting, and the reason a system like GLUE is needed, is when we add in uncertainty. If two afflictions are cured by the same thing, what is cured is random, and we have no idea what was cured. On the other hand, we may make reasonable guesses about what was cured based on things we see. For instance, if they eat kelp which may have cured asthma or clumsiness, and then they smoke to cure something else, we now know that the original eat cured away asthma. If they don't smoke, we can reason that it is likely they cured clumsiness instead. 

## GLUE

GLUE is a hidden Markov model (HMM) based affliction tracker for Achaea, built to run in Mudlet. It maintains multiple possible *states* simultaneously — each state is one hypothesis about what afflictions the target currently has. As attacks land and cures fire, states branch (when uncertain) or are pruned (when new information eliminates possibilities). Affliction confidence is reported as the fraction of states containing a given affliction.

---

## Core Concepts

### States

A **state** is one possible world: a table of afflictions the target might have, each with a stack count, plus a probability weight.

```lua
-- Conceptual structure of one state
{
    affs = {
        asthma = 1,
        clumsiness = 1,
    },
    prob = 0.35,   -- 35% probability weight (all states sum to 1.0)
}
```

`GLUE.state.states` is the array of all live states. The number of states grows with uncertainty and shrinks when information prunes implausible branches.

### Branching

When a cure fires and multiple afflictions could have been cured, each state forks into one branch per possible cure outcome. Probabilities are split proportionally.

### Pruning

When the game gives us definitive information (e.g., the target just ate an herb → they don't have anorexia), all states inconsistent with that fact are deleted and the remainder renormalized.

### Waste Penalty

If a state contains nothing for a cure to act on, that state's probability is multiplied by `GLUE.config.wastePenalty` (default `0.4`). Over several cure rounds, implausible states decay toward zero and are eventually hard-pruned.

### Exponential Decay (Huff Pruner)

Every 500ms, the huff tick checks whether cure balances have been free longer than they should be (given the afflictions in each state). States that fail this test receive an exponential decay penalty: `exp(-0.5 * overtime_seconds)`. When the effective sample size drops below half the state count, states below 1% probability are hard-pruned.

---

## Setup & Initialization

GLUE initializes automatically when its Mudlet package loads. The load sequence:

1. `GLUE_Init.lua` creates the `GLUE` namespace and sets config defaults.
2. Core modules populate affliction maps, balance timers, defense tables, etc.
3. Cure method handlers and class-specific modules load.
4. Triggers register, ready to fire on MUD output.
5. After a 3-second defer, the display color map is built.

You will see: `[GLUE] Loaded: Good Luck Understanding Everything v2.0.0`

---

## Configuration

```lua
GLUE.config.maxStates     -- Hard cap on live states before forced optimization (default 500)
GLUE.config.debug         -- Print per-state detail on every change (default false)
GLUE.config.echos         -- Short affliction-change messages in the main window (default true)
GLUE.config.wastePenalty  -- Probability multiplier applied when a cure finds nothing (default 0.4)
```

---

## Callbacks

Assign functions to these hooks to react to GLUE events. They are called by GLUE internally — you own the implementation.

```lua
GLUE.OnStateUpdate = function()
    -- Fires whenever the affliction state changes: aff added, removed, pruned, or branched.
    -- Use this to re-evaluate your attack strategy.
end

GLUE.OnDefenseChanged = function(defense, isUp)
    -- Fires when a defense toggles.
    -- defense: string key (e.g. "shield", "rebounding")
    -- isUp: boolean
end

GLUE.OnChaseUpdated = function()
    -- Fires when the chase system updates the target's estimated location.
end

GLUE.UpdateDisplay = function()
    -- Fires whenever the UI should refresh (state, defenses, limbs changed).
end

GLUE.OnAffGiven = function(affliction)
    -- Fires when an affliction is added to states.
    -- Use this for party calls or external logging.
end
```

**Example** — minimal combat routing wiring (from GLUEoffenses):

```lua
local function setAttackBasedOnClass()
    local class = gmcp.Char.Status.class
    if class == "Psion" then
        setPsionAttack()
    elseif class == "Dragon" then
        setDragonAttack()
    end
end

GLUE.OnStateUpdate    = setAttackBasedOnClass
GLUE.OnDefenseChanged = setAttackBasedOnClass
GLUE.OnChaseUpdated   = setAttackBasedOnClass
```

### Registering Per-Affliction Cure Callbacks

```lua
GLUE.RegisterOnAfflictionCured(key, fn)
-- key: unique string to prevent re-registration on reload
-- fn(affliction): called when GLUE confirms an affliction was cured
```

---

## Target Management

```lua
GLUE.SetTarget(name)      -- Switch target; resets all state, balances, and defenses
GLUE.ClearTarget()        -- Clear current target and reset
GLUE.IsTarget(name)       -- Case-insensitive check; use in triggers to gate processing
GLUE.target.name          -- String: current target name (nil if none)
```

---

## Affliction State API

### Queries

```lua
GLUE.state.HasAffliction(aff)           -- Boolean: is aff present in any state above ~1%?
GLUE.state.GetProbability(aff)          -- Number 0–100: confidence target has this aff
GLUE.state.GetAfflictionList(threshold) -- [{affliction, probability}, ...] sorted descending
GLUE.state.CountAfflictions(threshold)  -- Count of affs above threshold probability
GLUE.state.GetMinStacks(aff)            -- Lowest stack count across all states
GLUE.state.GetMaxStacks(aff)            -- Highest stack count across all states
```

### Modifications

These are used internally by triggers but can be called from custom code:

```lua
GLUE.state.AddAffliction(aff, addToRoom)
-- Add aff to all states; fires OnStateUpdate

GLUE.state.RemoveAffliction(aff)
-- Remove aff from all states; fires OnStateUpdate

GLUE.state.BranchAffliction(aff, weight)
-- Split: states without aff branch into "has it (weight)" + "doesn't (1-weight)"

GLUE.state.AddAfflictionStacks(aff, count)
-- Add N stacks to all states (for multi-stack attacks)

GLUE.state.SetAfflictionStacks(aff, count)
-- Set exact stack count (when count is known from output)

GLUE.state.AddTimedAffliction(aff, duration_seconds)
-- Add aff with a known expiry; auto-removed after duration
-- Timed affs report 100% probability until expiry
```

### Pruning

```lua
GLUE.state.PruneStatesWithAffliction(aff)
-- Confirmed they don't have aff: delete all states containing it

GLUE.state.PruneStatesWithoutAffliction(aff)
-- Confirmed they do have aff: delete all states lacking it

GLUE.state.PruneStates(conditionFn)
-- Delete all states where conditionFn(state) returns true; renormalize

GLUE.state.PruneByAfflictions(affList, mode)
-- mode = "any": prune states containing any aff in list
-- mode = "all": prune states containing all affs in list
-- mode = "none": prune states containing none of the affs
```

### Housekeeping

```lua
GLUE.state.Optimize()       -- Deduplicate identical states, merge their probabilities
GLUE.state.Normalize()      -- Ensure all probs sum to 1.0
GLUE.state.CopyState(state) -- Deep copy a state table
GLUE.Reset()                -- Clear all states, return to one empty state
GLUE.state.GetStatesSummary() -- Debug string showing first 10 states
```

---

## Cure Balance

GLUE tracks cooldown timers for each cure method.

```lua
GLUE.balance.IsAvailable(cureType)    -- Boolean
GLUE.balance.FreeFor(cureType)        -- Seconds this balance has been free (0 if on balance)
GLUE.balance.TimeRemaining(cureType)  -- Seconds until this balance recovers
GLUE.balance.SetOffBalance(cureType)  -- Mark as used; starts the cooldown timer
GLUE.balance.ResetAll()               -- Clear all timers (called automatically on target switch)
```

**Cure type strings**: `"herb"`, `"smoke"`, `"salve"`, `"focus"`, `"tree"`, `"sip"`, `"restore"`, `"shrug"`

Default durations (seconds):

| Type    | Duration |
|---------|----------|
| herb    | 1.3      |
| smoke   | 1.3      |
| salve   | 0.8      |
| focus   | 2.3      |
| tree    | 9.3      |
| sip     | 4.3      |
| restore | 3.8      |
| shrug   | 10.0     |

---

## Defense Tracking

```lua
GLUE.defenses.Set(defense, boolean)  -- Update defense; fires OnDefenseChanged
GLUE.defenses.Has(defense)           -- Boolean query
GLUE.defenses.GetActive()            -- List of currently-up defense names
GLUE.defenses.Reset()                -- Clear all (called automatically on target switch)
```

Tracked defenses: `shield`, `rebounding`, `curseward`, `reflection`, `prismatic`, `cloak`, `sileris`, `aria`, `hands`, `healing`, `breathing`, `speed`, `blind`, `deaf`

Direct read: `GLUE.defenses.current["shield"]` — boolean.

---

## Limb Tracking

```lua
GLUE.limbs.AddHit(targetName, limb, damage)
-- Increments cumulative damage% for that limb.
-- Auto-adds "damaged" at >100%, "mangled" at >200%.
-- Starts a 180s auto-reset timer (simulates natural healing).

GLUE.limbs.ResetLimb(targetName, limb)
-- Called by the auto-timer or a restoration cure; downgrades affliction.

GLUE.limbs.HandleRestorationCure(targetName, area)
-- Called after restoration's 4s balance; downgrades one limb in the area.

GLUE.limbs.damage[targetName][limb]  -- Flat damage% value
```

Limb strings: `"head"`, `"torso"`, `"left arm"`, `"right arm"`, `"left leg"`, `"right leg"`

---

## Utility Functions

```lua
GLUE.util.ShowStatus()
-- Echo top afflictions with probabilities to the main window

GLUE.util.ShowStates()
-- Echo first 10 states for debugging

GLUE.util.GetTopAfflictions(count)
-- Returns [{affliction, probability}, ...] top N affs

GLUE.util.GetCurableAfflictions(method, herbOrLocation)
-- method: "herb", "smoke", "focus", "tree", "salve", "restore"
-- herbOrLocation: "piece of kelp" / "head" / etc.
-- Returns [{aff, prob}, ...] of afflictions this cure would hit

GLUE.util.GetStats()
-- Returns {stateCount, afflictionCount, highConfidence, mediumConfidence, avgAffsPerState}
```

---

## Huff Heartbeat

The huff tick fires every 500ms and drives pruning and timed-aff expiry.

```lua
GLUE.huff.Register(fn)  -- Register a 500ms callback
GLUE.huff.Start()       -- Begin ticking
GLUE.huff.Stop()        -- Stop ticking
GLUE.huff.Tick()        -- Fire all callbacks once manually
```

---

## Cure Handler API

These are called by GLUE's built-in triggers. You can call them from custom triggers if you detect cures in non-standard lines.

```lua
GLUE.cure.Herb(herbName)
-- herbName: e.g. "piece of kelp", "goldenseal root"
-- Prunes anorexia (they could eat → they don't have it), then branches for possible herb cures.

GLUE.cure.ApplyTiered(priorityTable)
-- For passive/tree/expunge cures.
-- priorityTable: { affliction = tier_number, ... }
-- Branches by the highest-tier curable aff in each state; applies waste penalty if none found.
```

---

## Chase System

```lua
GLUE.chase.BeginSquint(dir)       -- Squint out the given exit to locate target
GLUE.chase.Locate()               -- Progressively narrow target location
GLUE.chase.DoLocate(targetName)   -- Class-specific locate (override per class)
GLUE.chase.disabled               -- Set to false to enable; true by default
```

---

## Affliction Reference

`GLUE.affs.list` — Boolean table of all valid affliction keys.  
`GLUE.affs.stackable` — Subset that can hold >1 stack (unweaving levels, humours, etc.).

Call `GLUE.util.ShowStatus()` in-game for a live listing of current probabilities.

---

## Typical Integration Checklist

1. **Set a target** — call `GLUE.SetTarget(targetName)` when you engage.
2. **Hook OnStateUpdate** — assign your attack-selection function so it re-evaluates on every state change.
3. **Hook OnDefenseChanged** — update attack selection when shield/rebounding status changes.
4. **Query afflictions** — use `GLUE.state.GetProbability(aff)` or `GLUE.state.HasAffliction(aff)` inside your attack logic.
5. **Query cures** — use `GLUE.util.GetCurableAfflictions(method, arg)` to find what the target can remove next balance.
6. **Check defenses** — use `GLUE.defenses.Has("shield")` etc. before selecting attacks.
7. **Clear on disengage** — call `GLUE.ClearTarget()` when combat ends to reset all state.
