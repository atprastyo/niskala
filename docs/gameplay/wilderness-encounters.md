# Wilderness monster groups and respawning

Status: accepted gameplay direction with proposed tuning values. This is a design specification, not a claim that group spawning or respawning is implemented. See [implementation-roadmap.md](../implementation-roadmap.md) for the implementation order.

## Goal

Let Arka find recognizable monster habitats, fight groups, gain levels, and return to those habitats for optional grinding. Main-story progress must remain reasonable without repeatedly farming the same camp.

Each habitat has authored monster types, a narrow level range within its region, valid spawn points, a territory, and a maximum population. Do not scale every encounter automatically to Arka's level. Ordinary mainland monsters are capped at level 99; the final story boss is level 100.

## Encounter types

| Type | Starting group size | Placement and purpose |
| --- | --- | --- |
| Scattered wildlife | 1–2 | Gentler approaches and introductory encounters |
| Roaming pack | 3–5 | Clearings and branching trails for normal leveling |
| Monster camp | 5–8 | Deliberately entered combat spaces with better ordinary rewards |
| Elite group | One elite plus 2–4 companions | Clearly signaled optional danger away from essential early routes |

These are playtest targets. Do not begin by implementing the largest groups. The first prototype is **one forest habitat with three groups of three monsters**, nine monsters total when fully populated. Select or reskin existing enemy types for this prototype before commissioning a full regional bestiary.

Village service areas, gate arrival points, portal return points, and checkpoint spawn locations are safe. Larger groups should be discoverable without standing directly on the only route to the next story objective.

## Group combat

- Give each group a stable identity and bounded territory. Nearby group members may respond to a provoked member; distant groups do not automatically join.
- Require range and suitable line of sight or path access for reinforcement. An enemy behind a cliff must not alert the entire region.
- Prototype a shared limit of two simultaneous attack commitments near Arka, including enemies from adjacent engaged groups. This is a tuning proposal, not a final combat rule.
- Other enemies can reposition, circle, or seek space while waiting. Avoid an obvious stationary queue or overlapping bodies blocking every escape.
- Stagger heavy attack telegraphs and do not allow offscreen attacks without adequate warning. Check the existing auto-aim against crowds and unreachable targets.
- Enemies pursue within their territory and return home after a bounded disengagement. Returning enemies do not grant kill rewards, and any health reset must be clearly communicated.
- Test melee, finisher, ranged targeting, stamina regeneration, hit reactions, and recovery supplies against packs before raising counts.

## Respawn policy

Starting values: ordinary packs return roughly **2–3 minutes** after the pack is cleared; camps return roughly **4–6 minutes** after clearance. Tune these values alongside route length, kill speed, XP, and recovery access.

For the first version, use pack-clear respawning: individual kills leave the surviving pack depleted. The cooldown begins when its final member dies. Restore only the configured pack population after the cooldown and safety conditions are satisfied. Individual-slot replenishment can be a later extension.

A ready pack may respawn only when its spawn points are outside the camera view plus a safety margin, sufficiently far from Arka, and free from nearby combat. Being offscreen alone is not enough. Validate terrain, collision, village exclusions, and arrival-point exclusions before placing each actor. If no valid placement exists, defer rather than stacking enemies at one fallback coordinate.

Cap population per group, habitat, and active region; measure a global active-actor budget on the target devices. Group caps count actors already alive or being created. Cooldown expiry must never accumulate multiple replacement waves.

Use elapsed gameplay time initially: pause stops cooldown progress, and closing the application does not grant offline respawns. Preserve the cooldown across map changes and saves. Clearing a pack and stepping through a village gate must not reset it into an immediately farmable replacement.

## Rewards and persistence

Every legitimate newly spawned monster can award ordinary combat XP and loot on defeat. Deduplicate death processing using its instance identity so damage callbacks, unloading, and reloading cannot award the same kill twice. Unloading or returning home is not a death event.

A pack may also have an explicitly one-time first-clear bonus. Persist that bonus separately from repeatable kill rewards. Keep fixed quest encounters and dungeon bosses separate from normal repeatable habitats, so respawns cannot duplicate quest items or the seven medicinal ingredients.

Suggested saved habitat state includes stable group identity, population or dead-slot state, remaining cooldown, and first-clear reward claim. Save persistent combat outcomes; transient attack commitments and aggro are rebuilt safely after loading. Decide and test how surviving pack health resets on leaving a region; do not accidentally create kill or loot rewards during that reset.

## Prototype acceptance

- Three packs can be found and engaged independently, with local rather than region-wide aggro.
- Arka can intentionally pull and fight several monsters while reading attacks and retaining a retreat route.
- A cleared pack returns after the configured cooldown only when safe, never in the player's view or on an arrival point.
- Active population stays bounded across repeated clear/respawn cycles and region reloads.
- Each killed instance awards XP once; repeat spawns award ordinary XP again, while first-clear rewards remain one-time.
- Saves, pause, village visits, defeat, and chunk unloading do not duplicate packs or erase cooldowns.
- The required story route remains playable without grinding camps.
