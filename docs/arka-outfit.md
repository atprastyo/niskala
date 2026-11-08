# Arka side-part hairstyle and blue outfit

The active appearance uses short layered side-part hair with a swept fringe, retaining the near-black base and brown highlights. Clothing changes to a slate-blue outer garment, closed blue center panel, dark navy trousers, and reddish-brown wristbands and neck scarf. Brown boots and belt remain.

## Sources and motion

- Pre-pass sheets: [art/arka-outfit/base](art/arka-outfit/base).
- Built-in imagegen edit target: [style-reference.png](art/arka-outfit/style-reference.png).
- Generated four-view reference: [style-design.png](art/arka-outfit/style-design.png), right/left/back/front in a 2 × 2 grid.
- Final exporter: [export_arka_outfit.m](../tools/export_arka_outfit.m).
- [Final running preview](art/arka-outfit/preview.png) and [animation loop](art/arka-hd/run-preview.gif).

The generated full-body reference is not used as a replacement animation. Hair detail is sampled into each original connected hair mask, fitting the original head bounds and adjusting its local parting for the original head tilt. It retains the compact head silhouette rather than introducing a larger head or new hair envelope. Clothing changes are material/region color mappings on the saved sprites, with the former white center panel covered by matching blue coat material. Neutral neck and small cuff regions become rust; the sword and large attack effects are excluded from those material selections.

All output alpha values are asserted identical to the saved pre-pass sheets. No frames are added, removed, reordered or recentered, and gameplay size, movement, collisions and animation timing remain unchanged. Existing face detail and the accepted pre-straightening sword geometry remain in place.

## Export

```sh
clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_outfit.m -o /tmp/export-arka-outfit
/tmp/export-arka-outfit
```

Run this final appearance pass after the hair/outline stages. An optional output-root argument supports staged review; fixed saved inputs make reruns non-cumulative. Restart the game after PNG changes to refresh cached textures.

## Built-in edit prompt

> Precise character edit, transparent 2x2 sprite reference, preserve exact same four views and composition: top-left right-facing, top-right left-facing, bottom-left BACK, bottom-right FRONT. Keep character pose, head angle, facial features, proportions, sword and hand placement. Change hairstyle to neat short layered SIDE-PART with a distinct swept fringe, subtle tapered sides, black base with warm brown gradient highlights. No ponytail, no long hair, no spiky exaggerated silhouette. Keep hair within the same compact head envelope. Change outer tunic/coat to muted denim/slate BLUE, visible central inner garment to WHITE. Change trousers to very dark NAVY blue. Change existing WHITE WRISTBANDS and WHITE NECK SCARF/collar to reddish brown (rust #914B3C); keep face and sword silver unchanged, keep boots brown. Maintain the existing compact smooth cartoon sprite style and bold dark outlines. No redesign of weapon or animation, no added accessories, no ground shadows, no labels or grid. Prioritize a clear consistent side-part hairstyle from all views and the specified colors.

The white center-panel experiment was reverted: the garment is closed blue across the center in every frame. The generated style reference may still show the earlier white panel; the runtime exporter does not apply it.

## Pose-specific palette corrections

Both attack actions include explicit left/right corrections for raised blue shoulder cloth and reddish-brown bracer surfaces. Original cloth colors identify missed shoulder pixels above the usual torso region. Small guards and neutral regions on the forearm side of the original hand receive the reddish-brown bracer palette; broad effect frames are excluded from proximity-based selection to avoid coloring slash trails.

Idle-up uses head-relative collar and wrist regions to apply reddish-brown to remaining neutral cloth. The left wrist region stops before the diagonal sword edge. Every export still asserts identical alpha masks. Review the current [idle](art/arka-outfit/idle-current.png), [attack 1](art/arka-outfit/attack_1-current.png), and [attack 2](art/arka-outfit/attack_2-current.png) contact sheets when adjusting these regions.

Attack palette: bracers in both left/right attack sets and the scarf in both up-facing attack sets use reddish-brown, matching the established scarf/wristband palette. Shoulder cloth remains blue.

**Current bracer decision:** bracers/wristbands are white with subtle cool-gray shading across all animations. This supersedes earlier red/blue bracer experiments. The neck scarf stays reddish-brown; the outer garment stays blue.
