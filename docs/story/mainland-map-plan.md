# Mainland map plan — Forest-and-mountain island

Status: geographic design draft, not an implemented map. The established setting is one large island with extensive forests, many mountains, multiple lakes, a large bay, and ocean around its coastline. Names, orientation, anchor coordinates, distances, and technical budgets below are proposals.

Working island name: **Pulau Niskala**. Working bay name: **Teluk Teduh**, the Sheltered Bay. Neither name is required for the story to work.

This document places the existing three settlements, seven dungeon regions, and quest routes on a shared island. It adds geography, not another dungeon, settlement, medicinal ingredient, or required quest. See [quest-flow.md](quest-flow.md) for the authoritative 12 main quests and 11 side quests.

## 1. Island identity

The island should feel like a continuous place whose terrain explains its settlements and routes. A northern mountain backbone feeds rivers, forested valleys, freshwater lakes, and southeastern wetlands. The large bay cuts into the southern coastline and opens directly into the surrounding ocean.

Forests occupy much of the lower and middle elevations, including wooded mountain slopes. Mountains form several ridges and peaks rather than one isolated end-game cone. Use inhabited clearings, paths, farms, lake margins, rocky slopes, and sheltered passes to give the player room to navigate.

The island is fully surrounded by ocean. The bay is part of that ocean, not an inland lake. Interior freshwater lakes remain visually and geographically distinct from its tidal shoreline.

### Proposed geography at a glance

| Area | Proposed character | Purpose |
| --- | --- | --- |
| Northern backbone | Several high peaks, cold ridges, narrow saddles, and the highest summit | Late-game ascent and a visible long-term destination |
| Central highlands | Forested ravines, rocky foothills, terraces, and an elevated lake basin | Mid-game traversal and varied sightlines |
| Southwest lowlands | Freshwater lake, fields, gentle forest, and sheltered coastal slopes | Kamboja, opening encounters, and the first dungeon |
| Southeast lowlands | River channels, marshes, raised paths, and fishing platforms | Tirta and dungeon 2 |
| Southern bay | Broad saltwater inlet with beaches, coves, headlands, and distant cliffs | A memorable island landmark and orientation aid |
| Outer coast | A mix of forested headlands, rock cliffs, and selected accessible beaches | Establish the island boundary without requiring a walkable route around every shore |

## 2. Geographic sketch

North is at the top. This is a schematic landform sketch, not a tile layout or a scale-accurate minimap. The anchor table below is the reference for approximate positions.

```text
                              OUTER OCEAN
                  __________________________________
              ___/       NORTHERN MOUNTAIN RANGE     \___
            _/                SUMMIT / D7                \_
           /        RIDGES / D6          HIGH PEAKS         \
          /   DANAU SENJA / D5              DANAU CERMIN     \
         |       forest    RAVINES / D4      FOOTHILLS / D3  |
         |                       WANA SELA                   |
         |  HUTAN EMBUN / D1     river valley                 |
         |  DANAU BENING                      RAWA BISU / D2 |
          \       KAMBOJA                    TIRTA           /
           \__   west shore     _______      east shore  __/
              \             ___/       \___            /
               \___________/   TELUK TEDUH  \__________/
                              LARGE BAY
                           OPEN TO THE SOUTH
                              OUTER OCEAN
```

`D1` through `D7` indicate mainland entrances to separate dungeon maps. Interior dungeon rooms are not physically laid out across the surface island. The marsh portal's small islet lies within wetland channels; it does not imply another major offshore island.

## 3. Settlements and story-region anchors

Use normalized coordinates during planning: `(0, 0)` is the northwest corner of the world planning rectangle; X increases eastward and Y increases southward. Values are percentages, not tile positions. Not every coordinate inside this rectangle is land.

