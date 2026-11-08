# Niskala — Step-by-step implementation checklist

Status: implementation plan. Unchecked tasks are future work; this document does not implement them. Complete phases in dependency order and verify each exit condition before expanding content. Proposed tuning values remain subject to playtesting.

## Starting point — 2026-11-08

Current stage: a playable dungeon foundation with campaign design documents. The current entry point constructs Arka and loads `tiled/map.json`; game over constructs a fresh `Game`. Campaign travel and recovery therefore need explicit shared state before content expansion. These observations are based on `lib/game.dart` and `lib/widgets/game_controller.dart`, rather than a full runtime audit.

The accepted Arka design is saved in [the approved snapshot](art/arka-approved-2026-11-08/README.md). Use it for the initial playable milestones. Additional character-art experiments are outside the first development work package.

**First product target:** start in Kamboja, receive permission, enter the forest, fight a small pack, defeat the first dungeon boss, receive one ingredient, and return home. Closing and reopening the game must preserve progress. This is the first vertical slice and the point to evaluate whether exploration, combat, and the story work together.

### Immediate work package: baseline and shared state

Execute these tasks in order. This is the next work package, not a claim that P00 or P01 is complete.

| Order | Deliverable | Evidence required |
| --- | --- | --- |
| 1 | Record the current automated baseline with `flutter analyze` and `flutter test` | Commands, results, and any pre-existing failures recorded separately |
| 2 | Run the current dungeon on one available development target | Movement, both attacks, XP, level-up, death, and restart checked; device and controls recorded |
| 3 | Record current scale, camera, loading, and performance observations | A repeatable sandbox scene and measured starting values; unresolved device targets explicitly listed |
| 4 | Define stable IDs and a minimal shared session | Player progression, resources, current location, and checkpoint have clear ownership; future campaign fields have an extension path |
| 5 | Bind a newly constructed Arka to that session | Focused tests show reconstruction retains progression and resources; an ordinary enemy defeat still awards XP once |
| 6 | Review the P00/P01 exit conditions | Only verified tasks checked off; next work package becomes the registry and three-map travel prototype in P02 |

Keep implementation changes small enough to review by deliverable. The baseline record can live in `docs/development-baseline.md` when execution starts; do not fill it with assumed results.

### Scope and scheduling rules

- Treat milestones A–E below as delivery gates. Complete the gate's observable behavior before expanding into its next content batch.
- Use placeholder village, forest, NPC, and boss art through the first loop where needed. Produce outdoor art after routes and combat spaces survive playtesting.
- Defer seamless streaming, the complete island, dungeons 2–7, and additional side quests until the first loop is validated. Basic map transitions come first.
- Keep inventory/equipment to the minimum needed for opening rewards and protected ingredients; settle broader gear design during that prototype.
- Choose a primary development device in P00. Supported release platforms, final performance budgets, and release requirements remain open until verified.
- Set calendar estimates after the baseline and travel prototype reveal actual throughput. Team size and available development time are currently unspecified; phase order is the commitment here.

At each milestone review, record the build/revision, automated check results, manual route played, observed problems, and the next priority. A milestone passes when its exit conditions are demonstrated, with blocking failures resolved.

## Target experience

Arka starts in Kamboja, receives guidance and his mother's permission, explores a forest-and-mountain island, fights respawning monster groups, visits two regional villages, conquers seven dungeons, and returns with seven ingredients to craft the cure.

Architecture direction: the mainland consists of connected regions with loading or streaming boundaries; villages and dungeons use separate maps. A shared game session preserves player and story state across transitions. This is a planned architecture, not the current single-map entry point's behavior.

Design references:

- [Main story](story/main-story.md) and [quest catalog](story/quest-flow.md): 12 main quests and 11 optional side quests.
- [Island geography](story/mainland-map-plan.md) and [settlements](story/mainland-settlements.md): three settlements, forests, mountain ranges, three lakes, a large bay, and surrounding ocean.
- [Dungeon progression](story/dungeon-progression.md): seven ingredients and the level-100 final boss.
- [Wilderness encounters](gameplay/wilderness-encounters.md): group combat, territory, respawn policy, grinding, and population limits.
- [Player assets](player-sprites.md) and [dungeon tileset](dungeon-tileset.md): existing asset conventions.

