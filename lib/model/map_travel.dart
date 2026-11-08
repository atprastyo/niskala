import 'campaign_state.dart';
import 'game_session.dart';
import 'map_registry.dart';

class MapTravel {
  final GameSession session;
  final MapRegistry registry;
  bool _busy = false;
  bool get busy => _busy;
  MapTravel(this.session, this.registry);

  Future<bool> travel(
    String exitId,
    Future<void> Function(MapDestination) load,
  ) async {
    if (busy || session.health <= 0) return false;
    final source = registry
        .resolve(session.currentMapId, session.currentSpawnId)
        .map;
    final exit = source.exits.firstWhere(
      (exit) => exit.id == exitId,
      orElse: () => throw ArgumentError('Unknown exit: $exitId'),
    );
    final destination = registry.resolve(
      exit.destinationMapId,
      exit.destinationSpawnId,
    );
    _busy = true;
    try {
      await load(destination);
      session.campaign.setReturnLocation(
        destination.map.id,
        TravelLocation(source.id, exit.returnSpawnId),
      );
      session.currentMapId = destination.map.id;
      session.currentSpawnId = destination.spawnId;
      return true;
    } finally {
      _busy = false;
    }
  }
}
