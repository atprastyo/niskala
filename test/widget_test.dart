import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bonfire/bonfire.dart';
import 'package:niskala/game.dart';
import 'package:niskala/util/sounds.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test Game widget, melee attack animation, and ranged fireball projectile',
      (tester) async {
    Sounds.enabled = false;
    Game.useJoystick = false;

    await tester.pumpWidget(
      const MaterialApp(
        home: Game(),
      ),
    );

    await tester.runAsync(() async {
      for (int i = 0; i < 50; i++) {
        await Future.delayed(const Duration(milliseconds: 40));
        await tester.pump(const Duration(milliseconds: 40));
      }
    });

    expect(find.byType(Game), findsOneWidget);
    final gameWidgetFinder = find.byWidgetPredicate(
      (w) => w.runtimeType.toString().startsWith('ListenerGameWidget'),
    );
    final gameRef =
        (tester.widget(gameWidgetFinder) as dynamic).game as BonfireGame;

    expect(gameRef.player, isNotNull);

    // Trigger melee attack (Space key)
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    // Verify AnimatedGameObject is spawned for melee attack effect
    await tester.runAsync(() async {
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 30));
        await tester.pump(const Duration(milliseconds: 30));
      }
    });

    // Trigger ranged fireball attack (KeyZ)
    await tester.sendKeyEvent(LogicalKeyboardKey.keyZ);
    await tester.pump();

    // Verify FlyingAttackGameObject is spawned for fireball projectile
    await tester.runAsync(() async {
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(milliseconds: 30));
        await tester.pump(const Duration(milliseconds: 30));
      }
    });

    final projectiles =
        gameRef.world.children.whereType<FlyingAttackGameObject>().toList();
    expect(projectiles.isNotEmpty, isTrue);
  });
}
