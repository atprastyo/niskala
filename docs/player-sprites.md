# Arka player sprites

The active player uses the supplied PNGs under `assets/images/player/arka/`. The artwork is loaded directly and is not regenerated or recolored. The older knight and male_hero sheets are retained as legacy assets.

Each sheet contains eight 96 × 80 frames in a horizontal 768 × 80 strip. Dedicated right, left, up, and down sheets are available for every action:

- `idle/idle_<direction>.png`: idle, 0.10 seconds per frame.
- `run/run_<direction>.png`: run, 0.07 seconds per frame. Walking reuses these poses at 0.12 seconds per frame because Arka has no separate walk sheet.
- `attack_1/attack1_<direction>.png` and `attack_2/attack2_<direction>.png`: played sequentially as the melee combo, 0.065 seconds per frame.

Movement samples the central 48 × 48 area at offset (24, 16) within each source cell to preserve the player's enlarged visible size. Attacks retain the full 96 × 80 cell and render with the corresponding scale and offset so the sword arcs fit and the body remains aligned. The source PNGs remain unchanged.

The player's display area remains 2.5 tiles square with a half-tile foot collision box. Arrows walk, Shift runs, and joystick intensity selects the gait. Space or the melee button plays the combo; Z or the ranged button fires after recovery. Dedicated left-facing artwork is used without mirroring.

All four Arka asset directories are registered in `pubspec.yaml`. The previous male_hero export tool and generation notes are retained for historical reference and are not used for Arka.
