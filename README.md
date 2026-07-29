# Siren Head Pill Pack

A pill pack for [Parakeet's Pill Pack Base (Revised)](https://github.com/Setnour6/PillPackBaseRevised).
Adds a **Siren Head** pill using `models/ametryx/master.mdl`.

## Requirements

- Pill Pack Base (Revised) — this pack does nothing without it (it prints a warning and stops loading).
- The Siren Head model addon providing `models/ametryx/master.mdl`.

## Install

Copy this folder into `garrysmod/addons/`, so you end up with
`garrysmod/addons/Sirenheadpill/lua/autorun/sirenhead_pack.lua`.

The pill shows up in the pill menu under the **Siren Head** pack.

## Controls

| Input | Action |
| --- | --- |
| Primary attack | Melee swipe (45 damage, 110 units) |
| Secondary attack | Siren blast (4s cooldown) |
| R | **Rage mode** — crawls on all fours, much faster, 20s, then a 45s cooldown |
| E | **Siren sonar** — stands still while a ring expands; players caught in it are highlighted for 8s. Press E again to stop, 30s cooldown |

## Files

- `lua/autorun/sirenhead_pack.lua` — registers the pack with `pk_pills.packStart`.
- `lua/autorun/sirenhead_include/pill_sirenhead.lua` — the pill definition (incl. rage mode).
- `lua/autorun/sirenhead_include/sonar.lua` — the sonar ability, its networking and rendering.
- `materials/pills/sirenhead.png` — pill menu icon (placeholder, 256x256; replace with real art).

## Tuning

Values worth adjusting once you see it in game, all in `pill_sirenhead.lua`:

- `hull` / `duckBy` — collision box size. Too small and you clip into things, too big and you get
  stuck in doorways.
- `camera.offset` / `camera.dist` — third person camera height and pull-back.
- `modelScale` — set above 1 if the model is player-height instead of towering.
- `anims.default` — uses the standard Garry's Mod player model animation set (`idle_magic`,
  `walk_magic`, `run_magic`, …). If the model ships its own sequences, put their names here.
- `sounds` — currently placeholder HL2 sounds; drop custom `.wav` files in `sound/` and point at them.

Full list of supported fields: `pk_pills.register` in the base's `lua/includes/modules/pk_pills.lua`.