## Existing foundations to reuse

These observations come from the named source files, not an exhaustive audit. Source presence and existing tests are not proof that the new island systems work. Run the baseline checks in P00 before implementation.

| Foundation observed | Current evidence | Treatment |
| --- | --- | --- |
| Arka movement, melee/finisher, ranged combat, and auto-aim | `lib/player/knight.dart`; `test/auto_aim_test.dart` | Extend and verify against packs rather than replace |
| Player XP, level-ups, stats, and current player cap of 100 | `lib/model/progression.dart`; `test/progression_test.dart` | Reuse the model; rebalance the campaign curve later. The final boss does not require a level-100 player |
| Enemy level-based stats and XP bounty integration | `lib/model/progression.dart`, `lib/enemies/goblin.dart`, `lib/enemies/imp.dart` | Add habitat-level constraints and duplicate-reward protection |
| A configured Tiled map and object builders | `lib/game.dart` | Preserve the existing map as a development sandbox while introducing a registry |
| A game-over flow that creates a new `Game` | `lib/widgets/game_controller.dart` | Replace session-reset behavior deliberately when checkpoints and persistence are introduced |
| Active Arka and HD dungeon assets, plus tests | `lib/util/player_sprite_sheet.dart`; asset and dungeon tests | Retain compatibility checks and avoid unrelated art rewrites |

## Delivery milestones

| Milestone | Phases | Observable result |
| --- | --- | --- |
| A — Travel foundation | P00–P03 | Move between test maps, save, reload, and keep character state |
| B — First playable story loop | P04–P08 | Kamboja → forest packs → dungeon 1 → ingredient → return home |
| C — Scalable mainland foundation | P09–P10 | Two connected mainland regions, bounded populations, and reusable overworld art |
| D — Regional campaign | P11–P13 | Tirta, Wana Sela, and dungeons 2–6 with their quests |
| E — Complete story | P14–P15 | Dungeon 7, cure, ending, and campaign validation |

The first implementation priority is P00 followed by P01–P02. Do not start by drawing the whole island or creating all seven dungeon interiors.

## P00 — Establish the baseline

Dependencies: none.

- [x] Run the current test suite and record existing failures separately from new work. Check progression, auto-aim, assets, dungeon geometry, and the game integration test. All 21 tests passed; analysis has 10 pre-existing informational findings. See [development baseline](development-baseline.md).
- [ ] Smoke-test the existing game on the chosen development target: movement, attacks, XP gain, level-up, game over, and UI.
- [x] Confirm current player scale, source tile dimensions, world tile size, camera settings, and controls from the current code; do not overwrite recent changes using old documentation values. Recorded in the baseline.
- [ ] Define the first device/performance target and a repeatable profiling scene. Record loading, frame-time, memory, and actor-count baselines without inventing final budgets.
- [ ] Preserve the current dungeon map as a clearly named development/test map; decide how tests will select it after new-game flow changes.
- [x] Record stable identifier conventions for maps, regions, spawns, portals, NPCs, quests, ingredients, habitats, and monster instances. Recorded in the baseline; registry implementation remains P02 work.

Exit condition: the current build has a recorded baseline and the new campaign can be developed without silently replacing the sandbox or invalidating its test fixtures.

## P01 — Separate persistent game state from map actors

Dependencies: P00.

The P01 data foundation is implemented: `GameSession` owns progression, health, stamina, map/checkpoint IDs, reward claims, and a component-free `CampaignState`. `GameState` retains it across actor reconstruction; `Knight` accepts the session and mirrors life changes into it. Reconstruction, campaign ownership, healing, level-up, save compatibility, and session isolation have focused tests. P00's manual/profile checks remain pending; this does not pass the travel milestone gate.

