# Development baseline

Recorded for roadmap P00 on 2026-11-08 (Asia/Jakarta), against revision `29e2783` with roadmap documentation edits present. No gameplay code was changed for this baseline.

## Automated checks

`flutter analyze` exits 1 with 10 informational findings and no reported errors or warnings. These are pre-existing:

| File | Findings |
| --- | --- |
| `lib/menu.dart` | Missing widget key; private type in public API |
| `lib/util/custom_sprite_animation_widget.dart` | Prefer super parameter |
| `lib/util/functions.dart` | Constant naming |
| `lib/util/localization/my_localizations.dart` | Four unnecessary `this` qualifiers; one local-variable naming issue |
| `lib/widgets/custom_radio.dart` | Prefer super parameter |

`flutter test` passed all 21 tests in approximately 52 seconds, including dungeon geometry, Arka assets, progression, auto-aim, and the game widget checks. No failing tests were observed.

The existing widget test exercises keyboard walking/sprinting, directional animations, melee combos, stamina spending, and ranged projectiles in the loaded game. It does not establish a manual device pass, death/restart behavior, campaign travel, or save/load.

## Current runtime configuration

Values below are source observations, not performance measurements.

| Setting | Current value | Source |
| --- | --- | --- |
| World tile | 32 units | `lib/main.dart` |
| Sandbox map | `tiled/map.json`, 50 × 50 tiles | `lib/game.dart`, `assets/images/tiled/map.json` |
| Source map tile | 64 × 64 pixels; forced to 32 × 32 world units | Map JSON; `lib/game.dart` |
| Arka component | 48 × 48 world units (`spriteScale = 1.5`) | `lib/player/knight.dart` |
| Arka collision | 16 × 16, bottom centered in the component | `Knight.onLoad`, `lib/util/functions.dart` |
| Keyboard walk / sprint | 44.8 / 80 world units per second | `lib/player/knight.dart` |
| Controls | Joystick by default; keyboard arrows, Shift sprint, Space melee, Z ranged | `lib/game.dart`, `lib/player/knight.dart` |
| Camera | Speed 3; zoom calculated for 18 maximum visible tiles | `lib/game.dart` |
| Sprite cells | 384 × 320; locomotion crop 192 × 192 at offset (96, 64) | `lib/util/player_sprite_sheet.dart` |
| Animation step | Idle 0.10 s; walk 0.12 s; run 0.07 s; attacks 0.065 s | `lib/util/player_sprite_sheet.dart` |
| Restart | Game over navigates to a new `Game` | `lib/widgets/game_controller.dart` |

## Sandbox and identifier conventions

Preserve `assets/images/tiled/map.json` and its geometry fixtures as the development sandbox. P02 should register it as `dev_dungeon`; keep existing tests selecting this map explicitly when campaign startup changes. This is a registry decision for future implementation, not a renamed asset.

Use stable lowercase `snake_case` identifiers independent of display names. Keep the existing quest catalog IDs unchanged. References are validated within their owning namespace:

- Maps and regions: `dev_dungeon`, `kamboja`, `hutan_embun`, `akar_terlupakan`.
- Named map anchors: `(map_id, spawn_id)` and `(map_id, portal_id)`, such as `kamboja / village_gate`.
- NPCs, ingredients, and habitats: stable definition IDs such as `ratih`, `daun_embun`, and `hutan_embun_pack_01`.
- Monster lives: a fresh instance ID for every spawned life, distinct from habitat/group IDs. Persist claimed reward identities; never reuse a killed life's identity for a respawn.

## Device and profiling plan

`flutter devices` detected macOS desktop (macOS 15.7.9, darwin-x64) and Chrome web. Use macOS as the provisional local development/profiling target. Release platform coverage remains undecided; these results establish no mobile-device performance.

Repeatable profiling scene: open the existing sandbox, use keyboard controls, idle for 30 seconds, walk/sprint the same accessible route, fight the same nearby enemy group, and repeat after restart. Record hardware, viewport, build mode, route, and enemy count with each capture. Measure cold loading time, frame-time distribution, memory before/after repeated restarts, and active actor count using a profile build.

No loading, frame-time, memory, or actor-count measurements have been captured. Do not infer budgets from unit/widget-test duration.

## Remaining P00 verification

- [ ] Manually play movement, both attacks, XP gain, level-up, death, restart, and UI on the chosen target.
- [ ] Record the profiling route and actual device measurements.
- [ ] Confirm whether macOS is also a release target and identify the first representative mobile device if mobile release is intended.

P00 remains open until its runtime and profiling exit conditions are met. Shared session implementation is the next engineering work after the baseline gate.
