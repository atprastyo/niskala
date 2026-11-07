import 'package:bonfire/bonfire.dart';
import 'package:niskala/main.dart';
import 'package:niskala/model/progression.dart';
import 'package:niskala/player/knight.dart';
import 'package:niskala/util/enemy_sprite_sheet.dart';
import 'package:niskala/util/functions.dart';
import 'package:niskala/util/game_sprite_sheet.dart';
import 'package:niskala/util/sounds.dart';
import 'package:flutter/material.dart';

// Bonfire v4:
// - BlockMovementCollision → WithCollision
// - UseLifeBar → WithLifeBar
// - `attack` → `attackDamage` (WithAttack already defines `attack` API)
// - simpleAttackMelee + interval → attack.melee() + IntervalTick
// - seeAndMoveToPlayer → vision.seeAndMoveToPlayer()
// - showDamage → util.showDamage()
// - onDie / onReceiveDamage → life.onDieListener / life.onReceiveDamageListener
class Goblin extends SimpleEnemy with WithCollision, WithLifeBar {
  final Vector2 initPosition;
  final EnemyProgression progression;
  int get level => progression.level;
  double attackDamage = 25;
  final IntervalTick _attackInterval = IntervalTick(800);

  Goblin(this.initPosition, {int level = 1})
      : progression = EnemyProgression(tier: EnemyTier.goblin, level: level),
        super(
          animation: EnemySpriteSheet.goblinAnimations(),
          position: initPosition,
          size: Vector2.all(tileSize * 0.8),
          speed: tileSize * 1.5,
          life: EnemyProgression(tier: EnemyTier.goblin, level: level).maxLife,
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
    add(RectangleHitbox(
      size: Vector2(
        valueByTileSize(7),
        valueByTileSize(7),
      ),
      position: Vector2(valueByTileSize(3), valueByTileSize(4)),
    ));
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    vision.seeAndMoveToPlayer(
      closePlayer: (player) {
        _execAttack(dt);
      },
      radiusVision: tileSize * 4,
    );
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
      (gameRef.player as Knight).gainExp(progression.expBounty);
    }
    removeFromParent();
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
