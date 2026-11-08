# Arka player sprites

The active player uses `assets/images/player/arka/`. All 16 sheets preserve the complete original Arka pixel-art design, poses, frame order, and placement. The palette, image resolution, edge treatment, and restrained interior shading change. The earlier generated redesigns are retained as historical experiments and are not the runtime source.

## Layout and playback

Each strip is 3072 × 320: eight 384 × 320 frames, enlarged exactly 4× from the original 768 × 80 strip. Two Scale2x passes enlarge the source 4× while rounding supported diagonal corners. A small 3 × 3 premultiplied-RGBA filter then antialiases only transparency boundaries; interior color clusters remain sharp. This softens the block outlines without inventing new character details.

| Action | Filename | Frame duration |
| --- | --- | --- |
| Idle | `idle/idle_<direction>.png` | 0.10 seconds |
| Run | `run/run_<direction>.png` | 0.07 seconds |
| Walk | Reuses run | 0.12 seconds |
| Attack 1 | `attack_1/attack1_<direction>.png` | 0.065 seconds |
| Attack 2 | `attack_2/attack2_<direction>.png` | 0.065 seconds |

Every action has right, left, up, and down sheets. Movement samples a 192 × 192 crop at (96, 64); attacks sample the complete source cell. Original coordinates are multiplied by four with no pose recentering. Edge coverage may change locally by a few output pixels due to contour smoothing. World size, hitbox, controls, combat timing, and combo behavior remain unchanged.

## Palette and reproducible export

The [design guideline](design-guidelines.md) specifies warm brown hair/leather, brick-red cloth, charcoal trousers, and cream clothing. The exporter uses exact color substitutions consistently across every sheet while preserving skin tones, silver sword colors, slash highlights, and source transparency before edge smoothing. Unmapped source colors are unchanged; edge antialiasing introduces blended colors and partial alpha.

Source: [original Arka sheets](art/arka-originals). Active exporter: [export_arka_classic.m](../tools/export_arka_classic.m). The older generated-atlas and foot-redraw exporters are historical and should not be used to rebuild the current sprites.

```sh
clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_classic.m -o /tmp/export-arka-classic
/tmp/export-arka-classic
```

An optional output-root argument supports a staged export. The exporter also refreshes the [run preview](art/arka-hd/run-preview.gif), showing right, left, up, and down at the runtime run cadence. Restart the game after changing PNGs to refresh cached images.

## Current interior detailing

The runtime sheets add small brightness variations from generated material-detail references onto the smoothed classic design. Their transparency mask and frame placement are identical to the pre-detail version; no generated silhouette or foot motion is used. This general material pass leaves skin, face, bright sword effects, and contour padding untouched. The later face/sword pass below refines those selected surface regions.

After rebuilding the classic sheets, apply the current detail pass:

```sh
clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_details.m -o /tmp/export-arka-details
/tmp/export-arka-details
```

This exporter reads the saved pre-detail sheets in `docs/art/arka-detail/base` and is repeatable without compounding texture. See [detail sources, prompt and preview](arka-detail-pass.md).

## Face and sword refinement

The final pass adds face shading and facial accents within the original face, steel bevel contrast, and nearby hilt shading. The saved pre-pass base keeps this repeatable. Use `tools/export_arka_face_sword.m` after the general detail exporter. See [face/sword sources and export instructions](arka-face-sword.md). The final transparency mask and original foot motion remain unchanged.

## Final bold contour

The latest pass keeps the crisp warm-charcoal character outline. The straight-blade replacement was reverted at the user's request; sword artwork now comes from the saved pre-straightening sheets, including the earlier face/sword surface detail. Poses and animation timing remain unchanged. See [outline export](arka-outline.md).

## Current black-to-brown hair

The final color pass changes only connected head-hair material to a near-black base with brown highlights, retaining the accepted shading detail. It reads the pre-hair backup and original hair material mask; all alpha values and frame coordinates remain unchanged. Build and run `tools/export_arka_hair.m` after the outline pass. See [hair palette, sources and export](arka-hair.md).

## Current side-part hairstyle and blue outfit

The final pass applies side-part hair detail registered to each original head mask and tilt, with a blue outer garment, closed blue center panel, navy trousers, and rust-colored neck scarf/wristbands. Alpha and frame positions stay identical to the pre-pass sheets. The accepted sword is retained. This supersedes the earlier red/cream clothing palette. See [current outfit sources and export](arka-outfit.md). Build and run `tools/export_arka_outfit.m` last.

The white center-panel experiment was reverted: the garment is closed blue across the center in every frame. The generated style reference may still show the earlier white panel; the runtime exporter does not apply it.

Pose-specific corrections ensure raised shoulders stay blue and bracers use reddish-brown in both side attack actions, and the idle-up wristbands and scarf use reddish-brown. The exporter excludes wide attack trails from these cloth corrections.

Attack palette: bracers in both left/right attack sets and the scarf in both up-facing attack sets use reddish-brown, matching the established scarf/wristband palette. Shoulder cloth remains blue.

**Current bracer decision:** bracers/wristbands are white with subtle cool-gray shading across all animations. This supersedes earlier red/blue bracer experiments. The neck scarf stays reddish-brown; the outer garment stays blue.

## Accepted design snapshot

The current design was accepted on 2026-11-08. [Saved baseline, restoration instructions, and checksums](art/arka-approved-2026-11-08/README.md). This snapshot is the reference for subsequent art changes; historical generation experiments are not the accepted baseline.
