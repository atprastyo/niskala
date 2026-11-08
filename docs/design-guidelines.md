# Niskala character design guideline

**Accepted design — 2026-11-08:** the current Arka appearance is saved in [the approved snapshot](art/arka-approved-2026-11-08/README.md), including all 16 sheets and a hash manifest. Use this snapshot as the baseline for future changes. Bracers are white; the neck scarf is reddish-brown.

## Active hero: Arka

The active player artwork is under `assets/images/player/arka/`. Use the original Arka pixel-art design and animation geometry, recolored to the game's warm, earthy palette. Keep a youthful male adventurer with short layered side-part hair with a swept fringe, a near-black base, and warm brown highlights, expressive blue eyes, a slate-blue outer garment, closed blue center section, reddish-brown neck scarf, white bracers/wristbands, brown leather belt, dark navy trousers, brown boots, and a compact silver sword.

Preserve the original pixel-art rendering, proportions, silhouettes, and shading clusters. Upgrade the palette and output resolution with two Scale2x passes and light transparency-edge antialiasing. Keep internal details sharp. Restrained generated surface shading may be transferred inside the existing shapes, but the final alpha mask, original poses, and broad sword effects must remain unchanged. Face and blade surfaces may receive the targeted refinement described below. Do not replace body parts or introduce new animation poses. Do not add a ponytail, helmet, oversized weapon, or a new costume.

## Palette

| Material | Base color |
| --- | --- |
| Hair | Near-black base `#121113`, grading into warm brown highlights `#5B3925` |
| Neck scarf | Reddish brown `#914B3C` |
| Bracers / wristbands | White `#F5F6F8`, cool-gray shadows |
| Outer garment | Slate blue, approximately `#496487` |
| Center garment panel | Blue, matching the outer garment |
| Leather belt and boots | Brown `#704831` |
| Trousers | Dark navy `#1D2947` |
| Sword | Neutral silver with pale cream-white slash accents |

Derive warm shadows and restrained highlights from these anchors; they are material base colors, not a requirement that every rendered pixel be one of six flat colors. Keep the scarf more saturated than the clothing and terrain. Preserve neutral sword highlights so strike effects remain distinct from cloth.

## Camera, light, and silhouette

Keep a consistent slightly elevated orthographic view in every action. Light materials softly from the upper left. The front-facing sheet shows the face; the up-facing sheet shows the back of the head and torso. Use dedicated left-facing art rather than flipping all right-facing poses at runtime.

Keep hair short, the scarf compact, and the sword inside the allocated attack canvas. No baked ground shadow, colored halo, smoke behind the body, scenery, paper, grid, or labels. Export actual RGBA transparency and inspect it on both light and dark backgrounds.

## Animation and HD contract

- Actions: idle, run, attack 1, and attack 2, each with right, left, up, and down views.
- Eight frames per sheet, preserving the original action phases and directional meanings.
- HD source cells: 384 × 320 pixels, four times the original 96 × 80 resolution. Each horizontal strip is 3072 × 320.
- Locomotion uses a central 192 × 192 crop at offset (96, 64). Attack playback keeps the full 384 × 320 cell, including the sword arcs.
- Multiply every original source coordinate by exactly four. Preserve frame-specific offsets and foot placement; allow only local contour smoothing and partial-alpha coverage at the outline; do not normalize or recenter poses.
- Retain the complete original body in every frame, including the original run leg/boot motion. Apply the same palette substitutions to all actions and directions. Inspect the looping animation as well as individual still frames.
- Idle uses subtle breathing; run uses a coherent alternating gait. Walking reuses the run poses at a slower cadence because a distinct walk asset is not included in this update.
- Attack 1 and attack 2 remain separate eight-frame actions with their existing input/queue behavior. Make the strike readable at the early active frames, then recover. Do not redesign combat timing merely to fit new artwork.
- Keep the current world-space player size, foot hitbox, movement speed, attack canvas ratios, and gameplay behavior. Increasing source resolution does not imply enlarging the character in the game.