| Place | Approximate anchor | Geographic placement | Story role |
| --- | --- | --- | --- |
| **Kamboja Village** | `(24, 76)` | Southwest lowland, inland from the bay's western shore | Home, permission, departure, final cure |
| **Hutan Embun / D1** | `(32, 60)` | Forest north and northeast of Kamboja | Levels 1–12; Akar Terlupakan |
| **Desa Tirta** | `(69, 73)` | Low ground near freshwater channels reaching the bay's eastern shore | Wetland rest and quest hub |
| **Rawa Bisu / D2** | `(76, 64)` | Inland marsh northeast of Tirta | Levels 13–25; Sumur Rawa |
| **Lereng Bara / D3** | `(75, 45)` | Eastern rocky foothills with old quarry routes | Levels 26–40; Gua Bara |
| **Desa Wana Sela** | `(57, 48)` | Central foothill terrace west of the quarry approach | Midpoint farming, mining, and repair hub |
| **Jurang Angin / D4** | `(43, 41)` | Forested ravines west and northwest of Wana Sela | Levels 41–55; Menara Angin |
| **Danau Senja / D5** | `(29, 35)` | Elevated western lake basin below the northern ridge | Levels 56–70; Kuil Senja |
| **Punggung Kabut / D6** | `(41, 20)` | Northern ridge passes above the lake basin | Levels 71–85; Benteng Kabut |
| **Puncak Niskala / D7** | `(54, 12)` | Highest summit approach near the northern center | Ordinary monsters 86–99; Jantung Niskala and the level-100 boss |

The main route moves out from the southwest, around the bay's inland head toward the southeast, up the eastern foothills, west across the central highlands, then north into the mountains. It is a broad arc with local loops, not a straight staircase or a route that repeatedly crosses the entire island.

The bay occupies a broad southern inlet, approximately between X 36–66 in its central portion, widening toward the southern ocean. The mainland path between Kamboja and Tirta stays north of the inlet on dry land; the player does not need to cross open water.

## 4. Mountains, elevation, and forests

### Mountain structure

Use a main northern ridge with western and eastern spurs descending into the central highlands. Puncak Niskala is the tallest peak, but lesser summits should be visible throughout the journey. Their changing position on the horizon helps orient the player.

Lereng Bara is rocky foothill terrain, not an obligatory active volcanic biome. Its ember-themed dungeon can occupy a sealed mineral cavern without adding lava rivers to the entire island. Jurang Angin supplies deeply cut forest valleys; Wana Sela occupies a gentler terrace between the quarry road and ravine route.

Elevation is authored through connected paths, cliff edges, switchbacks, bridges, and passes. The current story does not assume free climbing or jumping. A visible summit is not necessarily reachable by walking straight at it.

### Forest distribution

- Lower forest: broadleaf woodland around Hutan Embun, with clear paths, farms, and gentler early encounters.
- Wetland forest: water-tolerant trees and reeds around Rawa Bisu, with raised trails and distinct channel edges.
- Highland forest: denser slopes and sheltered valleys around Wana Sela, Jurang Angin, and Danau Senja.
- Upper ridges: gradually thinner trees, exposed roots, shrubs, rock, and mist approaching Punggung Kabut. Snow or ice is an optional later art decision, not required by this plan.

Avoid filling all forest cells with solid trees. Use alternating dense stands, clearings, trail bends, overlooks, and landmark silhouettes. Essential pickups, attack telegraphs, and paths must remain readable under the canopy.

## 5. Lakes, rivers, bay, and ocean

### Three proposed freshwater lakes

| Lake | Approximate placement | Identity | Content role |
| --- | --- | --- | --- |
| **Danau Bening** | `(18, 67)`, southwest lowland | Small clear lake feeding village irrigation through a local stream | Early exploration and a view connecting farms to their water source; no new required quest |
| **Danau Senja** | `(29, 35)`, western highland basin | Largest inland lake, with wooded shores, rocky banks, and old ruins | Existing dungeon-5 region and `sq_exp_01`, A Marker at the Lake |
| **Danau Cermin** | `(80, 31)`, northeastern mountain basin | Remote reflective lake below eastern peaks | Optional scenic exploration and a possible journal landmark; no eighth dungeon or additional main quest |

Lake sizes and exact coastlines should follow the eventual terrain blockout. Danau Cermin is not a reason to force a long detour during the seven-ingredient quest.

### Drainage and river routes

Headwater streams descend from the northern and eastern mountain slopes. An outlet from Danau Senja follows a central valley downhill, bends southeast, and reaches the wetland channels near Tirta before entering the bay. Danau Cermin can have a separate stream reaching the eastern coast. Danau Bening supplies the southwest fields and has a smaller coastal outlet.

Draw riverbeds through low valleys rather than over ridgelines. Use waterfalls at clear elevation breaks. Freshwater becomes tidal or brackish close to the bay; Tirta's drinking-water point should draw from an upstream freshwater channel rather than directly from seawater.

