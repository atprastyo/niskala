# Encrypted local saves

The storage foundation is implemented in `lib/storage/save_repository.dart` and `lib/storage/native_save_files.dart`. The native menu offers New Game and Continue; `SavedGame` provides manual Save at entrance and Menu controls. Continue restores player stats/resources at the saved area’s named entrance and resets encounters and map objects. The Travel prototype also supports returning to its village, wilderness, or dungeon entrance. Exact position, collected keys/potions, enemy deaths, and quest state are not persisted yet. This is an explicit sandbox checkpoint prototype, not full campaign persistence.

New Game creates an in-memory session without immediately replacing an existing save. Choosing Save at entrance records the current named entrance as the checkpoint and writes the single save slot; failed writes restore the earlier checkpoint. Menu returns without autosaving. Defeat recovery in the menu-hosted game retains the same session and returns to the checkpoint with full health/stamina and no XP/item penalty. A missing checkpoint ID uses the registered fallback; failed loading preserves the defeated scene and provides Retry recovery. Successful checkpoint recovery automatically saves the restored state. Continue rejects dead players. It resolves map/spawn IDs through the registry; an unavailable location falls back to a valid checkpoint, then the sandbox entrance, with a visible recovery notice. Character and campaign data are retained; Continue’s location fallback does not itself write the disk save. Failed storage loads display an error and do not replace progress.

After a successful map transition, the native game automatically saves the committed destination, return records, and session state. Failed transitions do not save. Automatic saving does not change the established checkpoint; only Save at entrance does. While a write is pending, additional travel, saving, and Menu are disabled. Gameplay may continue in the loaded scene. A write failure leaves that scene active and shows Retry save; retry captures the latest valid session without changing the checkpoint. A successful automatic or manual save clears that retry notice. No automatic save occurs just from opening New Game or Continue. A fresh adventure will replace the single save slot after its first successful travel, recovery, or manual save.

Web retains New Game without save controls; a conditional factory keeps native file imports out of the browser build. The native repository is initialized lazily when entering a game or continuing. Setup or load failures display a retryable error; key access during manual saving is also reported without leaving the game.

Continue now preflights the current location's map, external tileset JSON, and decoded image before opening the game. Missing or corrupt assets fall back to the saved checkpoint, then the registered safe entrance. If all candidates fail, Continue reports failure and retains the original save. Manual saving is also disabled until the initial scene reports ready.

## Format and key ownership

Each version-1 envelope contains a version, random 12-byte nonce, ciphertext, and authentication tag. AES-256-GCM authenticates the encrypted versioned session payload and the fixed format identifier. Keys are randomly generated and held separately by `flutter_secure_storage` under `niskala_save_key_v1`. No plaintext save or plaintext temporary file is written.

The encrypted payload contains level, XP, current health/stamina, map/spawn/checkpoint IDs, claimed reward IDs, and versioned campaign records. Older version-1 payloads without reward claims or campaign records load with empty defaults. Unknown versions, invalid resource bounds, invalid IDs, and inconsistent XP are rejected. The registry checks map/spawn existence when continuing; asset-load failure and collision-free arrival verification remain future work.

Campaign records hold ordinary inventory quantities, owned equipment references, quest/interaction facts, discoveries, completed quest IDs, boss/ingredient ownership, habitat cooldown seconds, and named return map/spawn pairs. Ingredients remain separate from ordinary consumable inventory. Duplicate boss/ingredient assignments, negative cooldowns, invalid quantities, and unowned equipment references are rejected. Cooldown records do not run a clock; prototype map transitions record the source return entrance after a successful load. Existing sandbox potions/keys and encounters still reset on Continue because their actors do not yet emit campaign events.

Discovered locations are a map-ID → spawn-ID set in campaign records. The initial ready scene, successful travel/recovery, and validated checkpoints record arrivals. Failed loads do not discover their destinations. Older version-1 campaign records without this optional field remain compatible.

Enemy reward IDs identify one spawned life. A repeated defeat notification for that life cannot award XP again after loading. Current sandbox loading still creates fresh enemy lives and resets encounters. Persistent populations and claim retention/pruning for a large campaign remain future work; claims currently accumulate in the save.

Keep one repository instance per slot. Its queue serializes reads, key creation, and writes; it does not provide cross-process locking. Only one application process should own the slot. Saves capture the state at the time the request is made.

## Native use

Call `createNativeSaveRepository()` after Flutter binding initialization and retain the result. The menu retains one instance for the active route. Use `await repository.save(session)` at an explicitly chosen stable checkpoint. `await repository.load()` returns null for an empty slot or a `LoadedSave` with the session and a backup-recovery flag. Show a recoverable error when storage/key access fails; never silently start a new campaign or overwrite data on load failure.

Files `campaign.enc` and `campaign.backup.enc` live in the application-support directory. Writes flush encrypted bytes to a neighboring temporary file and rename it over the destination. A validated previous primary is written to backup before replacement. Rename behavior must be verified on each release platform; this does not guarantee survival of every filesystem/power failure.

Missing keys are not regenerated while either save file exists. Recovery never deletes the original files. With no valid copy, saving also fails rather than silently replacing unreadable progress. An explicit reset/export recovery interface remains future work.

## Platform setup and limits

- macOS uses the non-data-protection Keychain option documented by the plugin, avoiding a Keychain Sharing provisioning requirement for this standalone app. Real Keychain behavior still needs a signed-device smoke test.
- Android automatic backup is disabled to avoid restoring encrypted files without their device-bound keys. Verify device-transfer policy and secure-storage behavior on a representative release device. Secure storage requires Android API 23 or newer.
- iOS signing/Keychain capabilities and native Windows/Linux packaging dependencies still need release-platform verification.
- The native file adapter uses `dart:io`; browser storage is not implemented. `save_factory.dart` selects a native or unsupported-browser implementation through a conditional export.
- Copying save files alone to another device will not restore progress. Key loss makes them unreadable. No cloud sync, cross-device export, anti-rollback protection, or anti-cheat guarantee is provided.

Package configuration references: [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) and [cryptography](https://pub.dev/packages/cryptography).

## Verification

Tests use actual temporary encrypted files and an in-memory key-store substitute. They cover round trips, plaintext absence, fresh nonces, encrypted backups, ciphertext tampering, recovery, missing keys, concurrent requests, and invalid state. These tests do not exercise the OS Keychain/Keystore plugin.

The Continue widget test reconstructs the menu and repository twice, reads real encrypted files, verifies progression/inventory/ingredients/discovered entrances/return records, travels and autosaves, then continues again. This simulates application reconstruction; it does not claim an actual OS process restart or platform-key-store smoke test.
