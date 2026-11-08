# Arka black-to-brown hair

The active hair palette uses near-black `#121113` in the shadows and warm brown `#5B3925` in the brightest existing highlights. Intermediate shades follow the pre-existing hair shading using a nonlinear mapping of the existing warm highlight brightness, preserving texture rather than flattening the hair to one color.

The original small Arka sheets identify the connected top-of-head hair material in each frame. The exporter applies this mask to the saved current artwork, with a one-output-pixel allowance for smoothed edges and warm-material checks to avoid skin and leather. The dark external contour stays intact. It writes only RGB values, preserving alpha, frame coordinates, foot movement, and the accepted pre-straightening sword artwork.

- Pre-pass backup: [art/arka-hair/base](art/arka-hair/base).
- Exporter: [export_arka_hair.m](../tools/export_arka_hair.m).
- [Preview](art/arka-hair/preview.png) and [running loop](art/arka-hd/run-preview.gif).

```sh
clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_hair.m -o /tmp/export-arka-hair
/tmp/export-arka-hair
```

An optional output-root argument supports staged exports. This is the final color pass after outlining. Repeated runs read the fixed pre-pass backup and do not darken the hair repeatedly. No image generation or pose reconstruction is used for this recolor. Restart the game after replacing PNGs.

For additional HD detail, preserve these motion frames and work within material masks. More source pixels alone cannot supply newly authored facial or material detail; inspect close-ups and the animation loop at actual gameplay size when judging further refinements.