Major required crossings use established bridges, fords with explicit walkable geometry, or raised paths. Do not add swimming, current simulation, or boat control as an unstated requirement for this story route.

### Teluk Teduh — The large bay

The bay should be recognizable in multiple views: an opening coastal overlook, a forest headland, and the wetlands near Tirta. Its southern mouth remains visibly connected to the ocean. Keep the far shore distant enough to communicate scale.

Place sheltered beaches and fishing platforms on selected shore sections. Higher rocky headlands frame the inlet. These locations may support exploration, but the bay is primarily a geographic landmark in the first version, not an additional sea-travel campaign.

A later ferry between discovered coastal stops is possible. The base quest route must remain completable on foot, and optional ferry service must not become an extra prerequisite for the cure.

### Surrounding ocean

Show ocean beyond every side of the island when the coastline is reached. Use coast, shallows, and deep-water color bands to communicate depth. In the initial scope, deep water is a clear traversal boundary; do not rely on an invisible wall placed over apparently walkable terrain.

Accessible coastline does not need to form one continuous beach. Cliffs and headlands can separate shore pockets, with inland routes connecting them. Offshore silhouettes may communicate distance, but they are not promised explorable islands.

## 6. Roads, exploration, and return routes

Keep three route types visually distinct:

| Route type | Purpose | Design rule |
| --- | --- | --- |
| Main story path | Connect the current hub, region landmark, and next portal | Clear enough to follow without a permanent full-screen marker trail |
| Local exploration loop | Offer a side objective, cache, viewpoint, or additional combat | Reconnect near the chapter route rather than ending in a long empty return walk |
| Return shortcut | Reduce repeated travel after discovery or a dungeon victory | Keep the ordinary route open; never require optional quest completion for the only exit |

A required connection along the island's inhabited southern lowlands joins Kamboja, Hutan Embun, the dry route around the bay's head, and Tirta. Later, a central foothill connection links Tirta's inland road, Lereng Bara, and Wana Sela. Highland branches lead to the ravines, lake basin, ridge passes, and final summit.

Visiting home between chapters is optional. Provide practical return connections as regions are cleared; decide later whether these use physical shortcuts, travel between discovered hubs, or another explicitly introduced system. Do not assume the player must manually retrace the entire island after dungeon 7.

Portals become active according to the established ingredient sequence. Ordinary mainland routes, village services, and emergency retreat paths must not become reputation or side-quest locks. Higher-level regions can be visible early, with clear danger warnings, while the required route remains readable and fair.

## 7. Quest placement and environmental storytelling

- Put Kamboja's goat, seed delivery, and clinic tasks in or immediately around the village. Do not scatter tutorial tasks across the whole island.
- Place Tirta's water-maintenance encounter and two material bundles near the raised-trail approach toward Rawa Bisu. Leave a safe route to its merchant regardless of side-quest status.
- Put Damar's lookout on the Wana Sela-to-Jurang Angin approach. Wira's tool cart and Intan's wayfinding posts use nearby branches, not a second trip through the earlier quarry dungeon.
- Keep the two shoreline markers and cache for `sq_exp_01` around Danau Senja, not split across the island's three lakes.
- Keep the lantern loop for `sq_exp_02` near the Punggung Kabut route. Required mountain navigation remains visible before repairing optional lanterns.
- Let major forest, bay, lake, and mountain landmarks contribute to Sinta's existing journal quest. Reusing a discovery does not create another quest or another reward claim.
- Make the final summit approach focused and well prepared. Do not put a new village, a mandatory sailing trip, or a large side-quest chain between ingredient 7 and the return home.

The geography can hint at the optional illness-origin mystery through related river markings or unusual plant growth. These should remain optional story clues until that lore is explicitly adopted. Do not claim that fixing a local water point cures the illness.

Implementation dependencies and milestone checklists are in the [implementation roadmap](../implementation-roadmap.md). The [wilderness encounter specification](../gameplay/wilderness-encounters.md) defines monster packs, grinding habitats, and respawning without changing the seven main dungeon milestones.

## 8. Region boundaries, safety, and difficulty

Settlements are safe hubs without ordinary monster spawns inside essential service areas. Kamboja's surrounding routes begin gently; progressively stronger encounter areas follow the seven existing mainland level bands. The strongest ordinary wilderness monsters remain level 99, and the final dungeon boss remains level 100.

