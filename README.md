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
| R | **Rage mode** — crawls on all fours while moving, much faster, 12s, then a 40s cooldown |
| E | **Siren sonar** — stands still while a ring expands; players/NPCs it passes are highlighted for 10s. Press E again to stop, 30s cooldown |

Cooldowns and bindings are shown in the bottom-right HUD while transformed.

## Files

- `lua/autorun/sirenhead_pack.lua` — registers the pack with `pk_pills.packStart`.
- `lua/autorun/sirenhead_include/pill_sirenhead.lua` — the pill definition (incl. rage mode).
- `lua/autorun/sirenhead_include/abilities.lua` — rage mode + sonar (server logic, networking, world rendering).
- `lua/autorun/sirenhead_include/hud.lua` — bottom-right ability/cooldown HUD.
- `materials/pills/sirenhead.png` — pill menu icon (256x256).

## Tuning

Values worth adjusting once you see it in game, all in `pill_sirenhead.lua`:

- `hull` / `duckBy` — collision box size. Too small and you clip into things, too big and you get
  stuck in doorways.
- `camera.offset` / `camera.dist` — third person camera height and pull-back.
- `modelScale` — how tall he is; currently `.35`.
- `anims.default` / `anims.rage` — the model's own sequences (`idle`, `walk`, `run`, `crawl`,
  `kill`, `shot`, …).
- Speeds, rage timings and sonar tuning live at the top of `abilities.lua`.
- `sounds` — currently placeholder HL2 sounds; drop custom `.wav` files in `sound/` and point at them.

Full list of supported fields: `pk_pills.register` in the base's `lua/includes/modules/pk_pills.lua`.