The session is retained for one `GameState` and can be restored through the encrypted sandbox save flow. Game-over navigation still starts a fresh game; campaign checkpoint recovery and integration of the new records into world interactions remain future work. Only one live player actor should own a session at a time; transition lifecycle enforcement belongs to P02.

Campaign increment — 2026-11-09: inventory quantities, equipment references, quest/interaction facts, discoveries, completed quests, boss-to-ingredient ownership, habitat cooldown records, and named return destinations are now session-owned and encrypted with saves. Typed campaign events update the appropriate records idempotently. These are data boundaries: no quest acceptance logic, inventory UI, equipment stat bonuses, respawn clock, automatic story events, or map transitions are implied. The next implementation step is P02's validated map registry and travel prototype.

Reward increment — 2026-11-09: enemy actors now issue an `EnemyDefeated` value with a unique spawned-life ID. The session owns XP grants and claimed reward IDs; repeated notifications for the same life do not grant XP again, including after actor reconstruction or encrypted save/load. Fresh sandbox map loads construct new lives, consistent with the existing encounter-reset policy. This does not implement persistent enemy populations, boss completion, ingredients, or first-clear rewards.

- [x] Define a shared session containing progression, health, stamina, inventory/equipment references, current map, checkpoint, and return destinations.
- [x] Plan extensible records for quest facts, ingredient ownership, boss completion, habitat cooldowns, discovery, and reward claims; do not put all mutable data inside `Knight` or a widget. Implemented with validated, versioned campaign records.
- [x] Reuse `PlayerProgression` when constructing or rebinding Arka on a map; do not reset level or XP during scene creation. Verified by reconstruction tests.
- [x] Define typed events or equivalent boundaries for enemy defeat, region discovery, interaction, quest completion, and ingredient receipt. Enemy defeat is wired to actors; campaign event producers belong to later map/quest phases.
- [x] Define reward ownership so one enemy defeat cannot award XP through both its old death callback and a new encounter controller. All four enemy types route life-specific rewards through the session; future controllers must retain the same life ID and use this boundary.
- [x] Write focused state tests for character reconstruction and duplicate reward claims. No save-system success should depend on a live rendering component. Includes replay, new lives, rejected rewards, level-up resources, read-only claims, and encrypted restoration.

Exit condition: two fresh map/player component instances can refer to the same authoritative character and campaign state without sharing mounted component instances.

## P02 — Implement map registry and safe transitions

Dependencies: P01.

Registry increment — 2026-11-09: immutable map definitions now identify asset, map kind, dimensions, and named tile-coordinate spawns. The preserved `dev_dungeon/start` entry loads the original asset at its original location through this registry. Invalid/duplicate definitions and out-of-bounds spawns are rejected. Continue resolves a saved location, then its checkpoint, then the registered sandbox fallback, retaining character/campaign state and showing a recovery notice if needed. Definition bounds are not proof of collision-free terrain or successful asset loading.

P02 remains open: only the existing sandbox is registered. The three prototype maps, transition objects, arrival protection, loading/failure rollback, and checkpoint recovery still need implementation.

- [ ] Add map definitions for mainland regions, village interiors, dungeons, and the preserved sandbox. Each definition identifies its asset and valid named spawns.
- [ ] Create three simple test maps: a village area, a wilderness area, and a dungeon room. Use existing or placeholder art.
- [ ] Add transition objects with destination map, destination spawn, return entrance, and interaction requirements. Support village gates and dungeon portals through the same validated transition boundary.
- [ ] Add loading/fade behavior, prevent duplicate activation, and disable input while the destination is not ready.
- [ ] Place Arka at a validated arrival point, clear of collision and hostile spawn exclusions, with arrival protection against immediately retriggering the return trigger.
- [ ] Restore the correct mainland entrance when leaving a village or dungeon. Keep health, stamina, XP, inventory, and quest facts unchanged except for explicit gameplay rules.
- [ ] Handle missing maps, invalid spawns, or loading failure by retaining or restoring a valid safe scene and state.
- [ ] Adapt game-over navigation so rebuilding a scene does not accidentally start a new campaign. Recovery destination and restored resources become explicit rules.

