import 'campaign_state.dart';
import 'game_session.dart';
import 'map_registry.dart';

class MapTravel {
  final GameSession session;
  final MapRegistry registry;
  bool _busy = false;
  bool get busy => _busy;
  MapTravel(this.session, this.registry);

  void setCheckpoint() {
    if (busy || session.health <= 0) {
      throw StateError('Checkpoint is unavailable');
    }
    final location = registry.resolve(
      session.currentMapId,
      session.currentSpawnId,
    );
    session.checkpointMapId = location.map.id;
    session.checkpointSpawnId = location.spawnId;
    session.campaign.recordArrival(location.map.id, location.spawnId);
  }

  Future<bool> recover(Future<void> Function(MapDestination) load) async {
    if (busy || session.health > 0) return false;
    final checkpoint = TravelLocation(
      session.checkpointMapId,
      session.checkpointSpawnId,
    );
    final destination = registry.resolveSavedLocation(
      checkpoint,
      registry.fallback,
    );
    final health = session.health, stamina = session.stamina;
    _busy = true;
    try {
      // Candidate actors need live resources at construction. Saving and other
      // travel are blocked until readiness; failure rolls these values back.
      session.health = session.progression.maxLife;
      session.stamina = session.progression.maxStamina;
      await load(destination);
      session.campaign.recordArrival(destination.map.id, destination.spawnId);
      session.currentMapId = session.checkpointMapId = destination.map.id;
      session.currentSpawnId = session.checkpointSpawnId = destination.spawnId;
      return true;
    } catch (_) {
      session.health = health;
      session.stamina = stamina;
      rethrow;
    } finally {
      _busy = false;
    }
  }

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
    if (exit.requiredFact != null &&
        !session.campaign.facts.contains(exit.requiredFact)) {
      throw StateError('Exit requirement has not been met');
    }
    _busy = true;
    try {
      await load(destination);
      session.campaign.recordArrival(destination.map.id, destination.spawnId);
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
