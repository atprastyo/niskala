import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/enemies/boss.dart';
import 'package:niskala/enemies/goblin.dart';
import 'package:niskala/enemies/imp.dart';
import 'package:niskala/enemies/mini_boss.dart';
import 'package:niskala/model/progression.dart';
import 'package:niskala/player/knight.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PlayerProgression Tests', () {
    test('Default initial stats at Level 1', () {
      final p = PlayerProgression();
      expect(p.level, 1);
      expect(p.currentExp, 0);
      expect(p.maxLife, 200.0);
      expect(p.maxStamina, 100.0);
      expect(p.attack1Damage, 25.0);
      expect(p.attack2Damage, 35.0);
      expect(p.skillDamage, 10.0);
      expect(p.expToNextLevel, 140); // 80 * 1^1.65 + 60 * 1 = 140
      expect(p.expProgressRatio, 0.0);
      expect(p.staminaRegenInterval, 0.15);
    });

    test('Stats at max Level 100', () {
      final p = PlayerProgression(level: 100);
      expect(p.level, 100);
      expect(p.maxLife, 4160.0); // 200 + 40 * 99
      expect(p.maxStamina, 298.0); // 100 + 2 * 99
      expect(p.attack1Damage, 421.0); // 25 + 4 * 99
      expect(p.attack2Damage, closeTo(589.4, 0.01)); // 421 * 1.4
      expect(p.skillDamage, 208.0); // 10 + 2 * 99
      expect(p.expToNextLevel, 0);
      expect(p.expProgressRatio, 1.0);
      expect(p.staminaRegenInterval, 0.10);
    });

    test('Single level up with callback', () {
      final p = PlayerProgression();
      int? leveledTo;
      final gained = p.gainExp(140, onLevelUp: (lvl) => leveledTo = lvl);

      expect(gained, 1);
      expect(leveledTo, 2);
      expect(p.level, 2);
      expect(p.currentExp, 0);
      expect(p.maxLife, 240.0);
      expect(p.maxStamina, 102.0);
      expect(p.attack1Damage, 29.0);
    });

    test('Multi-level up and overflow remainder', () {
      final p = PlayerProgression();
      final levels = <int>[];
      // Level 1 -> 2 needs 140 EXP
      // Level 2 -> 3 needs (80 * 2^1.65 + 60 * 2).floor() = (80 * 3.1383 + 120) = 251 + 120 = 371 EXP
      // Total needed for lv 3 = 140 + 371 = 511 EXP
      final gained = p.gainExp(550, onLevelUp: (lvl) => levels.add(lvl));

      expect(gained, 2);
      expect(levels, [2, 3]);
      expect(p.level, 3);
      expect(p.currentExp, 550 - 140 - 371);
      expect(p.expProgressRatio, greaterThan(0.0));
      expect(p.expProgressRatio, lessThan(1.0));
    });

    test('Level cap clamp at 100', () {
      final p = PlayerProgression(level: 99);
      final needed = p.expToNextLevel;
      p.gainExp(needed + 1000000);

      expect(p.level, 100);
      expect(p.currentExp, 0);
      expect(p.expToNextLevel, 0);
      expect(p.expProgressRatio, 1.0);

      // Subsequent EXP gains do nothing
      final extraGain = p.gainExp(5000);
      expect(extraGain, 0);
      expect(p.level, 100);
      expect(p.currentExp, 0);
    });
  });

  group('EnemyProgression Tests', () {
    test('Imp scaling at Level 1 and Level 10', () {
      final imp1 = EnemyProgression(tier: EnemyTier.imp, level: 1);
      expect(imp1.maxLife, 80.0);
      expect(imp1.attackDamage, 10.0);
      expect(imp1.expBounty, 35);

      final imp10 = EnemyProgression(tier: EnemyTier.imp, level: 10);
      expect(imp10.maxLife, 152.0); // 80 * 1.9 = 152
      expect(imp10.attackDamage, 17.0); // (10 * 1.72).floorToDouble() = 17
      expect(imp10.expBounty, 72); // (35 * 2.08).floor() = 72
    });

    test('Goblin scaling at Level 1 and Level 5', () {
      final gob1 = EnemyProgression(tier: EnemyTier.goblin, level: 1);
      expect(gob1.maxLife, 120.0);
      expect(gob1.attackDamage, 25.0);
      expect(gob1.expBounty, 60);

      final gob5 = EnemyProgression(tier: EnemyTier.goblin, level: 5);
      expect(gob5.maxLife, 177.0); // (120 * 1.48).floorToDouble() = 177
      expect(gob5.attackDamage, 34.0); // (25 * 1.36).floorToDouble() = 34
      expect(gob5.expBounty, 96); // (60 * 1.6).floor() = 96
    });

    test('MiniBoss and Boss scaling', () {
      final mb1 = EnemyProgression(tier: EnemyTier.miniBoss, level: 1);
      expect(mb1.maxLife, 150.0);
      expect(mb1.attackDamage, 50.0);
      expect(mb1.expBounty, 250);

      final boss1 = EnemyProgression(tier: EnemyTier.boss, level: 1);
      expect(boss1.maxLife, 200.0);
      expect(boss1.attackDamage, 40.0);
      expect(boss1.expBounty, 1500);
    });
  });

  group('Knight Leveling Integration Tests', () {
    test('Knight initializes with progression stats', () {
      final knight =
          Knight(Vector2.zero(), progression: PlayerProgression(level: 10));
      expect(knight.progression.level, 10);
      expect(knight.life.max, 560.0); // 200 + 40 * 9
      expect(knight.life.value, 560.0);
      expect(knight.stamina, 118.0); // 100 + 2 * 9
      expect(knight.attackDamage, 61.0); // 25 + 4 * 9
      expect(knight.progression.skillDamage, 28.0); // 10 + 2 * 9
    });

    test('Knight gainExp triggers level up, heals HP, and restores stamina', () {
      final knight = Knight(Vector2.zero());
      expect(knight.progression.level, 1);
      expect(knight.life.max, 200.0);

      // Damage knight and drain stamina
      knight.life.remove(50);
      knight.decrementStamina(40);
      expect(knight.life.value, 150.0);
      expect(knight.stamina, 60.0);

      // Give enough EXP to reach level 2 (needs 140)
      final levelsGained = knight.gainExp(140);
      expect(levelsGained, 1);
      expect(knight.progression.level, 2);
      expect(knight.life.max, 240.0);
      expect(knight.life.value, 240.0); // Fully restored!
      expect(knight.stamina, 102.0); // Fully restored!
      expect(knight.attackDamage, 29.0);
    });

    test('Enemy instances scale attributes based on level parameter', () {
      final gob1 = Goblin(Vector2.zero(), level: 1);
      final gob5 = Goblin(Vector2.zero(), level: 5);
      expect(gob1.life.max, 120.0);
      expect(gob1.attackDamage, 25.0);
      expect(gob1.progression.expBounty, 60);

      expect(gob5.life.max, 177.0);
      expect(gob5.attackDamage, 34.0);
      expect(gob5.progression.expBounty, 96);

      final imp1 = Imp(Vector2.zero(), level: 1);
      final imp10 = Imp(Vector2.zero(), level: 10);
      expect(imp1.life.max, 80.0);
      expect(imp10.life.max, 152.0);

      final mb1 = MiniBoss(Vector2.zero(), level: 1);
      final mb3 = MiniBoss(Vector2.zero(), level: 3);
      expect(mb1.life.max, 150.0);
      expect(mb3.life.max, 195.0);

      final boss1 = Boss(Vector2.zero(), level: 1);
      final boss2 = Boss(Vector2.zero(), level: 2);
      expect(boss1.life.max, 200.0);
      expect(boss2.life.max, 240.0);
    });
  });
}
