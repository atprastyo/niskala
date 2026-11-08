# Three-map travel prototype

Select **Travel prototype** from the main menu. This creates a separate in-memory session at `prototype_village/start`; it replaces the existing single-slot save after the first successful travel, recovery, or manual save. **New Game** continues to open the original development dungeon.

Walk onto the cyan **Forest** portal on the right. In the wilderness, **Village** is on the left and **Dungeon** on the right. The dungeon's left **Forest** portal returns to the wilderness's dungeon entrance. These small enclosed rooms deliberately use existing dungeon tiles as blockout art; they are not the production Kamboja, Hutan Embun, or first story dungeon.

Maps have no enemies or NPCs. They exercise loading, collision boundaries, named arrival points, return routes, and session retention. Use arrows and Shift with keyboard controls, or the existing joystick. Save at entrance and Continue retain the current area and its named entrance, not exact position.

## Lifecycle

`MapTravel` resolves exits from the authoritative registry and serializes requests. It commits the new location and return record only after the host reports successful loading. `SavedGame` pauses the source, preflights destination JSON, and keeps the source mounted until the destination's ready callback. A 15-second readiness timeout discards the candidate and resumes the source. Input and Save/Menu buttons remain disabled during travel; keyboard focus returns after commit or rollback.

Portals only fire once per contact, have a one-second grace after construction, and are separated from arrival points. A failed portal requires leaving its contact area before retrying. Exits can require a campaign fact; prototype routes currently require none. Save at entrance establishes the current named entrance as the checkpoint. After defeat, Play Again reloads that checkpoint while retaining progression and campaign records and refilling health/stamina. Failed recovery leaves the old scene intact and offers Retry recovery. Unknown checkpoint IDs use the registry fallback. Only New Game or Travel prototype starts a fresh session.

Only stable location records and campaign state are persisted. Encounter actors reset when scenes are reconstructed. Successful travel and defeat recovery automatically save on native platforms. These saves retain the previous checkpoint unless Save at entrance is used. A failed automatic save keeps the current scene active and offers Retry save; failed loads do not trigger saving. No streaming, target-device loading budget, or production outdoor art is introduced.
