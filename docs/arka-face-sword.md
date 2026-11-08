# Arka face and sword detail

This pass builds on the accepted smoothed classic design and interior material detailing. It adds face shading and small facial accents, plus steel bevel contrast and nearby hilt hardware shading, without replacing the animation geometry.

## Sources and application

- Pre-pass sheets: [art/arka-face-sword/base](art/arka-face-sword/base).
- Edit targets: `art/arka-face-sword/<action>-reference.png`.
- Selected built-in imagegen references: `art/arka-face-sword/<action>-detail.png`.
- Exporter: [export_arka_face_sword.m](../tools/export_arka_face_sword.m).
- [Final preview](art/arka-face-sword/preview.png) and [running loop](art/arka-hd/run-preview.gif).

The final exporter keeps the base alpha mask exactly. It locates the face from the existing blue eye pixels and applies a bounded color blend only to face-colored pixels in that area; the back-facing row never receives a face. Elongated silver components receive restrained brightness contrast while keeping the existing silver palette. Small warm hardware regions beside those components can receive hilt shading. Broad components associated with attack arcs are excluded. Effects joined to the blade can prevent blade detailing in those frames, preserving the original effect instead.

The two-dimensional crop is the same 192 × 192 body region used by the earlier detail pass. Weapon portions outside this region are unchanged. Character positions, feet, clothing, frame count, playback timing, world size, and collisions are unaffected. The generated references are not direct replacement sheets.

## Export

```sh
clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_face_sword.m -o /tmp/export-arka-face-sword
/tmp/export-arka-face-sword
```

The saved base makes repeated exports non-cumulative. An optional output-root argument supports staged review. This is the final pass after the classic and general detail exports. Restart the game to refresh replaced PNGs.

## Prompt

Each action uses the same prompt prefixed by `Action <action>.`, with its corresponding reference PNG and a transparent-background request to the built-in imagegen tool.

> Use case: precise-object-edit. Edit this existing sprite atlas only to detail FACE and SWORD. Same exact 8 columns x 4 rows, transparent background, row directions right left back front. Preserve every pose, silhouette, character scale, original frame location, foot movement, costume, hair and scarf. Keep existing compact smoothed cartoon style and palette. Face: add readable blue irises and tiny pupils, eyelids and eyebrows, a subtle nose and small mouth, warm cheek shading, keeping original head shape and eye position. Sword: add restrained steel blade bevel and central ridge, silver edge glint, dark brown leather grip wraps and a modest brass guard/pommel, staying strictly inside the existing weapon silhouette. Sword stays on back in idle, moves exactly as reference in run/attacks. Keep all original attack arcs and effects as-is. Back view must remain back view, never add a face to back of head. No new accessories, no new weapons, no armor redesign, no changes to animation, no labels grid or shadows. Detailed surfaces only; not a character redesign. Keep all frames registered to input.
