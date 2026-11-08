import 'package:bonfire/bonfire.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/model/game_events.dart';
import 'package:niskala/model/progression.dart';
import 'package:niskala/player/knight.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('old and replacement actors cannot reward the same life twice', () {
    final session = GameSession();
    final first = Knight(Vector2.zero(), session: session);
    const event = EnemyDefeated(lifeId: 'goblin_01', experience: 20);
    first.rewardEnemyDefeat(event);
    final replacement = Knight(Vector2.zero(), session: session);
    replacement.rewardEnemyDefeat(event);
    expect(session.progression.currentExp, 20);
  });

  test('replacement actor retains progression and depleted resources', () {
    final session = GameSession();
    final first = Knight(Vector2.zero(), session: session);
    first.gainExp(20);
    first.life.remove(35);
    first.decrementStamina(15);

    final replacement = Knight(Vector2(100, 100), session: session);
    expect(replacement.progression, same(first.progression));
    expect(replacement.progression.currentExp, 20);
    expect(replacement.life.value, 165);
    expect(replacement.life.max, 200);
    expect(replacement.stamina, 85);
    expect(session.health, 165);
    expect(replacement, isNot(same(first)));
  });

  test('healing and level-up update shared resources', () {
    final session = GameSession();
    final knight = Knight(Vector2.zero(), session: session);
    knight.life.remove(50);
    knight.life.add(10);
    expect(session.health, 160);
    knight.gainExp(PlayerProgression.expToNextLevelFor(1));
    final replacement = Knight(Vector2.zero(), session: session);
    expect(replacement.progression.level, 2);
    expect(replacement.life.value, 240);
    expect(replacement.life.max, 240);
    expect(replacement.stamina, 102);
  });

  test(
    'fresh sessions are independent and ambiguous ownership is rejected',
    () {
      final first = GameSession();
      final second = GameSession();
      first.progression.gainExp(20);
      expect(second.progression.currentExp, 0);
      expect(
        () => Knight(
          Vector2.zero(),
          session: first,
          progression: PlayerProgression(),
        ),
        throwsArgumentError,
      );
    },
  );
}
