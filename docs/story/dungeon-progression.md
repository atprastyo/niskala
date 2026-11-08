# Seven dungeons — Story and progression plan

Status: proposed names, regions, ingredients, and balance targets. The required structure is seven dungeons, one medicinal ingredient from each boss, wilderness monsters capped at level 99, and a level-100 final boss.

See [main-story.md](main-story.md) for the opening, final return, cure, and optional illness-origin mystery. [Quest catalog and flow](quest-flow.md) defines main and side quest dependencies. [Mainland settlements](mainland-settlements.md) describes Desa Tirta before dungeon 2 and Desa Wana Sela before dungeon 4; each adds two optional quests without becoming an ingredient or reputation gate.

## Progression overview

The level ranges below describe ordinary mainland monsters. Recommended player levels are guidance, not hard entry requirements. Dungeon encounter composition and experience values need playtesting; do not require players to fight through every individual level in a range before progressing.

| # | Mainland region and ordinary monster levels | Portal landmark | Dungeon | Recommended Arka level | Boss and level | Guaranteed ingredient |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | Hutan Embun, village-edge forest — 1–12 | An old stone arch behind a root-covered shrine | **Akar Terlupakan** — Forgotten Roots | 8–12 | **Penjaga Lumut** — Mosswarden, **12** | **Daun Embun** — Dewleaf |
| 2 | Rawa Bisu, forest wetlands — 13–25 | Standing stones on an island reached by a raised trail | **Sumur Rawa** — Marsh Well | 20–25 | **Ratu Rawa** — Marsh Queen, **25** | **Lumut Nadi** — Pulse Moss |
| 3 | Lereng Bara, rocky mountain foothills — 26–40 | A sealed mining arch exposed along an old quarry path | **Gua Bara** — Ember Cavern | 34–40 | **Golem Bara** — Ember Golem, **40** | **Getah Bara** — Ember Resin |
| 4 | Jurang Angin, forested highland ravines — 41–55 | A weathered gateway beyond a suspended bridge | **Menara Angin** — Wind Tower | 48–55 | **Rajawali Batu** — Stone Eagle, **55** | **Bunga Langit** — Skybloom |
| 5 | Danau Senja, highland lake basin — 56–70 | A lakeshore ruin revealed from a hidden mountain trail | **Kuil Senja** — Dusk Sanctuary | 63–70 | **Ular Senja** — Dusk Serpent, **70** | **Akar Senja** — Duskroot |
| 6 | Punggung Kabut, cold mountain ridges — 71–85 | A lantern-marked arch in a mist-filled pass | **Benteng Kabut** — Mist Fortress | 78–85 | **Penjaga Kabut** — Mistwarden, **85** | **Biji Fajar** — Dawnseed |
| 7 | Puncak Niskala, summit and deep-root approach — 86–99 | A monumental split-stone gateway beneath the summit | **Jantung Niskala** — Heart of Niskala | 90–99 | **Jantung Kelam** — Dark Heart, **100** | **Sari Niskala** — Niskala Essence |

All ingredient names and their properties are fictional. They represent distinct quest items, not real medicinal recommendations. Boss names are suggested display names and do not require adopting the optional corrupted-guardian lore.

The mainland progresses from village-adjacent forest into wetlands, foothills, ravines, lakes, and high mountains. The [mainland island map plan](mainland-map-plan.md) places these regions around a southern bay and a northern mountain backbone, with multiple freshwater lakes. Its geographic anchors are proposals; exact tile coordinates and region sizes still require a playable blockout.

## Dungeon 1 — Akar Terlupakan

Main quest: `main_04_dungeon_01`. Regional detours and optional rewards are listed in [quest-flow.md](quest-flow.md).

**Purpose:** Give Arka his first proof that the journey can help the village.

- Approach: low-level forest creatures, recognizable paths, and a landmark visible from a safe clearing.
- Dungeon identity: roots and old stone chambers. Introduce a short loop that reconnects to the entrance.
- Boss identity: Penjaga Lumut, a large forest guardian. Proposed lesson: watch a clear wind-up, evade, then retaliate.
- Reward: Daun Embun, ingredient 1 of 7, recorded automatically after victory.
- Story beat: Arka sees that the remedy record describes something real. A suggested memory connects the leaf's scent with home.
- Follow-up: the journal reveals the wetlands lead. Lestari's optional return conversation expresses cautious hope, not a premature cure.

