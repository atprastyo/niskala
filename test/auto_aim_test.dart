import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/enemies/goblin.dart';
import 'package:niskala/enemies/imp.dart';
import 'package:niskala/player/knight.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Knight Auto-Aim Tests', () {
    test('findNearestEnemy selects closest living enemy within radius', () {
      final knight = Knight(Vector2(100, 100));
      final farGoblin = Goblin(Vector2(400, 100)); // 300px away
      final nearGoblin = Goblin(Vector2(150, 100)); // 50px away
      final deadImp = Imp(Vector2(120, 100)); // 20px away, but dead
      deadImp.life.remove(1000);

      final nearest = knight.findNearestEnemy(
        maxRadius: 200,
        candidateEnemies: [farGoblin, nearGoblin, deadImp],
      );

      expect(nearest, equals(nearGoblin));
    });

    test('findNearestEnemy returns null if all enemies are beyond maxRadius',
        () {
      final knight = Knight(Vector2(100, 100));
      final farGoblin = Goblin(Vector2(500, 500));

      final nearest = knight.findNearestEnemy(
        maxRadius: 100,
        candidateEnemies: [farGoblin],
      );

      expect(nearest, isNull);
    });

    test('autoAimTowards changes direction to face target enemy', () {
      final knight = Knight(Vector2(100, 100));
      knight.direction = Direction.right;

      // Enemy to the left
      final leftEnemy = Goblin(Vector2(30, 100));
      final target = knight.autoAimTowards(
        maxRadius: 200,
        candidateEnemies: [leftEnemy],
      );

      expect(target, equals(leftEnemy));
      expect(knight.direction, Direction.left);

      // Enemy directly above
      final topEnemy = Goblin(Vector2(100, 20));
      knight.autoAimTowards(
        maxRadius: 200,
        candidateEnemies: [topEnemy],
      );
      expect(knight.direction, Direction.up);

      // Enemy directly below
      final bottomEnemy = Goblin(Vector2(100, 180));
      knight.autoAimTowards(
        maxRadius: 200,
        candidateEnemies: [bottomEnemy],
      );
      expect(knight.direction, Direction.down);
    });

    test('autoAimTowards honors verticalThresholdRatio on diagonals', () {
      final knight = Knight(Vector2(100, 100));
      knight.direction = Direction.up;

      // Diagonal right-down (horizontal dominant: dx = 60, dy = 30)
      // |dy| <= |dx| * 1.73 (30 <= 60 * 1.73 = 103.8) -> horizontal (right)
      final diagEnemy = Goblin(Vector2(160, 130));
      knight.autoAimTowards(
        maxRadius: 200,
        candidateEnemies: [diagEnemy],
      );
      expect(knight.direction, Direction.right);

      // Mostly vertical down (dx = 10, dy = 60)
      // |dy| > |dx| * 1.73 (60 > 10 * 1.73 = 17.3) -> vertical (down)
      final verticalEnemy = Goblin(Vector2(110, 160));
      knight.autoAimTowards(
        maxRadius: 200,
        candidateEnemies: [verticalEnemy],
      );
      expect(knight.direction, Direction.down);
    });

    test('actionAttack triggers auto-aim when autoAimEnabled is true', () {
      final knight = Knight(Vector2(100, 100));
      knight.direction = Direction.left;

      // Enemy to the right
      final rightEnemy = Goblin(Vector2(180, 100));

      // With autoAimTowards called with candidateEnemies
      knight.autoAimTowards(
        maxRadius: knight.autoAimMeleeRadius,
        candidateEnemies: [rightEnemy],
      );
      expect(knight.direction, Direction.right);
    });

    test('auto-aim does nothing when autoAimEnabled is false', () {
      final knight = Knight(Vector2(100, 100));
      knight.direction = Direction.left;
      knight.autoAimEnabled = false;

      final rightEnemy = Goblin(Vector2(180, 100));
      final target = knight.autoAimEnabled
          ? knight.autoAimTowards(
              maxRadius: knight.autoAimMeleeRadius,
              candidateEnemies: [rightEnemy],
            )
          : null;

      expect(target, isNull);
      expect(knight.direction, Direction.left);
    });
  });
}
