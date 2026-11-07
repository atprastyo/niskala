import 'dart:math';

class PlayerProgression {
  static const int maxLevel = 100;

  int level;
  int currentExp;

  PlayerProgression({
    this.level = 1,
    this.currentExp = 0,
  }) {
    level = level.clamp(1, maxLevel);
    if (currentExp < 0) currentExp = 0;
  }

  /// Calculates the experience required to reach the next level from [lvl].
  /// Returns 0 if already at or beyond [maxLevel].
  static int expToNextLevelFor(int lvl) {
    if (lvl >= maxLevel) return 0;
    // 80 * lvl^1.65 + 60 * lvl
    return (80 * pow(lvl, 1.65) + 60 * lvl).floor();
  }

  int get expToNextLevel => expToNextLevelFor(level);

  double get expProgressRatio {
    if (level >= maxLevel) return 1.0;
    final needed = expToNextLevel;
    if (needed <= 0) return 1.0;
    return (currentExp / needed).clamp(0.0, 1.0);
  }

  /// Player max life: 200 at level 1, +40 per level, up to 4,160 at level 100.
  double get maxLife => 200.0 + 40.0 * (level - 1);

  /// Player max stamina: 100 at level 1, +2 per level, up to 298 at level 100.
  double get maxStamina => 100.0 + 2.0 * (level - 1);

  /// Stamina regeneration interval (seconds per 2 stamina tick).
  /// Scales smoothly from 0.15s (13.3/s) at level 1 to 0.10s (20.0/s) at level 100.
  double get staminaRegenInterval {
    if (maxLevel <= 1) return 0.15;
    final progress = (level - 1) / (maxLevel - 1);
    return (0.15 - 0.05 * progress).clamp(0.10, 0.15);
  }

  /// Attack 1 damage: 25 at level 1, +4 per level, up to 421 at level 100.
  double get attack1Damage => 25.0 + 4.0 * (level - 1);

  /// Attack 2 finisher combo damage: 1.4x of Attack 1.
  /// 35 at level 1, up to 589.4 at level 100.
  double get attack2Damage => attack1Damage * 1.4;

  /// Fireball / ranged skill damage: 10 at level 1, +2 per level, up to 208 at level 100.
  double get skillDamage => 10.0 + 2.0 * (level - 1);

  /// Grants [amount] EXP to the player.
  /// Handles single or multiple level-ups if enough EXP is gained.
  /// Invokes [onLevelUp] for each level gained.
  /// Returns the number of levels gained.
  int gainExp(int amount, {void Function(int newLevel)? onLevelUp}) {
    if (amount <= 0 || level >= maxLevel) return 0;

    currentExp += amount;
    var levelsGained = 0;

    while (level < maxLevel) {
      final needed = expToNextLevel;
      if (currentExp >= needed) {
        currentExp -= needed;
        level++;
        levelsGained++;
        onLevelUp?.call(level);
      } else {
        break;
      }
    }

    if (level >= maxLevel) {
      currentExp = 0;
    }

    return levelsGained;
  }
}

enum EnemyTier {
  imp,
  goblin,
  miniBoss,
  boss,
}

class EnemyProgression {
  final EnemyTier tier;
  final int level;

  const EnemyProgression({
    required this.tier,
    this.level = 1,
  });

  int get clampedLevel => level.clamp(1, 100);

  double get maxLife {
    final lvlOffset = clampedLevel - 1;
    switch (tier) {
      case EnemyTier.imp:
        return (80.0 * (1.0 + 0.10 * lvlOffset)).floorToDouble();
      case EnemyTier.goblin:
        return (120.0 * (1.0 + 0.12 * lvlOffset)).floorToDouble();
      case EnemyTier.miniBoss:
        return (150.0 * (1.0 + 0.15 * lvlOffset)).floorToDouble();
      case EnemyTier.boss:
        return (200.0 * (1.0 + 0.20 * lvlOffset)).floorToDouble();
    }
  }

  double get attackDamage {
    final lvlOffset = clampedLevel - 1;
    switch (tier) {
      case EnemyTier.imp:
        return (10.0 * (1.0 + 0.08 * lvlOffset)).floorToDouble();
      case EnemyTier.goblin:
        return (25.0 * (1.0 + 0.09 * lvlOffset)).floorToDouble();
      case EnemyTier.miniBoss:
        return (50.0 * (1.0 + 0.10 * lvlOffset)).floorToDouble();
      case EnemyTier.boss:
        return (40.0 * (1.0 + 0.12 * lvlOffset)).floorToDouble();
    }
  }

  int get expBounty {
    final lvlOffset = clampedLevel - 1;
    switch (tier) {
      case EnemyTier.imp:
        return (35.0 * (1.0 + 0.12 * lvlOffset)).floor();
      case EnemyTier.goblin:
        return (60.0 * (1.0 + 0.15 * lvlOffset)).floor();
      case EnemyTier.miniBoss:
        return (250.0 * (1.0 + 0.18 * lvlOffset)).floor();
      case EnemyTier.boss:
        return (1500.0 * (1.0 + 0.20 * lvlOffset)).floor();
    }
  }
}
