# Niskala — Main story design

Status: Draft 2 for review; includes regional settlements and a detailed quest catalog. This document plans future story content; it does not describe features already implemented in the game.

## 1. Story foundation

### Established requirements

- Arka is the protagonist. His adventure begins in Kamboja Village, his home village.
- An illness is spreading among the villagers. Arka seeks medicinal ingredients to create a cure.
- Kamboja includes homes, a place of worship, an educational facility, a clinic, agricultural fields, livestock pens, and a marketplace. A village chief leads the community, and NPCs populate these locations.
- The village chief provides guidance. Arka asks his mother for permission before departing.
- Beyond the village is a wilderness main map inhabited by monsters from level 1 through level 99. Arka defeats monsters and gradually levels up.
- Particular mainland locations contain portals into seven dungeons. Each dungeon contains monsters and a boss and corresponds to a stage of progression.
- Each boss rewards exactly one of the seven medicinal ingredients. The final dungeon boss is level 100.
- After obtaining all seven ingredients, Arka returns to Kamboja, crafts the cure for the villagers, and the game concludes.

Names other than Arka and Kamboja, the illness lore, dialogue, region layout, numerical progression, and quest details below are proposals. They can change without changing the established story.

The expanded mainland plan includes two smaller quest hubs: **Desa Tirta** near dungeon 2 and **Desa Wana Sela** near dungeon 4. Kamboja remains the home village and final cure location. See [mainland-settlements.md](mainland-settlements.md) for their cast and [quest-flow.md](quest-flow.md) for the complete main and side quest list.

The mainland setting is one large island with forests, many mountains, freshwater lakes, a large bay, and ocean surrounding its coastline. [Mainland map plan](mainland-map-plan.md) proposes how the existing villages and dungeon regions fit this geography without adding required quests.

### Proposed logline

As a mysterious fever spreads through Kamboja Village, Arka follows an old healer's recipe beyond the safety of home. Across forests, ravines, and mountains, he must overcome seven dungeon guardians and gather the ingredients that can bring his community back to health.

### Tone and themes

A hopeful adventure with danger and moments of grief, grounded in family and community. Arka's goal is to bring people home to ordinary life, rather than to acquire power for its own sake.

Core themes are responsibility, courage learned through experience, cooperation, and the relationship between a community and the land that sustains it. Maintain a contrast between Kamboja's warmth and the wilderness's increasing danger.

## 2. Proposed illness and cure logic

Working name: **Demam Layu**, or the Withering Fever. It causes fatigue, fever, and a gradual loss of strength. This is fictional worldbuilding, as are the seven named ingredients; their preparation is a game ritual rather than a real medical recipe.

The village clinic can ease symptoms but cannot cure the illness with its remaining supplies. Chief Darma preserves a record describing a seven-ingredient remedy. He brings it to healer Lestari, who identifies the ingredients and confirms the preparation method. Darma knows the old routes; Lestari establishes the medical objective.

The seven ingredients grow or form inside isolated dungeon environments. Each guardian controls access to its ingredient's source. Defeating that boss yields the ingredient directly as a guaranteed quest reward. The ingredients remain stable in Lestari's sealed satchel until Arka returns.

All seven are necessary: identifying early ingredients helps the clinic plan, but they remain protected in the satchel and no partial combination resolves the village illness. Arka does not need to guess a recipe or sacrifice a unique quest ingredient while experimenting.

A possible explanation for the illness's origin is described under optional story improvements. It is not an established requirement.

## 3. Main story stages

