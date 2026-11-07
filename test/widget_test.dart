import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/bonfire.dart';
import 'package:niskala/game.dart';
import 'package:niskala/main.dart';
import 'package:niskala/player/knight.dart';
import 'package:niskala/util/sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Arka walks, sprints, plays directional combos, and fires',
      (tester) async {
    Sounds.enabled = false;
    Game.useJoystick = false;
    addTearDown(() => Game.useJoystick = true);

    Future<void> advance(int frames) async {
      await tester.runAsync(() async {
        for (var i = 0; i < frames; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          await tester.pump(const Duration(milliseconds: 30));
        }
      });
    }

    await tester.pumpWidget(const MaterialApp(home: Game()));
    await advance(70);
    expect(find.byType(Game), findsOneWidget);
    final gameWidgetFinder = find.byWidgetPredicate(
      (w) => w.runtimeType.toString().startsWith('ListenerGameWidget'),
    );
    final gameRef =
        (tester.widget(gameWidgetFinder) as dynamic).game as BonfireGame;
    final knight = gameRef.player! as Knight;
    expect(knight.size, Vector2.all(tileSize * Knight.spriteScale));
    expect(knight.animation!.animationSize, Vector2.all(48));
    expect(knight.animation!.canIdleUp, isTrue);
    expect(knight.animation!.canIdleDown, isTrue);
    expect(knight.animation!.canRunUp, isTrue);
    expect(knight.animation!.canRunDown, isTrue);

    // Both movement cycles must be reachable with keyboard input.
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    await advance(5);
    expect(knight.isRunning, isFalse);
    expect(knight.animation!.currentType, SimpleAnimationEnum.custom);
    expect(knight.velocity.length, closeTo(tileSize * 1.4, 0.01));
    await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
    await advance(5);
    expect(knight.speed, tileSize * 2.5);
    expect(knight.isRunning, isTrue,
        reason:
            'speed=${knight.speed}, velocity=${knight.velocity}, position=${knight.position}');
    expect(knight.animation!.currentType, SimpleAnimationEnum.runRight);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
    await advance(4);

    // Diagonal movement (Down + Right) maintains horizontal facing (Right)
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    await advance(5);
    expect(knight.direction, Direction.right);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
    await advance(5);
    // Pure Down switches to vertical facing (Down)
    expect(knight.direction, Direction.down);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowDown);
    await advance(4);

    // Diagonal movement (Up + Left) maintains horizontal facing (Left)
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowLeft);
    await advance(5);
    expect(knight.direction, Direction.left);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowLeft);
    await advance(5);
    // Pure Up switches to vertical facing (Up)
    expect(knight.direction, Direction.up);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowUp);
    await advance(4);

    for (final direction in [
      Direction.right,
      Direction.left,
      Direction.up,
      Direction.down
    ]) {
      knight.direction = direction;
      knight.stamina = 100;
      knight.actionAttack();
      expect(knight.isAttacking, isTrue);
      expect(knight.stamina, 85);
      // Repeated presses cannot restart the combo or spend more stamina.
      knight.actionAttack();
      expect(knight.stamina, 85);
      await advance(4);
      expect(knight.isAttacking, isTrue);
      expect(
          knight.animation!.fastAnimationcurrentIndex, greaterThanOrEqualTo(1));
      expect(knight.animation!.isFlipHorizontallyFastAnimation, false);
      await advance(40);
      expect(knight.isAttacking, isFalse);
    }

    knight.direction = Direction.right;
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await advance(5);
    expect(
        gameRef.world.children.whereType<FlyingAttackGameObject>(), isNotEmpty);

    // Verify Combo Debounce: Single press only plays attack_1
    knight.stamina = 100;
    knight.actionAttack();
    expect(knight.isAttacking, isTrue);
    expect(knight.stamina, 85);
    await advance(20);
    expect(knight.isAttacking, isFalse);

    // Wait for the combo debounce window (0.35s) to expire so combo resets to attack 1
    await advance(15);

    // Verify Combo Debounce: Double press chains attack_1 into attack_2
    knight.stamina = 100;
    knight.actionAttack();
    expect(knight.stamina, 85);
    knight.actionAttack();
    expect(knight.stamina, 85); // queued, not deducted yet
    await advance(20); // attack_1 finishes, attack_2 triggers
    expect(knight.isAttacking, isTrue);
    expect(knight.stamina, lessThan(100)); // attack_2 spent stamina (partially regenerated)
    await advance(25); // attack_2 finishes
    expect(knight.isAttacking, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  test(
      'Knight verticalThresholdRatio correctly resolves facing direction for analog angles',
      () {
    final knight = Knight(Vector2.zero());

    // 30° from horizontal (mostly right, slight down): |vy| / |vx| ≈ 0.577
    knight.velocity = Vector2(100 * 0.866, 100 * 0.500);
    expect(knight.direction, Direction.right);

    // 45° diagonal: |vy| / |vx| = 1.0 -> stays horizontal (right)
    knight.velocity = Vector2(70.7, 70.7);
    expect(knight.direction, Direction.right);

    // 55° from horizontal: |vy| / |vx| ≈ 1.428 (still <= 1.73) -> stays horizontal (right)
    knight.velocity = Vector2(100 * 0.573, 100 * 0.819);
    expect(knight.direction, Direction.right);

    // 75° from horizontal (steep vertical): |vy| / |vx| ≈ 3.73 (> 1.73) -> switches to vertical (down)
    knight.velocity = Vector2(100 * 0.259, 100 * 0.966);
    expect(knight.direction, Direction.down);

    // Steep up (-75°): switches to vertical (up)
    knight.velocity = Vector2(100 * 0.259, -100 * 0.966);
    expect(knight.direction, Direction.up);

    // 45° up-left: stays horizontal (left)
    knight.velocity = Vector2(-70.7, -70.7);
    expect(knight.direction, Direction.left);
  });
}
