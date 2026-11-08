import 'progression.dart';

/// State shared by successive map actors. Contains no mounted components.
class GameSession {
  final PlayerProgression progression;
  late double health;
  late double stamina;
  String currentMapId = 'dev_dungeon';
  String currentSpawnId = 'start';
  String checkpointMapId = 'dev_dungeon';
  String checkpointSpawnId = 'start';

  GameSession({PlayerProgression? progression})
      : progression = progression ?? PlayerProgression() {
    health = this.progression.maxLife;
    stamina = this.progression.maxStamina;
  }
}
