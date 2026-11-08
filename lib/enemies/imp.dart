import 'package:bonfire/bonfire.dart';
import 'package:niskala/main.dart';
import 'package:niskala/model/progression.dart';
import 'package:niskala/model/game_events.dart';
import 'package:niskala/player/knight.dart';
import 'package:niskala/util/enemy_sprite_sheet.dart';
import 'package:niskala/util/functions.dart';
import 'package:niskala/util/game_sprite_sheet.dart';
import 'package:niskala/util/sounds.dart';
import 'package:flutter/material.dart';

// Bonfire v4: BlockMovementCollision → WithCollision, UseLifeBar → WithLifeBar
class Imp extends SimpleEnemy with WithCollision, WithLifeBar {
  final Vector2 initPosition;
  final EnemyProgression progression;
  final String lifeId = EnemyDefeated.newLifeId();
  int get level => progression.level;
  double attackDamage = 10;
  final IntervalTick _attackInterval = IntervalTick(300);

  Imp(this.initPosition, {int level = 1})
    : progression = EnemyProgression(tier: EnemyTier.imp, level: level),
      super(
        animation: EnemySpriteSheet.impAnimations(),
        position: initPosition,
        size: Vector2.all(tileSize * 0.8),
        speed: tileSize * 2,
        life: EnemyProgression(tier: EnemyTier.imp, level: level).maxLife,
      ) {
    attackDamage = progression.attackDamage;
    lifeBar.setup(
      showLifeText: true,
      textStyle: TextStyle(
        fontSize: valueByTileSize(3),
        color: Colors.white,
        fontFamily: 'Normal',
      ),
      barLifetextBuilder: (life, maxLife) => 'Lv.$level ${life.toInt()}',
    );
  }

  @override
  void onMount() {
    super.onMount();
    life.onDieListener(_onDie);
    life.onReceiveDamageListener(_onReceiveDamage);
  }

  @override
  Future<void> onLoad() {
    add(
      RectangleHitbox(
        size: Vector2(valueByTileSize(6), valueByTileSize(6)),
        position: Vector2(valueByTileSize(3), valueByTileSize(5)),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    vision.seeAndMoveToPlayer(
      radiusVision: tileSize * 5,
      closePlayer: (player) {
        _execAttack(dt);
      },
    );
  }

  void _execAttack(double dt) {
    if (_attackInterval.update(dt)) {
      Sounds.attackEnemyMelee();
      attack.melee(
        size: Vector2.all(tileSize * 0.62),
        damage: attackDamage,
        animation: EnemySpriteSheet.enemyAttackEffectRight(),
      );
    }
  }

  void _onDie() {
    gameRef.add(
      AnimatedGameObject(
        animation: GameSpriteSheet.smokeExplosion(),
        position: position,
        size: Vector2(32, 32),
        loop: false,
      ),
    );
    if (gameRef.player is Knight) {
      (gameRef.player as Knight).rewardEnemyDefeat(
        EnemyDefeated(lifeId: lifeId, experience: progression.expBounty),
      );
    }
    removeFromParent();
  }

  void _onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    util.showDamage(
      damage,
      config: TextStyle(
        fontSize: valueByTileSize(5),
        color: Colors.white,
        fontFamily: 'Normal',
      ),
    );
  }
}
