import 'dart:math';

/// One spawned life, not an enemy type or a reusable habitat/group ID.
class EnemyDefeated {
  final String lifeId;
  final int experience;
  const EnemyDefeated({required this.lifeId, required this.experience});

  String get rewardId => 'enemy_$lifeId';

  static String newLifeId() {
    final random = Random.secure();
    return List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
  }
}

class ExperienceGrant {
  final bool accepted;
  final int levelsGained;
  const ExperienceGrant(this.accepted, this.levelsGained);
}
