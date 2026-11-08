import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/model/game_events.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/model/progression.dart';

void main() {
  const defeat = EnemyDefeated(lifeId: 'goblin_life_01', experience: 20);

  test(
    'replayed enemy defeat awards XP once without a rendering component',
    () {
      final session = GameSession();
      expect(session.applyEnemyDefeat(defeat).accepted, isTrue);
      expect(session.applyEnemyDefeat(defeat).accepted, isFalse);
      expect(session.progression.currentExp, 20);
      expect(session.rewardClaims, {defeat.rewardId});
    },
  );

  test('a fresh life can award XP while the same life stays claimed', () {
    final session = GameSession();
    final first = EnemyDefeated(
      lifeId: EnemyDefeated.newLifeId(),
      experience: 20,
    );
    final respawn = EnemyDefeated(
      lifeId: EnemyDefeated.newLifeId(),
      experience: 20,
    );
    expect(first.lifeId, isNot(respawn.lifeId));
    session.applyEnemyDefeat(first);
    session.applyEnemyDefeat(respawn);
    session.applyEnemyDefeat(first);
    expect(session.progression.currentExp, 40);
  });

  test('unaccepted rewards do not consume a claim', () {
    final session = GameSession()..health = 0;
    expect(session.applyEnemyDefeat(defeat).accepted, isFalse);
    expect(session.rewardClaims, isEmpty);
    session.health = session.progression.maxLife;
    expect(session.applyEnemyDefeat(defeat).accepted, isTrue);
    expect(session.grantExperience(0, rewardId: 'zero').accepted, isFalse);
    expect(session.rewardClaims, isNot(contains('zero')));
  });

  test(
    'level-up refills session resources once and reports each gained level',
    () {
      final session = GameSession()..health = 100;
      session.stamina = 20;
      final levels = <int>[];
      final reward = EnemyDefeated(
        lifeId: 'boss_01',
        experience:
            PlayerProgression.expToNextLevelFor(1) +
            PlayerProgression.expToNextLevelFor(2),
      );
      expect(
        session.applyEnemyDefeat(reward, onLevelUp: levels.add).levelsGained,
        2,
      );
      session.applyEnemyDefeat(reward, onLevelUp: levels.add);
      expect(levels, [2, 3]);
      expect(session.health, session.progression.maxLife);
      expect(session.stamina, session.progression.maxStamina);
    },
  );

  test('restored claims are copied and exposed read-only', () {
    final claims = <String>{defeat.rewardId};
    final session = GameSession(rewardClaims: claims);
    claims.clear();
    expect(session.applyEnemyDefeat(defeat).accepted, isFalse);
    expect(() => session.rewardClaims.clear(), throwsUnsupportedError);
    expect(
      () => GameSession(rewardClaims: ['invalid/id']),
      throwsFormatException,
    );
  });
}