Exit condition: village → wilderness → dungeon → wilderness → village works repeatedly, including rapid trigger re-entry and a failed destination load.

## P03 — Save, load, and checkpoint foundation

Dependencies: P01–P02.

Storage increment implemented ahead of scene integration: versioned session encryption with AES-256-GCM, a platform secure-storage key adapter, native encrypted files, validated backup recovery, and focused storage tests. Native New Game/Continue and manual Save at entrance now support the existing sandbox, restoring player stats/resources at its entrance while resetting encounters. A game widget test exercises saving without reconstructing the actor. See [encrypted saves](encrypted-saves.md). Campaign checkpoint semantics, world-state persistence, map-registry validation, OS-plugin smoke tests, and automatic save triggers remain pending; P03 is not complete.

- [ ] Choose local persistence and add a versioned save schema, validation, and recovery behavior for missing or invalid saves.
- [ ] Persist player state, discovered map/spawn IDs, checkpoint, and transition return records.
- [ ] Provide new-game and continue paths; make starting a fresh campaign an explicit action rather than a side effect of changing maps or dying.
- [ ] Define death recovery at a safe checkpoint, preserving story items and completed milestones. Decide any resource penalty separately.
- [ ] Save on stable transitions/checkpoints and later extend the same mechanism to boss/reward commits. Avoid saving a half-loaded destination as a valid arrival.
- [ ] Test save → process restart → continue, save during a transition request, missing data, incompatible versions, and death recovery.

Exit condition: closing and reopening the game preserves the travel loop and character progression, with a safe fallback if a saved location cannot load.

## P04 — Block out Kamboja and the first forest

Dependencies: P02–P03.

- [ ] Create a separate Kamboja map with the required homes, chief's hall, clinic, worship space, learning house, fields, pens, marketplace, and gate.
- [ ] Place stable named NPC/interaction anchors, beginning with Ratih, Darma, Lestari, Bima, Bayu, and Laras. Reuse placeholder visuals where needed.
- [ ] Create a small Hutan Embun mainland region with paths, clearings, a safe arrival zone, and the dungeon-1 portal landmark.
- [ ] Reserve three pack territories, a retreat route, ordinary recovery access, and space to test crowd movement without trees obscuring combat.
- [ ] Set terrain collisions and transition exclusion areas. Keep the main route traversable with current movement; do not assume swimming, jumping, or climbing.
- [ ] Walk and time the opening route before final art. Correct dead ends, cramped hitboxes, poor camera framing, and excessive empty travel.

Exit condition: Arka can leave Kamboja, find the first portal area, and return safely on a playable blockout.

## P05 — Quest and NPC framework for the opening

Dependencies: P01, P03–P04.

- [ ] Implement quest definitions and state transitions for availability, acceptance, objective progress, turn-in, and completion. Use the existing catalog IDs.
- [ ] Persist underlying facts separately from presentation: discovery, interactions, fixed encounters, ingredients, and reward claims.
- [ ] Add NPC dialogue conditions and a small quest journal with one tracked main objective and optional side tasks.
- [ ] Implement `main_01_village`, `main_02_permission`, and `main_03_departure`, including Ratih's permission and the first portal discovery.
- [ ] Implement only the two initial optional choices for the first loop: `sq_kam_01` and `sq_kam_03`.
- [ ] Protect quest items from ordinary selling or consumption, and support pending ordinary reward collection when inventory is full.
- [ ] Test actions before acceptance, declined/abandoned side tasks, repeated dialogue, changed NPC location, and save/reload during progress.

Exit condition: opening main quests advance without either optional task, and rewards cannot be lost or duplicated by replaying interactions.

## P06 — Habitat spawning and fair mob combat

Dependencies: P01, P04–P05. Use [wilderness encounter rules](gameplay/wilderness-encounters.md).

