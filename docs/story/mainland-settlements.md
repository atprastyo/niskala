# Mainland settlements — Regional quest hubs

Status: planning draft, not implemented game content. The story plan now includes two smaller mainland settlements alongside Kamboja. Names, dialogue, rewards, and precise map coordinates remain adjustable.

See [quest-flow.md](quest-flow.md) for quest IDs, objectives, prerequisites, and progression rules.

The [mainland island map plan](mainland-map-plan.md) proposes Kamboja inland from the southwest bay shore, Tirta near the southeastern estuary, and Wana Sela on a central foothill terrace. These are geographic anchors rather than final tile coordinates.

## Roles and route

Kamboja remains Arka's home, the origin of his promise, and the location of the final cure. Other settlements give him people to help and places to recover without replacing that central relationship.

```mermaid
flowchart LR
    K[Kamboja: home and clinic] --> F[Hutan Embun: dungeon 1]
    F --> T[Desa Tirta: wetland hub]
    T --> D2[Rawa Bisu: dungeon 2]
    D2 --> D3[Lereng Bara: dungeon 3]
    D3 --> W[Desa Wana Sela: foothill hub]
    W --> D4[Jurang Angin: dungeon 4]
    D4 --> D5[Danau Senja: dungeon 5]
    D5 --> D6[Punggung Kabut: dungeon 6]
    D6 --> D7[Puncak Niskala: dungeon 7]
    D7 --> R[Return to Kamboja: craft the cure]
```

This diagram shows story order, not exact distances or a requirement to walk the entire route again. Settlements and cleared regions should have convenient return paths. High mountain regions use small checkpoints or camps rather than additional full villages in the initial scope.

| Settlement | First intended visit | Initial content scope | Regional main-story thread |
| --- | --- | --- | --- |
| Kamboja | Opening | Existing village cast and five optional quests spread over the journey | Permission, departure, return, and cure |
| Desa Tirta | After dungeon 1, before dungeon 2 | Four named NPCs, one integrated regional main quest, two optional quests | `main_05_dungeon_02`: A Path Above the Water |
| Desa Wana Sela | After dungeon 3, before dungeon 4 | Four named NPCs, one integrated regional main quest, two optional quests | `main_07_dungeon_04`: Beyond the Bridge |

The regional main quests are chapters of the existing seven-dungeon chain, not extra dungeons or a new set of mandatory fetch quests. Village services, portal activation, and unique ingredient rewards never require completing local side quests.

## Desa Tirta

A small fishing settlement at the forest-wetland boundary of Rawa Bisu. Raised homes, a public water point, fishing platforms, and a compact trading shelter distinguish it from Kamboja.

Place its rest point and merchant near the through-route. A lookout should frame the wetland standing stones so the player connects local directions to a visible landmark.

| NPC | Station | Role | Quest connection |
| --- | --- | --- | --- |
| **Sena** | Meeting platform beside the trading shelter | Elder and settlement leader | Explains the raised trail toward Sumur Rawa; gives local traveling stories |
| **Nala** | Public water point and small care station | Caretaker who organizes water and rest supplies | Offers `sq_tir_01`, Water for Every Home |
| **Danu** | Fishing platforms and repair bench | Fisher and boat repairer | Offers `sq_tir_02`, What the River Took |
| **Suri** | Trading shelter | Merchant and keeper of traveler messages | Supplies, ordinary equipment, and delivery of home letters |

### Main-story visit

Arka hears from Sena that creatures are making the raised trail dangerous. Following the main route, he deals with an authored encounter, reaches the standing stones, and enters dungeon 2. Local dialogue explains why people cannot simply retrieve Lumut Nadi themselves.

Arka can learn the same essential landmark from his main journal if he misses Sena's conversation. Helping the water point and retrieving Danu's nets are separate optional activities, not concealed entrance requirements.

### Local identity and payoff

Tirta's problem is disrupted access to water and fishing grounds. Repairing its water point restores an everyday service, not the cure for Demam Layu. A resident can show a familiar symptom as an optional story hint; do not confirm a shared illness source unless the wider mystery is adopted.

Main progress and local help change different things: defeating the dungeon boss marks Arka's ingredient progress, while the water quest changes the water point and NPC conversations. Neither flag should falsely complete the other.

## Desa Wana Sela

A farming and mining settlement along the foothill route between Lereng Bara and Jurang Angin. Terraced plots, timber sheds, stone retaining walls, and a small forge give it a distinct silhouette.

Use it as a midpoint rest stop. The ravine route leaves from one clearly marked side of the settlement, with the mountain skyline signaling the journey ahead.

| NPC | Station | Role | Quest connection |
| --- | --- | --- | --- |
| **Sekar** | Communal granary and meeting yard | Settlement leader and farmer | Explains the bridge route and the missing scout's last known position |
| **Wira** | Forge beside the trading yard | Smith and tool repairer | Offers `sq_wan_01`, Tools Left Behind |
| **Damar** | Initially the ravine lookout; later the route board | Scout | Encountered on the main dungeon-4 approach; gives directions and traveling stories |
| **Intan** | Granary loading area | Farmer and supply carrier | Offers `sq_wan_02`, Shelter at the Pass |

### Main-story visit

Sekar is concerned because Damar has not returned from inspecting the ravine crossing. Arka finds Damar sheltering at a lookout on the direct route to dungeon 4. The encounter provides a clear view of the tower and practical route advice. Do not require a long escort, a rare item, or completion of forge errands to continue.

Finding Damar is a main-route story beat, not a third optional settlement quest. If Arka takes a valid alternate route first, journal and encounter flags reconcile when he reaches the landmark; the game must not force a redundant search after the boss is defeated.

### Local identity and payoff

The forge and granary show how travel danger affects ordinary work. Optional tool recovery improves convenience and equipment choices. Optional pass maintenance opens a useful resting shortcut. Baseline repairs, normal travel, and equipment sufficient for the main route remain available without either side quest.

Ratih's midpoint letter can reach Arka through the settlement's travelers. Reading it is a short character moment, not a new delivery quest requiring a trip back to Kamboja.

## Shared hub rules

- Each new hub offers one regional main-story thread and two optional quests. Avoid expanding every named NPC into a separate quest chain.
- Discovering a settlement opens its baseline rest, merchant, and return-route services. Do not hide essential preparation behind reputation or optional quest completion.
- Helping residents awards experience, ordinary supplies, equipment options, shortcuts, or relationship scenes. Only the seven dungeon bosses award the seven medicinal ingredients.
- Kamboja's Genta and Ningsih remain useful; regional vendors provide convenience and local flavor rather than making home services obsolete.
- Required clinic and preparation information remains available in Arka's journal. Missing a particular hub conversation cannot permanently block the main story.
- Track the eight new NPCs as unique characters. Damar's location changes after his lookout encounter; do not spawn a second copy at the village simultaneously.
- Some residents may show early symptoms, but this draft still ends with the cure crafted for Kamboja. Treatment of other settlements after the ending is a possible epilogue extension, not another required objective or a claim that they are already cured.