Suggested quest title: **The First Ingredient**.

## Dungeon 2 — Sumur Rawa

Main quest: `main_05_dungeon_02`. Regional detours and optional rewards are listed in [quest-flow.md](quest-flow.md).

**Purpose:** Make preparation and observation matter as much as forward momentum.

- Approach: a rest and information stop at Desa Tirta, followed by wetland paths, shallow crossings, and stronger creatures around the portal island. Sena or the journal explains the standing-stone route; repairing the water point and recovering fishing materials remain optional.
- Dungeon identity: waterlogged masonry, raised walkways, and simple route-choice challenges. Any hazard should have a visible safe alternative or clear counterplay.
- Boss identity: Ratu Rawa. Proposed lesson: manage positioning against area attacks and summoned threats.
- Reward: Lumut Nadi, ingredient 2 of 7.
- Story beat: an abandoned field station or travel record suggests that earlier travelers also studied the illness. This is a proposed clue, not a required new NPC encounter.
- Follow-up: point Arka toward the foothill quarry route.

Suggested quest title: **A Path Above the Water**.

## Dungeon 3 — Gua Bara

Main quest: `main_06_dungeon_03`. Regional detours and optional rewards are listed in [quest-flow.md](quest-flow.md).

**Purpose:** Shift the journey from surviving alone toward recognizing the value of shared knowledge.

- Approach: rocky foothills and former extraction paths that remain part of the forest-and-mountain mainland.
- Dungeon identity: mineral-lit chambers, worn mining structures, and safe rest pockets between encounters.
- Boss identity: Golem Bara. Proposed lesson: alternate between avoiding heavy attacks and exploiting recovery windows.
- Reward: Getah Bara, ingredient 3 of 7.
- Story beat: a proposed miner's note explains a practical route or hazard. Arka succeeds by listening to someone else's experience.
- Follow-up: a journal annotation directs Arka through Desa Wana Sela toward the highland crossing. Sekar introduces the missing scout; no return to Darma is required to obtain the lead.

Suggested quest title: **What the Mountain Keeps**.

## Dungeon 4 — Menara Angin

Main quest: `main_07_dungeon_04`. Regional detours and optional rewards are listed in [quest-flow.md](quest-flow.md).

**Purpose:** Mark the emotional midpoint: Arka is stronger, but the distance from home is becoming real.

- Approach: Desa Wana Sela provides rest, repairs, and Sekar's missing-scout lead. Arka encounters Damar at the ravine lookout along the main route, then continues toward the bridge and tower. Tool recovery and shelter maintenance are optional local quests, not crossing requirements.
- Dungeon identity: broken tower levels and sheltered passages. Any apparent height change must work within the game's chosen top-down movement system; platform jumping is not assumed.
- Boss identity: Rajawali Batu. Proposed lesson: recognize approach patterns and reposition rather than chase constantly.
- Reward: Bunga Langit, ingredient 4 of 7.
- Story beat: a letter carried through Wana Sela or an optional home visit reminds Arka of specific people waiting for him. Ratih's words renew his promise without making the next destination a mere order.
- Follow-up: the route opens toward Danau Senja.

Suggested quest title: **Beyond the Bridge**.

## Dungeon 5 — Kuil Senja

Main quest: `main_08_dungeon_05`. Regional detours and optional rewards are listed in [quest-flow.md](quest-flow.md).

**Purpose:** Deepen Arka's understanding of the cure and the land.

- Approach: a highland lake basin, weathered paths, and a portal inside an easily distinguished ruin.
- Dungeon identity: flooded courtyards and quiet stone halls, with a restrained navigation puzzle between combat sequences.
- Boss identity: Ular Senja. Proposed lesson: balance threat awareness and timing against a mobile enemy.
- Reward: Akar Senja, ingredient 5 of 7.
- Story beat: an inscription can explain why all seven ingredients must be prepared together. If the optional illness-origin mystery is adopted, this is an appropriate place to connect previously observed clues.
- Follow-up: the journal points toward the cold mountain pass and encourages preparation.