- [ ] Define habitat and group data: map/region ID, group ID, enemy types, fixed regional level range, home positions, territory, spawn exclusions, and population caps.
- [ ] Validate spawn positions against walkable terrain, collision, player proximity, safe hubs, and portal/checkpoint arrivals.
- [ ] Create the first forest habitat with three groups of three monsters. Do not expand into large camps yet.
- [ ] Add independent group identities, local assistance/aggro, bounded pursuit, disengagement, and returning-home behavior.
- [ ] Prototype a shared attack-commitment budget near Arka; start by testing two simultaneous commitments rather than three synchronized hits.
- [ ] Provide repositioning and separation behavior for nonattacking members. Check cliff/path access before recruiting nearby allies.
- [ ] Verify current melee, finisher, ranged auto-aim, stamina recovery, and hit reactions against several enemies; make enemy targets and attacks readable.
- [ ] Give every spawned life a unique identity, award kill XP exactly once, and treat unload/despawn as lifecycle operations rather than deaths.

Exit condition: the player can intentionally engage one pack, survive a readable mob fight, retreat, and avoid accidentally pulling the whole region.

## P07 — Respawning and optional grinding

Dependencies: P03, P06.

- [ ] Implement pack-clear cooldowns. Start timing when the last member dies; keep partly cleared groups depleted until then.
- [ ] Try ordinary pack cooldowns of 2–3 minutes and camp cooldowns of 4–6 minutes as configurable tuning, not hardcoded constants spread across enemy classes.
- [ ] Require offscreen placement plus distance, valid terrain, and no nearby combat. Defer safely when conditions fail; never stack replacements on a fallback point.
- [ ] Enforce group, habitat, and active-region population caps, including actors being created. Measure a global active-actor budget.
- [ ] Persist dead/cleared state, cooldown remaining, and one-time first-clear claims across map transitions and saves. Pause stops the initial gameplay clock; application closure grants no offline respawns.
- [ ] Test repeated farming cycles, partial clears, leaving for a village, defeat, saving/reloading, and returning just before or after cooldown expiry.
- [ ] Verify legitimate fresh spawns award ordinary kill XP again, but the same killed instance and one-time first-clear reward cannot be claimed twice.

Exit condition: packs reliably return for grinding without visible pop-in, immediate gate-reset farming, unlimited population growth, or reward duplication.

## P08 — Dungeon 1, ingredient reward, and the first complete loop

Dependencies: P02–P07.

- [ ] Author Akar Terlupakan as a separate map with an entrance checkpoint, retreat path, encounters, boss area, and clear exit.
- [ ] Prototype Penjaga Lumut at the proposed level 12 using readable attacks and placeholder art if necessary.
- [ ] Implement `main_04_dungeon_01`, boss completion, and guaranteed Daun Embun receipt in protected quest storage.
- [ ] Commit boss completion, ingredient ownership, and reward claims consistently. Re-entering or reloading cannot grant a second ingredient.
- [ ] Keep story bosses and fixed quest encounters outside ordinary wilderness respawn rules.
- [ ] Return Arka to the correct forest portal, then permit a home visit with updated Lestari/Ratih dialogue and the next-region lead.
- [ ] Test full inventory, defeat before/after victory, interrupted reward presentation, re-entry, and continuing from a save after the first ingredient.

Exit condition — Milestone B: a playable new-game route reaches ingredient 1, returns home, and preserves progression through a restart. Stop and playtest before adding the rest of the island.

## P09 — Verify regional loading and active-world limits

Dependencies: P08 and a reviewed first-loop playtest.

