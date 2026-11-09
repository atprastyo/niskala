import 'package:niskala/model/game_session.dart';
import 'package:niskala/model/map_registry.dart';
import 'save_repository.dart';

class ContinuedGame {
  final GameSession session;
  final bool recoveredFromBackup;
  final bool relocated;
  ContinuedGame(
    this.session, {
    required this.recoveredFromBackup,
    required this.relocated,
  });
}

class ContinueGame {
  final MapRegistry registry;
  final Future<void> Function(MapDestination) validate;
  ContinueGame(this.registry, this.validate);

  /// Reads without writing. Do not replace progress when no location can load.
  Future<ContinuedGame?> load(SaveRepository repository) async {
    final loaded = await repository.load();
    if (loaded == null) return null;
    final session = loaded.session;
    if (session.health <= 0) {
      throw const SaveException('Saved player is defeated.');
    }
    final candidates = [
      (session.currentMapId, session.currentSpawnId),
      (session.checkpointMapId, session.checkpointSpawnId),
      (registry.fallback.mapId, registry.fallback.spawnId),
    ];
    final attempted = <String>{};
    for (final location in candidates) {
      if (!attempted.add('${location.$1}/${location.$2}')) continue;
      MapDestination destination;
      try {
        destination = registry.resolve(location.$1, location.$2);
        await validate(destination);
      } catch (_) {
        continue;
      }
      final relocated =
          session.currentMapId != destination.map.id ||
          session.currentSpawnId != destination.spawnId;
      session.currentMapId = destination.map.id;
      session.currentSpawnId = destination.spawnId;
      return ContinuedGame(
        session,
        recoveredFromBackup: loaded.recoveredFromBackup,
        relocated: relocated,
      );
    }
    throw const SaveException(
      'No saved location can be loaded; existing data preserved.',
    );
  }
}