Suggested quest title: **The Recipe Remembered**.

## Dungeon 6 — Benteng Kabut

Main quest: `main_09_dungeon_06`. Regional detours and optional rewards are listed in [quest-flow.md](quest-flow.md).

**Purpose:** Turn late-game progress into a feeling of responsibility rather than invulnerability.

- Approach: cold ridges, wind-sheltered camps, and paths marked by lanterns or other readable landmarks.
- Dungeon identity: ruined fortress passages with limited visibility balanced by consistent navigation cues. Do not make progression depend on wandering blindly through identical rooms.
- Boss identity: Penjaga Kabut. Proposed lesson: distinguish real attack cues from misleading movement while retaining fair telegraphs.
- Reward: Biji Fajar, ingredient 6 of 7.
- Story beat: Arka learns the final route and makes a deliberate choice to continue. Village dialogue shows that the community is preparing supplies and a treatment area for his return.
- Follow-up: reveal the summit gateway and a safe shortcut back to lower regions.

Suggested quest title: **A Light in the Pass**.

## Dungeon 7 — Jantung Niskala

Main quest: `main_10_dungeon_07`. Regional detours and optional rewards are listed in [quest-flow.md](quest-flow.md).

**Purpose:** Pay off Arka's growth and the promise that began the journey.

- Approach: the most dangerous mainland region, with regular monster levels no higher than 99. Provide a clear preparation checkpoint before the portal.
- Dungeon identity: ancient stone and deep roots beneath the mountain, combining familiar navigation ideas rather than introducing an unlearned movement mechanic at the end.
- Boss identity: Jantung Kelam, level 100. Proposed lesson: combine positioning, timing, recovery management, and encounter reading learned from earlier guardians.
- Reward: Sari Niskala, ingredient 7 of 7. The reward is guaranteed and cannot be lost on the way out.
- Story beat: Arka finishes the task that once seemed beyond him. If the source-of-illness lore is adopted, the battle prevents further corruption, but the village still needs the completed remedy.
- Follow-up: unlock an exit or shortcut and set the main objective to return to Kamboja. No eighth dungeon or surprise ingredient is needed.

Suggested quest title: **Bring the Dawn Home**.

## Experience and difficulty guidance

- Introduce enemies near the low end of a region's band along safer approaches, with stronger encounters farther from the main path or near the portal.
- Keep region difficulty authored and readable. Avoid automatically scaling every monster to Arka, which would undermine the feeling of gradual growth.
- Main-route combat, required discoveries, and main/boss rewards should support reasonable progress toward the next recommended range without side quests. Optional encounters and quests provide extra preparation and flexibility rather than filling a mandatory XP deficit. Exact values still require balance testing.
- Treat the proposed level bands and boss levels as a progression framework, not a completed XP curve. Encounter counts and experience awards must be balanced together before claiming that the route supports these levels without grinding.
- The last boss being level 100 is an enemy milestone. It does not establish a player level cap or require a level-100 Arka.

## Portal and reward rules

1. Each mainland portal leads to one corresponding dungeon and records a return point.
2. Discovering a later portal can reveal its name and warning even before its main-story activation.
3. The proposed main-story sequence activates portals in order as previous ingredients are recorded. Do not lock players inside a dangerous future region simply because its portal is inactive.
4. Entering a portal does not remove the ability to retreat before a boss battle.
5. Defeating a boss records both its completion and unique ingredient. Use a guaranteed quest reward rather than a random drop chance.
6. Returning to the mainland or reloading must not undo a completed reward. Full ordinary inventory space must not prevent ingredient collection.
7. Cleared dungeons may remain visitable, but unique quest rewards do not duplicate. Optional repeatable enemies must not imply that the same story boss repeatedly dies in canon.
8. Finishing dungeon 7 sets the return-home objective. Cure preparation becomes available after all seven unique ingredients are recorded.

## Distinction between mainland and dungeon encounters

The requirement that wilderness monsters stop at level 99 applies to ordinary main-map encounters. Dungeons may use encounters appropriate to their chapter; this draft reserves the explicit level-100 milestone for the final boss. Additional enemy caps, elite variants, and repeatable challenge modes require a later balance decision.