- [ ] Choose and prototype the mainland loading approach: connected region scenes or chunk streaming. Do not assume engine support alone establishes the full world-state lifecycle.
- [ ] Build two adjacent mainland test areas with stable region/chunk IDs and one walkable crossing.
- [ ] Keep the transition between mainland areas distinct from entering a separate village or dungeon, even if the first implementation uses loading screens for both.
- [ ] Activate enemies near the player and unload or suspend distant actors without awarding deaths, resetting cooldowns, or cloning persistent state.
- [ ] Test backtracking across a boundary during pursuit, partial pack clearance, and respawn eligibility. Define what pursuing enemies do at that boundary.
- [ ] Profile repeated crossings and a mob fight on target devices. Establish measured loading, memory, frame-time, and actor budgets before increasing island size.

Exit condition: expanding the mainland does not require simulating every monster or retaining every loaded map component.

## P10 — Overworld art and opening-region production pass

Dependencies: P08–P09.

- [ ] Write the overworld art specification: earthy palette plus restrained forest greens, freshwater colors, deep ocean, consistent light, and connecting edges.
- [ ] Create only the first required tileset families: grass/path transitions, trees and canopy, cliffs, village buildings, bridges, water edges, and portal markers.
- [ ] Use the 64-pixel source-tile convention deliberately and validate world scale, collision, and multi-cell props; do not stretch dungeon textures into every outdoor material.
- [ ] Replace Kamboja/Hutan Embun blockout art while preserving validated routes, safe zones, combat clearings, and named spawns.
- [ ] Block out the island coast, southern bay, lakes, drainage valleys, and mountain backbone at planning scale; keep geography separate from a promise to author every tile immediately.
- [ ] Recheck seams, canopy occlusion, target visibility, collision, and performance after replacing simple prototype geometry.

Exit condition: the first region establishes a repeatable outdoor art and authoring pipeline without breaking the playable loop.

## P11 — Tirta and dungeon 2

Dependencies: P09–P10.

- [ ] Build the dry route around the bay's inland head into the wetlands, with readable difficulty progression and safe retreat.
- [ ] Add Desa Tirta as a separate map, its four named NPCs, baseline rest/merchant access, and correct mainland return point.
- [ ] Implement the regional main thread within `main_05_dungeon_02`, not a new mandatory quest chain.
- [ ] Add `sq_tir_01` and `sq_tir_02` on nearby route branches. Neither gates the portal or basic services.
- [ ] Build Sumur Rawa, Ratu Rawa at proposed level 25, Lumut Nadi, and the next-region lead.
- [ ] Add regional habitats and level constraints. Verify the mainland cap of 99 separately from the enemy model's general cap of 100.

Exit condition: two ingredients are obtainable, both settlement exits work, and skipping Tirta's side quests still permits progression.

## P12 — Foothills, Wana Sela, and dungeons 3–4

Dependencies: P11.

- [ ] Add Lereng Bara and Gua Bara with `main_06_dungeon_03`, the proposed level-40 boss, and Getah Bara.
- [ ] Add Desa Wana Sela as a separate map with its four named NPCs, repairs, supplies, and return records.
- [ ] Implement Damar's lookout encounter and `main_07_dungeon_04`, with journal fallback for valid alternate routes.
- [ ] Build Jurang Angin and Menara Angin, the proposed level-55 boss, and Bunga Langit.
- [ ] Add `sq_wan_01` and `sq_wan_02`, plus Ratih's optional midpoint letter; keep essential repairs and crossings available without optional completion.
- [ ] Add the remaining Kamboja side quests `sq_kam_02`, `sq_kam_04`, and `sq_kam_05`, with retroactive discovery/conversation credit and convenient later turn-ins.

Exit condition: four ingredients and the two regional hubs work together; optional home visits acknowledge progress without consuming ingredients.

## P13 — Lake basin, ridge passes, and dungeons 5–6

Dependencies: P12.

- [ ] Build Danau Senja and its main-route connections, with readable lakeshore and cliff collisions.
- [ ] Implement Kuil Senja and `main_08_dungeon_05`, the proposed level-70 boss, Akar Senja, and required recipe information.
- [ ] Add `sq_exp_01` as a local exploration loop, keeping its optional cache separate from essential recipe knowledge.
- [ ] Build Punggung Kabut, Benteng Kabut, and `main_09_dungeon_06`, with the proposed level-85 boss and Biji Fajar.
- [ ] Add `sq_exp_02`; optional lantern repairs improve navigation but are not the only way to see the required path.
- [ ] Complete supporting lake/bay/coast landmarks according to available production budget without introducing new required quests or mandatory sailing.

