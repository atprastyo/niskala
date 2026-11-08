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
// withOpacity → withValues; attack API via attack.melee() / attack.range()
class MiniBoss extends SimpleEnemy with WithCollision, WithLifeBar {
  final Vector2 initPosition;
  final EnemyProgression progression;
  final String lifeId = EnemyDefeated.newLifeId();
  int get level => progression.level;
  double attackDamage = 50;
  bool _seePlayerClose = false;
  final IntervalTick _meleeInterval = IntervalTick(300);
  final IntervalTick _rangeInterval = IntervalTick(1000);

  MiniBoss(this.initPosition, {int level = 1})
    : progression = EnemyProgression(tier: EnemyTier.miniBoss, level: level),
      super(
        animation: EnemySpriteSheet.miniBossAnimations(),
        position: initPosition,
        size: Vector2(tileSize * 0.68, tileSize * 0.93),
        speed: tileSize * 1.5,
        life: EnemyProgression(tier: EnemyTier.miniBoss, level: level).maxLife,
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
        size: Vector2(valueByTileSize(6), valueByTileSize(7)),
        position: Vector2(valueByTileSize(2.5), valueByTileSize(8)),
      ),
    );
    return super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _seePlayerClose = false;

    vision.seePlayer(
      observed: (player) {
        _seePlayerClose = true;
        vision.seeAndMoveToPlayer(
          closePlayer: (player) {
            _execAttack(dt);
          },
          radiusVision: tileSize * 3,
        );
      },
      radiusVision: tileSize * 3,
    );

    if (!_seePlayerClose) {
      vision.seeAndMoveToAttackRange<Player>(
        positioned: (p) {
          _execAttackRange(dt);
        },
        radiusVision: tileSize * 5,
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

  void _execAttackRange(double dt) {
    if (_rangeInterval.update(dt)) {
      Sounds.attackRange();
      final fireballSize = tileSize * 0.65;
      final hitboxSize = tileSize / 3;
      attack.range(
        useAngle: true,
        animation: GameSpriteSheet.fireBallAttackRight(),
        animationDestroy: GameSpriteSheet.fireBallExplosion(),
        size: Vector2.all(fireballSize),
        damage: attackDamage,
        speed: speed * 2.5,
        marginFromOrigin: 20,
        onDestroy: () {
          Sounds.explosion();
        },
        collision: RectangleHitbox(
          size: Vector2.all(hitboxSize),
          position: Vector2.all((fireballSize - hitboxSize) / 2),
        ),
        lightingConfig: LightingConfig(
          radius: tileSize * 0.9,
          blurBorder: tileSize / 2,
          color: Colors.deepOrangeAccent.withValues(alpha: 0.4),
        ),
      );
    }
  }

  void _execAttack(double dt) {
    if (_meleeInterval.update(dt)) {
      Sounds.attackEnemyMelee();
      attack.melee(
        size: Vector2.all(tileSize * 0.62),
        damage: attackDamage / 3,
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