Use terrain and encounter signs to communicate danger: narrow tracks, damaged camps, larger creature silhouettes, or a scout's warning. A player who approaches a dangerous region early should retain a way to retreat. Do not place a lethal encounter immediately beyond an unmarked streaming transition.

Place preparation checkpoints before dungeon portals, rest stops at major route junctions, and a clear return point for each dungeon. An inactive future portal is not a trap and must not strand the player behind an impassable return route.

Terrain collision follows what the player can see: water edges, rock faces, trunks, and building footprints. Decorative canopy or a mountain painted in the distance must not silently block a foreground path.

## 9. Authoring and asset scope

Build the island as connected authored regions with loading or streaming boundaries, rather than committing to one enormous JSON file now. Region transitions can use sheltered bends, forest gaps, bridges, and mountain passes to limit abrupt visual changes. The actual loading design and performance budget need a prototype; this document does not claim that streaming is implemented.

Use normalized geography until walking speed, camera scale, encounter spacing, and travel time are tested. Avoid deciding the final island's tile count or real-world kilometers from an illustration alone. Prototype Kamboja and the Hutan Embun route first, then the connection to Tirta, before scaling the entire coast.

The overworld needs its own tileset families:

| Asset family | Needed pieces |
| --- | --- |
| Ground | Grass, earth trails, farmland, stone paths, wetland banks, and material transitions |
| Forest | Tree trunks, canopy layers, roots, shrubs, clearings, and collision-aware understory |
| Mountains | Connecting cliff faces, corners, ridge caps, slopes, switchbacks, and rock outcrops |
| Water | Lake edges, river bends, shallows, deep water, coast transitions, and waterfalls |
| Bay and coast | Beaches, rocky headlands, fishing platforms, bridges, and shoreline transitions |
| Settlements | Homes, service buildings, market pieces, fences, fields, pens, and regional decorations |
| Landmarks | Portal gateways, ruin fragments, wayfinding posts, overlooks, and readable trail markers |

Target the existing 64-pixel source-tile convention where suitable, while allowing larger trees and structures to span cells. Preserve the established world scale deliberately when implementing the new assets. Reuse the project's earthy material palette, with restrained forest greens, freshwater blue-green, and deeper ocean colors; write a dedicated overworld art specification before generating a full atlas.

Do not stretch the dungeon atlas into grass, water, mountains, and houses. Keep dungeon interiors as separate maps linked to their mainland entrance records.

## 10. Suggested planning and build sequence

1. **Geographic blockout:** outline the coast, southern bay, three lakes, drainage valleys, and mountain ridges using simple planning shapes. Check that all proposed anchors lie on appropriate terrain.
2. **Route blockout:** connect the three settlements and seven portal approaches. Walk the route on a simple test map before decorating it.
3. **Opening-region prototype:** build Kamboja, its fields, Hutan Embun, and dungeon-1 entrance. Test camera framing, travel rhythm, clearances, and safe retreat.
4. **First regional hub:** extend the dry bay-head route to Tirta and Rawa Bisu. Validate local side-quest loops and portal returns.
5. **Highland expansion:** add Lereng Bara, Wana Sela, Jurang Angin, and Danau Senja with distinct terrain and silhouettes.
6. **Final ascent:** add ridge passes, a preparation checkpoint, and the summit gateway. Verify a convenient return after the final dungeon.
7. **Art and performance pass:** replace blockout materials with connected overworld tiles, then check seams, collision, occlusion, loading, and encounter density.

## 11. Acceptance checklist

- The mainland reads as one large island with ocean around it and a bay connected to the sea.
- Several mountain ridges and extensive forests are evident, with multiple freshwater lakes.
- The story route is walkable from Kamboja through all seven portal regions without requiring optional quests, boats, swimming, jumping, or free climbing.
- Kamboja, Tirta, and Wana Sela remain the three planned settlements; later checkpoints do not silently expand into additional village production scope.
- The 12 main quests, 11 side quests, seven unique ingredients, and level-100 finale remain unchanged.
- Portal return points, hub services, main-route preparation, and retreat paths remain reachable.
- Optional lake and coastline discovery does not become a hidden main-story prerequisite.
- Exact coordinates, tile dimensions for the overall island, travel times, and streaming boundaries are validated through blockout rather than treated as final numbers in this document.