| Stage | Main objective | Required story result |
| --- | --- | --- |
| Prologue: A village growing quiet | Arrive in Kamboja, meet its people, and see the clinic | Establish Arka's home and the illness |
| Chapter 1: Permission to leave | Speak with Darma and Lestari, then ask Mother Ratih | Obtain guidance, permission, and the ingredient journal |
| Chapter 2: Beyond the fields | Leave through the village gate; learn exploration and combat | Reach the first dungeon portal |
| Chapters 3–9: Seven journeys | Explore each region, gain experience, enter its dungeon, defeat its boss | Obtain one unique ingredient per boss, reaching seven total |
| Final chapter: The road home | Return to Kamboja after the level-100 boss | Deliver the complete ingredient collection |
| Ending: A morning restored | Prepare and distribute the cure | Resolve the illness and conclude the game |

### Prologue — A village growing quiet

The player takes control of Arka at the entrance to Kamboja's central lane, arriving home from the nearby fields. This makes his arrival an ordinary return to his own village, not the arrival of a stranger.

Introduce the settlement through small, visible changes: a quiet marketplace, unattended farm work, and fewer pupils at the learning house. These details establish concern without making the entire village immediately inaccessible.

A short conversation with neighbor Rukmini directs Arka toward the clinic. There he meets Lestari and an ill pupil, Tama, accompanied by teacher Mira. Arka learns that this is affecting people he knows, not an abstract population.

Required interactions should be brief. Visiting every house and speaking to every NPC is optional. The player should be able to reach the expedition decision without completing a long chain of errands.

### Chapter 1 — Permission to leave

1. Lestari explains the clinic's limitations and asks Arka to speak with Darma.
2. Darma shows Arka the old remedy record and marks the first wilderness route. He explains that there are seven dungeon sources, not seven ordinary market ingredients.
3. Arka returns to Lestari, who supplies a journal and a sealed ingredient satchel.
4. Arka visits his home and asks Ratih for permission. She understands the danger but recognizes his resolve. He promises to return, and she asks him to remember that accepting help is part of being brave.
5. Gatekeeper Bayu reviews supplies and opens the village departure route.

Suggested quest title: **A Promise at the Door**.

Sample dialogue, proposed:

> Ratih: “I cannot make the road safe for you. But promise me you will not mistake being alone for being strong.”
>
> Arka: “I will ask for help when I need it. And I will come home.”

Ratih grants permission before the first departure. Later village visits do not require repeating this permission sequence.

### Chapter 2 — Beyond the fields

The village outskirts provide the first low-level encounters, recovery resources, and navigation landmarks. The route begins with open sightlines and space to retreat. Stronger creatures are clearly signaled before the player reaches dangerous regions.

Arka learns movement, attacks, recovery, equipment, leveling, and the difference between an ordinary cave and a dungeon portal. The journal identifies the first portal using a landmark description rather than relying only on a floating marker.

Suggested quest title: **Beyond the Last Fence**.

### Chapters 3–9 — The seven dungeon journeys

See [dungeon-progression.md](dungeon-progression.md) for each region, boss, ingredient, recommended level, and proposed story beat.

The repeated gameplay loop is:

1. Explore a new mainland region and discover its portal landmark.
2. Defeat monsters, improve equipment, and learn the region's combat challenge.
3. Enter the dungeon and reach its boss through encounters and navigation challenges.
4. Defeat the boss and receive its unique ingredient automatically.
5. Record the ingredient in the journal, reveal the next lead, and unlock a safe return route.

Give each chapter a different emotional or exploration question, so the story does not feel like seven identical fetch quests. Regional details in the progression document are suggestions for achieving this.

Arka may revisit Kamboja between chapters to speak with Ratih, report to Lestari, restock, and see changing village dialogue. These visits support the journey but do not replace the final return with all seven ingredients.

Two regional settlements give this journey breathing room. After dungeon 1, Desa Tirta introduces wetland residents and the raised trail to dungeon 2. After dungeon 3, Desa Wana Sela introduces the missing scout and the crossing toward dungeon 4. Each settlement has four named NPCs, one regional main-story thread integrated into its dungeon quest, and two optional quests. Their ordinary services are available on discovery; no reputation grind or side-quest checklist unlocks the next ingredient.

