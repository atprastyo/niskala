# Niskala dungeon design guideline

## Art direction

Use believable, weathered materials within the existing orthographic dungeon layout: chipped masonry, worn stone paving, aged timber, and dark iron. Favor clear hand-painted forms and restrained surface detail that survives the game's small tile size. The environment can have more realistic materials than Arka while sharing the same warm, earthy color family.

Preserve readable wall silhouettes and traversable floor space. Reserve the strongest contrast and saturated accents for the player, enemies, pickups, and active effects.

## Palette

| Role | Base color | Application |
| --- | --- | --- |
| Charcoal | `#302C32` | Deep masonry, recesses, iron, mortar |
| Dark umber | `#493426` | Warm stone shadows and wood end grain |
| Earth brown | `#704831` | Timber, weathered stone, subdued floor variation |
| Muted cream | `#E8D5AF` | Small worn edges and restrained sandstone highlights |
| Brick red | `#A54236` | Sparse existing prop or architectural accents |

Derive intermediate taupe, warm gray, and brown values from these anchors. Do not use the cream as the overall floor brightness or the red as a dominant wall color. Keep most surfaces low in saturation so Arka's red scarf remains distinct. Avoid the previous atlas's cool blue masonry bias.

## Materials

- Walls: irregular but structurally aligned masonry, subtle mortar, worn bevels, and occasional small chips. Shade recesses more strongly than the floor.
- Floors: quieter stone or earth paving, with restrained cracks and wear. Provide variation without creating false obstacle silhouettes. Avoid a strong repeated central crack or highlight that becomes a visible grid when tiled.
- Wood: warm brown grain on existing doors, chests, barrels, and trim; keep plank direction consistent within an object.
- Metal: charcoal iron with small neutral highlights. Preserve handles and fittings that make props recognizable at gameplay scale.
- Openings: maintain genuinely transparent empty regions and dark, readable recesses. Do not fill doorways or windows with decorative material.

## Camera and lighting

Keep the existing top-down orthographic camera and the original wall height conventions. Use a soft upper-left material light, with restrained shading inside the tile silhouette. Avoid perspective photography, dramatic directional shadows across neighboring cells, or highlights that appear to move when a tile repeats.

Let the game's lighting system supply torch light and combat glow. Do not bake broad orange halos, bloom, or background illumination into the atlas. Inspect materials under the actual dark game lighting as well as at full brightness.

## Atlas compatibility

The active asset is `assets/images/tiled/tile_set.png`. Its contract is fixed:

- Image: 448 × 448 pixels, genuine PNG alpha.
- Grid: seven columns and seven rows, 49 tiles total.
- Source tile: 64 × 64 pixels, zero spacing and zero margin.
- Tile IDs: preserve every existing row-major index, including empty or partially transparent cells.
- Geometry: retain wall corners, cap heights, doorway and window openings, prop footprints, and all tile connection boundaries.
- Metadata: `tileSet.json` and `map.json` use 64-pixel source tiles. Pixel-space object and collision coordinates are four times their original 16-pixel values; tile IDs and layer cell counts remain unchanged. The game retains 32-pixel world tiles through `forceTileSize`.

Export from the saved high-resolution source artwork to 448 × 448; do not enlarge the old 112-pixel runtime PNG. The 64-pixel source tiles retain material detail while the game renders each tile at its existing 32-pixel world size. Any future tile-resolution change must migrate source tile dimensions, map pixel coordinates, and collision coordinates together.

## Review before use

Inspect the atlas enlarged and at native scale. Assemble the actual map and check that wall runs and corners connect, floor repetitions remain quiet, openings stay open, and props remain recognizable. Check the player against floors and walls under game lighting. Verify image dimensions, tile IDs, transparency, and successful map loading.

The original atlas is retained at `docs/art/dungeon/tile_set-original.png`. Generation details and the selected source artwork are recorded in [dungeon-tileset.md](dungeon-tileset.md).
