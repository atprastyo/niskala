# Arka interior detail pass

This pass adds restrained hair, scarf, trouser, and leather shading to the current smoothed classic Arka sprites. It preserves the accepted design and animation geometry instead of replacing sheets with generated character poses.

## Sources and method

- Pre-detail runtime backup: [art/arka-detail/base](art/arka-detail/base).
- Four edit targets: `art/arka-detail/<action>-reference.png`, eight columns and four directional rows, cropped to the central 192 × 192 body region.
- Four generated references: `art/arka-detail/<action>-detail.png`, generated with the built-in imagegen tool.
- Active exporter: [export_arka_details.m](../tools/export_arka_details.m).
- [Current preview](art/arka-detail/preview.png) and [running loop](art/arka-hd/run-preview.gif), right/left/up/down.

The exporter transfers local luminance variation into the existing material colors with at most ±30% brightness change. It samples only opaque interior pixels with opaque neighbors, leaving a two-pixel boundary untouched. Skin-colored and bright neutral regions are excluded to protect facial features, silver, and attack highlights. Generated transparency and poses are never used. All output alpha values are asserted equal to the saved base before PNG export. A per-frame 192 × 192 crop limits changes to the character body, preserving the outer attack canvas.

The generated atlases are shading references, not direct replacements. Small variation in their interpretations is constrained by the original color regions, alpha, and bounded transfer. Review the final runtime preview for visible flicker and readability.

## Rebuild

```sh
clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_details.m -o /tmp/export-arka-details
/tmp/export-arka-details
```

An optional output-root argument allows a staged export. The saved base makes repeated exports deterministic without layering detail repeatedly. Restart the game after replacing runtime images.

## Generation prompt

Each action uses the same prompt with `Action <action>.` prefixed. The built-in tool was given that action's reference PNG and requested a transparent background.

> Use case: precise-object-edit. Add a SMALL amount of interior detail to this existing RPG character sprite sheet, not a redesign. Exact 8 columns by 4 rows, same aspect ratio, transparent background. Rows face right, left, back, front. Preserve EVERY frame's exact pose, foot locations, silhouette, head size, facial proportions, body scale, original costume and position. Retain the simple compact smoothed pixel-art style. Add restrained hair strand highlights within brown hair clumps, a few red scarf folds, cream fabric shading, fine leather seams and soft boot highlights. Keep the original flat color regions recognizable, dark brown hair, brick red scarf, charcoal pants, brown leather, silver sword. No new accessories, no armor redesign, no new outline, no ground shadows, no extra detail outside existing shapes. Do not alter movement or reimagine feet. Keep sword slash effects identical. Treat input as fixed animation geometry; change only subtle interior surface shading. No labels or grid. Consistent details and lighting between adjacent frames.