Optional help should reinforce Arka's compassion and preparation. It can reward supplies, equipment choices, experience, shortcuts, and relationships, but never one of the seven medicinal ingredients. Main-route progression must remain viable for players who skip all side quests.

### Final chapter — The road home

After the seventh guardian falls, the journal confirms all seven ingredients. The immediate objective becomes **Return to Kamboja Village**.

Provide an unlocked exit or return shortcut. Do not require a second long traversal of the final dungeon or an unrelated eighth boss. Arka's return should carry the feeling of bringing something precious home.

Ratih meets Arka near the village entrance. Darma gathers volunteers, while Lestari prepares the clinic. A final short conversation acknowledges the cost and effort of the journey before preparation begins.

### Ending — A morning restored

At the clinic, Lestari guides Arka through a short, clearly prompted preparation sequence using all seven ingredients. The objective is to complete his journey, not to test an unexplained recipe mechanic. Incorrect input should retry the step without destroying ingredients.

Arka completes the cure. Village volunteers distribute it, and a short passage of time allows recovery to feel believable within the fiction. The ending shows familiar places returning to life: children at lessons, reopened market stalls, farmers tending fields, and neighbors gathering at the place of worship.

Ratih and Arka share a quiet final conversation at home, paying off his promise. Darma thanks him in the village square, but the last image focuses on ordinary village life rather than only on a public reward.

The main story ends with the village cured and the seven-dungeon quest complete. Roll credits and mark the save as completed. Post-game exploration, sequels, and alternate endings are outside the current required scope.

## 4. Quest and progression rules

Use stable quest identifiers so later implementation can separate story progress from presentation:

| Quest ID | Completion condition | Next objective |
| --- | --- | --- |
| `main_01_village` | Meet the clinic and chief | Prepare the expedition |
| `main_02_permission` | Receive guidance, journal, and Ratih's permission | Depart Kamboja |
| `main_03_departure` | Leave the village and discover portal 1 | Complete dungeon 1 |
| `main_04_dungeon_01` through `main_10_dungeon_07` | Defeat the corresponding boss and record its ingredient | Next dungeon, or return home after dungeon 7 |
| `main_11_return` | Reach the clinic with all seven ingredients | Prepare the cure |
| `main_12_cure` | Complete preparation and distribution scene | Ending and completion save |

These are proposed identifiers, not existing code or implemented save fields. [Quest catalog and progression flow](quest-flow.md) defines all 12 main quests and 11 optional side quests, including exact prerequisite IDs, objective sequences, and reward purposes. It is the authoritative quest list; regional settlement threads remain within `main_05_dungeon_02` and `main_07_dungeon_04`.

Progression principles:

- Regular wilderness monsters range from level 1 to 99. The final boss is explicitly level 100.
- Arka gains experience by defeating monsters; main quests and discoveries may also award experience to reduce repetitive grinding.
- The proposed level bands are balancing targets, not a requirement to reach a precise level before each boss. In particular, reaching player level 100 must not be required to challenge the final boss.
- The seven main dungeons follow the listed story order. Players may explore accessible mainland routes ahead of time, but the next main portal becomes active after the preceding ingredient is recorded. Exact portal-gating fiction is a later design decision.
- Dungeon bosses each award one distinct ingredient. Record boss defeat and ingredient ownership together so the reward cannot be lost through an interrupted return or a full inventory.
- Quest ingredients use dedicated inventory entries, cannot be sold or consumed in normal crafting, and survive defeat. Re-entering a cleared dungeon cannot generate a second unique ingredient.
- Defeat returns Arka to a safe checkpoint without resetting completed bosses or collected ingredients. Any other defeat penalty is a separate balancing decision.
- Every portal has a return location on the mainland. Clearing a dungeon unlocks a convenient exit.
- Narrative urgency does not imply a hidden countdown. Exploration and optional quests must not silently kill villagers or make the cure impossible.
- Crafting requires all seven unique ingredients and final-boss completion. Earlier reports to Lestari must never consume required ingredients.
- Local side quests never gate portals, normal hub services, recipe knowledge, or the cure. Main-route combat and rewards must support progression without optional completion.
- Before preparation starts, the player may finish outstanding optional tasks. Beginning the cure starts the ending sequence; unfinished side quests are archived without changing Kamboja's recovery or implying a hidden failure timer.