## Review

Check all 16 sheets for the same character, costume, palette, and body proportions. Review strips and animation loops for alternating feet, stable scale, foot placement, complete sword arcs, clean transparency, and matching up/down views. Verify source dimensions and the locomotion crop before playing the game.

The previous small Arka sheets are retained in [art/arka-originals](art/arka-originals). The old knight and male_hero sheets are legacy assets and should not determine Arka's current frame count or dimensions. See [player-sprites.md](player-sprites.md) for loading and export details.

For environment materials, see [dungeon-design-guidelines.md](dungeon-design-guidelines.md). Story and implementation planning are indexed in [README.md](README.md).

## Interior detail pass

Use subtle hair highlights, scarf folds, trouser shading, and leather surface variation. Apply these as bounded brightness detail within the current material colors, rather than replacing the entire generated character. The general material pass keeps the outermost two-pixel region, transparency, facial features, skin, silver highlights, and attack effects intact; face and sword edits belong in the separate targeted pass below. All 16 sheets should receive the same treatment. See [Arka detail pass](arka-detail-pass.md) for sources and export instructions.

## Face and weapon detail

Allow restrained eye, nose, mouth, and cheek definition inside the original face region, keeping blue eye placement and head proportions. Back-facing frames show no face. Use neutral silver bevel contrast on existing blade shapes and modest warm hilt accents. Preserve the alpha mask and broad slash effects. See [face/sword refinement](arka-face-sword.md).

## Final outline and blade shape

Use a roughly two-source-pixel warm-charcoal `#291F1E` outline with a narrow antialiased edge for a bold, sharp character silhouette. Preserve facial detail, original poses, and frame positions. Preserve the accepted pre-straightening sword artwork. Do not replace, reorient, or reconstruct its geometry; the attempted straight-blade replacement was reverted. Preserve curved attack trails as separate motion effects. The final contour pass may change local character-edge alpha coverage; it does not reconstruct the blade. See [outline specification and export](arka-outline.md).

## Motion-preserving HD refinement

The current hair pass maps existing hair shading into a near-black-to-brown gradient. It uses the connected original hair material as a mask, leaves every alpha value unchanged, and retains frame coordinates, face, clothes, and the accepted sword. See [hair export](arka-hair.md).

For further HD detail, keep the accepted silhouette and per-frame pose registration as fixed artwork. Refine small interior material layers (hair strands, eyes, fabric folds, leather seams) inside those masks, review representative front/side/back and attack frames, then carry the same material treatment through all frames. Do not regenerate whole poses or infer a new gait. Raising PNG dimensions alone adds no authored detail. Compare looping previews before accepting further passes.

## Current hairstyle and outfit

The active final pass uses a short layered side-part hairstyle inside the accepted head envelope, a blue outer garment with a closed blue center panel, dark navy trousers, and reddish-brown neck scarf and wristbands. A generated four-view style reference supplies the new hair parting; each original head mask, bounds, and modest tilt guide registration across the animation. The existing alpha mask, face, foot motion, and accepted sword geometry remain fixed. See [outfit and hairstyle export](arka-outfit.md). Earlier red/cream garment references are historical.

The white center-panel experiment was reverted: the garment is closed blue across the center in every frame. The generated style reference may still show the earlier white panel; the runtime exporter does not apply it.

Check pose-dependent palette coverage: both left/right attack sets need blue shoulders and reddish-brown bracers even when arms rise above the torso; idle-up must show reddish-brown wristbands and scarf beside the silver sword. Keep large slash effects neutral.

Attack palette: bracers in both left/right attack sets and the scarf in both up-facing attack sets use reddish-brown, matching the established scarf/wristband palette. Shoulder cloth remains blue.

**Current bracer decision:** bracers/wristbands are white with subtle cool-gray shading across all animations. This supersedes earlier red/blue bracer experiments. The neck scarf stays reddish-brown; the outer garment stays blue.
