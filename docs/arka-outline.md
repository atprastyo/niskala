> **Current decision:** the straight-blade replacement below was rejected and reverted. The active exporter now reads the pre-straightening backup and applies only the character contour. The generated blade remains a historical experiment and is not loaded or composited.

# Arka bold outline

The final artwork pass adds a warm-charcoal contour roughly two source pixels wide around the character, with a narrow antialiased edge. The existing face, hair, costume, and foot poses remain in place. The source cells remain 384 × 320 and the strips remain 3072 × 320.

The outline uses `#291F1E` and stays inside the movement crop. Bright neutral effects are excluded from contour expansion. This deliberately changes local alpha coverage at the character edge; the previous face/material passes' exact-alpha guarantee applies before this final pass.

## Straight blade experiment (reverted)

A single [straight silver blade](art/arka-outline/straight-blade.png) was generated using the built-in imagegen tool. Its edges and central ridge are straight; only the tip tapers. The exporter fits this same artwork to the axis, length, width, and location of exposed elongated silver blade regions in the saved sprites. At most one blade is replaced per frame. Facial highlights, small cuffs, and broad slash effects are excluded. Attack frames 1–3 retain their original effect-heavy artwork; the curved slash trails are motion effects, not the physical blade.

The old exposed silver component is removed before compositing the registered blade. Where it overlapped character material, a small local neighboring-material recovery avoids transparent holes. The existing hilt and hand positions are retained. Inspect [idle](art/arka-outline/idle-reference.png), [run](art/arka-outline/run-reference.png), [attack 1](art/arka-outline/attack_1-reference.png), and [attack 2](art/arka-outline/attack_2-reference.png) contact sheets when refining this selection.

## Rebuild and preview

- Saved pre-pass sprites: [art/arka-outline/base](art/arka-outline/base).
- Final exporter: [export_arka_outline.m](../tools/export_arka_outline.m).
- [Current preview](art/arka-outline/preview.png) and [running loop](art/arka-hd/run-preview.gif).

```sh
clang -framework Foundation -framework AppKit -framework ImageIO tools/export_arka_outline.m -o /tmp/export-arka-outline
/tmp/export-arka-outline
```

An optional output-root argument supports staged exports. This is the final pass after face/sword detailing. Repeated exports read the fixed base and do not compound the outline. Restart the game to refresh replaced PNGs.

## Built-in generation prompt

> Create one isolated straight silver sword BLADE ONLY as a transparent game sprite component matching the simple compact cartoon materials of the provided character. No character, no hilt, no guard, no grip, no text. Long vertical blade centered, pointed tip at TOP, flat blade root at BOTTOM. Perfectly straight parallel cutting edges tapering ONLY in the final short triangular tip, perfectly straight central ridge, absolutely no bends, curves, waviness or asymmetric bulges. Blade proportions width:length about 1:8. Simple silver steel with cool gray bevel face, bright silver edge and thin dark charcoal crisp outline. Minimal 2-3 tone shading, no photorealistic texture, no glow or ground shadow. Large clear transparent padding. Must be upright and symmetric. This is a replacement blade material for the existing sprite, not a new weapon design.
