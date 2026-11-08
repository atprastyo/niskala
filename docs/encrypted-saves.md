# Encrypted local saves

The storage foundation is implemented in `lib/storage/save_repository.dart` and `lib/storage/native_save_files.dart`. The native menu offers New Game and Continue; `SavedGame` provides manual Save at entrance and Menu controls. Continue restores player stats/resources at the sandbox entrance and resets encounters and map objects. Exact position, collected keys/potions, enemy deaths, and quest state are not persisted yet. This is an explicit sandbox checkpoint prototype, not full campaign persistence.

New Game creates an in-memory session without immediately replacing an existing save. Choosing Save at entrance writes the single save slot. Menu returns without autosaving. Defeat starts a fresh sandbox session while retaining save controls and the existing disk save. Continue rejects dead players and unsupported map/spawn IDs rather than loading them into an arbitrary map. Failed loads display an error and do not replace progress.

Web retains New Game without save controls; a conditional factory keeps native file imports out of the browser build. The native repository is initialized lazily when entering a game or continuing. Setup or load failures display a retryable error; key access during manual saving is also reported without leaving the game.

## Format and key ownership

Each version-1 envelope contains a version, random 12-byte nonce, ciphertext, and authentication tag. AES-256-GCM authenticates the encrypted versioned session payload and the fixed format identifier. Keys are randomly generated and held separately by `flutter_secure_storage` under `niskala_save_key_v1`. No plaintext save or plaintext temporary file is written.

The encrypted payload contains level, XP, current health/stamina, and map/spawn/checkpoint IDs. Unknown versions, invalid resource bounds, invalid IDs, and inconsistent XP are rejected. Location existence must still be checked by the future map registry.

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
