# Siren Head Pill Pack

A small, self-contained pill pack base for Garry's Mod. No workshop base addon required — take a
pill entity and you become the model, press your revert key to change back.

## Install

Copy this folder into `garrysmod/addons/` (so you end up with
`garrysmod/addons/Sirenheadpill/lua/...`) and restart the game or server.

## Using it in game

1. Spawn menu → **Entities** → **Pills** → **Siren Head**.
2. Press **E** on the pill to transform.
3. Press **G** (or type `pill_revert` in console) to change back. Dying also reverts you.

## Adding your model

Put the Siren Head PM/NPC files in `models/` and `materials/` of this addon, then set the path in
`lua/pillbase/pills/sirenhead.lua`:

```lua
local MODEL = "models/sirenhead/sirenhead.mdl"
```

Until that model exists the pill falls back to a stock model so it is still usable.

## Adding more pills

Drop a new file in `lua/pillbase/pills/`. It is loaded on both the client and server automatically,
and a spawnable entity `pill_<id>` is generated for it.

```lua
local PILL = {}

PILL.Name = "Zombie"
PILL.Model = "models/zombie/classic.mdl"
PILL.Health = 150
PILL.RunSpeed = 180
PILL.Hull = { Vector(-16, -16, 0), Vector(16, 16, 72) }
PILL.ViewOffset = Vector(0, 0, 64)

PillBase.Register("zombie", PILL)
```

Every supported field and its default lives in `PillBase.Defaults` in
`lua/pillbase/sh_pillbase.lua`: model/skin/bodygroups/scale/colour, health, armour, walk and run
speed, jump power, gravity, step size, hull, view offset, third person settings, weapon stripping,
transform and revert sounds, and `OnTransform` / `OnRevert` callbacks.

## Console variables

| ConVar | Realm | Default | Description |
| --- | --- | --- | --- |
| `pillbase_enabled` | server | `1` | Allow players to take pills. |
| `pillbase_revert_key` | server | `KEY_G` | Key code used to revert. |
| `pillbase_thirdperson` | client | `1` | Use third person while transformed. |

## Lua API

```lua
PillBase.Register(id, pill)      -- register a pill (shared)
PillBase.Get(id)                 -- pill table by id (shared)
PillBase.IsTransformed(ply)      -- bool (shared)
PillBase.GetActivePill(ply)      -- pill table or nil (shared)
PillBase.Transform(ply, id)      -- server
PillBase.Revert(ply)             -- server
```

Hooks: `PillBase_PlayerTransformed(ply, pill)` and `PillBase_PlayerReverted(ply, pill)`.