Exit condition: six ingredients are obtainable; level progression, mountain preparation, and return paths remain viable without optional tasks.

## P14 — Final dungeon, return, cure, and ending

Dependencies: P13.

- [ ] Build the Puncak Niskala approach and a guaranteed preparation checkpoint. Ordinary wilderness encounters remain level 99 or below.
- [ ] Implement Jantung Niskala and `main_10_dungeon_07`, with the level-100 final boss and guaranteed Sari Niskala.
- [ ] Provide a convenient final exit and the required return to Kamboja; no eighth ingredient, bonus reputation gate, or mandatory extra boss.
- [ ] Implement `main_11_return`, checking all seven unique ingredients and final-boss completion.
- [ ] Implement `main_12_cure`: clear prompts, recoverable input mistakes, no loss of unique ingredients through failed preparation.
- [ ] Make starting the ending clear to the player while allowing optional exploration beforehand. Archive unfinished side tasks without changing the cure outcome.
- [ ] Add distribution/recovery scenes, Ratih's reunion, relevant optional acknowledgments, credits, and a completed-story save.

Exit condition: the established story can be completed from new game to cure with exactly seven boss ingredients, whether or not side quests were completed.

## P15 — Campaign balance, resilience, and release checks

Dependencies: P14. Apply smaller versions of these checks at every earlier milestone.

- [ ] Play the full campaign while skipping side quests and repeatable farming. Tune main-route encounters, boss/main XP, supplies, and equipment access so optional grinding stays optional.
- [ ] Play a grinding-heavy route and check pack density, kill rates, cooldowns, XP/hour, healing cost, level curve, and whether repeated camps trivialize later bosses.
- [ ] Review 1–2 wildlife, 3–5 packs, 5–8 camps, and elite-plus-companion encounters before approving final group counts.
- [ ] Exercise save/load at transitions, during partial encounters, after bosses, before cure preparation, and after completion. Verify no duplicate ingredients or reward claims.
- [ ] Test all 12 main quests and 11 side quests for early actions, alternate routes, full inventory, moved NPCs, abandonment, late turn-in, and safe failure recovery.
- [ ] Verify ocean/river/cliff boundaries, island route connectivity, portal destinations, safe arrival zones, and every village exit.
- [ ] Profile worst-case visible mobs, scenery, effects, repeated map changes, memory growth, loading, and active-actor caps on target devices.
- [ ] Recheck UI readability, control bindings, attack telegraphs, dialogue, journal navigation, settings, and the updated documentation.

Exit condition: repeatable campaign, stable saves, bounded active-world simulation, and measured performance within the chosen device budgets.

## Decisions to settle during the prototypes

Do not block this checklist on selecting every content detail upfront. Record these decisions when the corresponding phase provides evidence:

| Decision | Resolve by |
| --- | --- |
| Save storage and compatibility policy | P03 |
| Region switching versus seamless chunk streaming | P09 prototype; use simple separate regions before expanding if needed |
| Active monster/attack budgets and safe respawn distance | P06–P09 profiling and combat tests |
| Final pack sizes and respawn timings | First-loop and campaign balance passes |
| Gear/inventory details and precise XP curve | Initial quest/reward prototype, then full campaign balancing |
| Optional illness-origin mystery and guardian lore | Before final dialogue/art production, without blocking travel and combat prototypes |
| Island tile count, travel times, and full art budget | After the first two mainland regions are walked and profiled |

## Completion discipline

Mark a task complete only when its behavior is implemented and checked. Documentation, placeholder art, or engine capability alone does not complete a gameplay task. Keep deferred ideas separate from the 12-main/11-side-quest scope, and update this checklist as current code and tested decisions evolve.
