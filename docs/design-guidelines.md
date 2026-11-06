See [dungeon-design-guidelines.md](dungeon-design-guidelines.md) for dungeon materials, palette, lighting, and tile compatibility.

# Active player asset set: Arka

The active player now uses the supplied assets in `assets/images/player/arka/`. Preserve this artwork as supplied. Use its dedicated four-direction idle, run, and two attack sheets. Each source cell is 96 × 80 pixels with eight frames per strip. Walking uses the run poses at a slower cadence. Movement crops the central 48 × 48 region; attacks retain the full cell to preserve sword arcs. Keep the enlarged player size and foot collision anchor.

See [player-sprites.md](player-sprites.md) for the current asset layout and timing. The male_hero design and generation specifications below describe the previous asset set and apply only to that legacy artwork.

---

# Niskala character design guideline

## Visual direction

Use a painterly cartoon action RPG style with expressive heads, compact heroic bodies, crisp silhouettes, and warm earthy colors. Preserve the supplied `male_hero` identity and movement references: short tousled brown hair, visible face, scarf, tunic, leather gear, dark trousers, boots, and a compact silver sword. The earlier ponytail knight is a legacy design.

## Player palette

| Material | Base color |
| --- | --- |
| Hair | Dark brown `#493426` |
| Scarf and cape | Brick red `#A54236` |
| Tunic | Cream `#E8D5AF` |
| Leather belt, bracers, boots | Brown `#704831` |
| Trousers | Charcoal `#302C32` |
| Sword | Silver with cream-white slash accents |

Use restrained highlights and warm shadows derived from these base colors. Replace the supplied purple scarf and cyan clothing with this palette in every action, including jump and fall assets. Avoid realistic armor, photographic texture, and decorative glow behind the character.

## Animation and export

- Idle, walk, and run have ten frames each. Walking uses shorter steps and gentle scarf sway; running uses a wider alternating stride and stronger cloth motion. Use the supplied `male_hero` motion sheets as references.
- Supply right, up, and down views for idle, walk, run, combo strike, and combo recovery. Mirror the right view for left-facing playback. Up shows the back of the head and torso; down shows the face.
- Use 256 × 256 transparent frames for locomotion and airborne assets. Idle steps last 0.1 seconds, walk 0.12 seconds, and run 0.07 seconds.
- The melee combo has three strike frames at 0.08 seconds each followed by four recovery frames at 0.09 seconds each. Use 512 × 512 attack canvases with room for the sword arc. Render at twice the locomotion canvas size, offset to align the character's feet and body; do not double the actual body size.
- Use one horizontal PNG strip per action and direction. Keep full bodies, hair, cloth, sword, and slash inside their cells. Keep character scale and foot alignment consistent between actions.
- Export genuine RGBA transparency. Exclude backgrounds, paper grids, ground shadows, gradients, and glow behind the hero.
- Display the player in a square area 2.5 times the tile size (80 × 80 at the default 32-pixel tile size). Its collision box remains half a tile square, centered at the feet, to preserve navigation through narrow dungeon passages.

## Playback and controls

Keyboard arrows walk; hold either Shift key to run. A light joystick push walks and a strong push runs. Space or the melee button plays the directional strike and recovery, applies damage on the slash frame, and prevents restarting or moving during recovery. Z or the ranged button fires after the combo finishes.

Jump and fall artwork is included and preloaded for future movement mechanics; the current top-down controller does not add jumping or falling controls.

## Review

Check all directions for consistent identity and palette, inspect cell boundaries and transparency, compare body size between movement and attack, and check complete loops in game. Preserve the original source sheets for reference.

See [player-sprites.md](player-sprites.md) for assets, generation prompts, and export instructions.