## 5. Suggestions to strengthen the story

These are optional additions, not changes to the required premise or ending.

| Suggestion | Story benefit | Recommended scope |
| --- | --- | --- |
| Let village relationships change after each ingredient | Makes progress emotionally visible | High priority: one short conversation or letter per chapter |
| Give Ratih a memory or practical skill that helps Arka | Keeps his mother involved beyond granting permission | High priority: practical advice and recurring home scenes |
| Connect the illness to a wounded network beneath the forests and mountains | Gives the seven journeys a shared mystery | Optional central lore thread; reveal gradually rather than through one exposition scene |
| Portray guardians as corrupted protectors | Makes victories feel like restoration as well as conquest | Optional, with clear visual signs of corruption and recovery |
| Offer small acts of help on regional routes | Shows that Arka's compassion grows with his strength | A limited number of authored side quests, not mandatory reputation grinding |
| Have early NPC favors pay off later | Makes the community part of the cure | Optional supplies, route information, or preparation assistance |
| Vary portal discovery and dungeon structure | Prevents seven bosses from feeling interchangeable | One signature navigation or environmental challenge per region |

### Suggested mystery, if adopted

An old underground root network once carried clean water and natural energy through the mainland. A disturbance at its deepest point corrupted seven guardians and contaminated what reaches Kamboja. Each ingredient restores a different part of the remedy, while Arka's victories reveal how the environments are connected.

Foreshadow this in three steps: unusual water and plants near the first forest; related markings and symptoms in the middle regions; confirmation beneath the final mountain. The level-100 boss, proposed as Jantung Kelam, is the final manifestation of that disturbance.

Keep the cure requirement intact even with this explanation: defeating the last boss stops the source from worsening, but already ill villagers still need the remedy Arka brings home. This prevents the final battle from making the seven ingredients irrelevant.

Avoid introducing a surprise betrayal by the village chief solely to add a twist. His guidance and the mother's trust already give the story a strong human foundation.

## 6. Decisions for a later design pass

The main plot can stand without settling all production details now. Before implementation, decide:

- Arka's starting age, starting equipment, and player level cap.
- Final names and local-language versus English display conventions.
- Whether the illness-origin mystery and corrupted-guardian idea are adopted.
- Exact experience curves, combat balance, dungeon lengths, and total playtime.
- Which village interactions are voiced or animated, and which use ordinary dialogue.
- Final tile coordinates, travel distances, and streaming boundaries following the draft [mainland geography plan](mainland-map-plan.md).

## 7. Content checklist

- Kamboja's required buildings and named NPCs: [kamboja-village.md](kamboja-village.md).
- Seven regions, bosses, ingredients, and chapter beats: [dungeon-progression.md](dungeon-progression.md).
- Two regional villages, eight additional NPCs, and baseline services: [mainland-settlements.md](mainland-settlements.md).
- Main and side quest prerequisites, objectives, rewards, and flow: [quest-flow.md](quest-flow.md).
- Opening: arrival, visible illness, chief's guidance, clinic preparation, mother's permission, departure.
- Middle: wilderness leveling, seven discoverable portals, seven bosses, seven distinct ingredient rewards, and optional village return dialogue.
- Finale: level-100 boss, protected quest inventory, return home, cure preparation, distribution, recovery scenes, credits, completion save.
- Validation before release: every ingredient is obtainable, the final return is reachable, defeat cannot erase unique rewards, and cure preparation cannot soft-lock the ending.
