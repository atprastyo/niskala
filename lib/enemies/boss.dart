import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:niskala/enemies/imp.dart';
import 'package:niskala/enemies/mini_boss.dart';
import 'package:niskala/main.dart';
import 'package:niskala/util/custom_sprite_animation_widget.dart';
import 'package:niskala/util/enemy_sprite_sheet.dart';
import 'package:niskala/util/functions.dart';
import 'package:niskala/util/game_sprite_sheet.dart';
import 'package:niskala/util/localization/strings_location.dart';
import 'package:niskala/util/npc_sprite_sheet.dart';
import 'package:niskala/util/player_sprite_sheet.dart';
import 'package:niskala/util/sounds.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Bonfire v4: BlockMovementCollision → WithCollision, UseLifeBar → WithLifeBar
// life.value instead of life, util.directionThePlayerIsIn(), attack.melee()
class Boss extends SimpleEnemy with WithCollision, WithLifeBar {
  final Vector2 initPosition;
  double attackDamage = 40;

  bool addChild = false;
  bool firstSeePlayer = false;
  List<Enemy> childrenEnemy = [];

  final IntervalTick _attackInterval = IntervalTick(1500);
  final IntervalTick _addChildInterval = IntervalTick(2000);

  Boss(this.initPosition)
      : super(
          animation: EnemySpriteSheet.bossAnimations(),
          position: initPosition,
          size: Vector2(tileSize * 1.5, tileSize * 1.7),
          speed: tileSize * 1.5,
          life: 200,
        );

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
        size: Vector2(valueByTileSize(14), valueByTileSize(16)),
        position: Vector2(valueByTileSize(5), valueByTileSize(11)),
      ),
    );
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    _drawBarSummonEnemy(canvas);
    super.render(canvas);
  }

  @override
  void update(double dt) {
    if (!firstSeePlayer) {
      vision.seePlayer(
        observed: (p) {
          firstSeePlayer = true;
          gameRef.camera.moveToTargetAnimated(
            target: this,
            zoom: 2,
            onComplete: _showConversation,
          );
        },
        radiusVision: tileSize * 6,
      );
    }

    if (life.value < 150 && childrenEnemy.length == 0) {
      _addChildInMap(dt);
    }
    if (life.value < 100 && childrenEnemy.length == 1) {
      _addChildInMap(dt);
    }
    if (life.value < 50 && childrenEnemy.length == 2) {
      _addChildInMap(dt);
    }

    vision.seeAndMoveToPlayer(
      closePlayer: (player) {
        _execAttack(dt);
      },
      radiusVision: tileSize * 4,
    );

    super.update(dt);
  }

  void _onDie() {
    gameRef.add(
      AnimatedGameObject(
        animation: GameSpriteSheet.explosion(),
        position: position,
        size: Vector2(32, 32),
        loop: false,
      ),
    );
    for (final e in childrenEnemy) {
      if (!e.isDead) e.life.handleAttack(AttackOriginEnum.WORLD, e.life.value, 0);
    }
    removeFromParent();
  }

  void _addChildInMap(double dt) {
    if (!_addChildInterval.update(dt)) return;

    Vector2 positionExplosion = Vector2.zero();

    switch (util.directionThePlayerIsIn()) {
      case Direction.left:
        positionExplosion = position.translated(width * -2, 0);
        break;
      case Direction.right:
        positionExplosion = position.translated(width * 2, 0);
        break;
      case Direction.up:
        positionExplosion = position.translated(0, height * -2);
        break;
      case Direction.down:
        positionExplosion = position.translated(0, height * 2);
        break;
      default:
        break;
    }

    Enemy e = childrenEnemy.length == 2
        ? MiniBoss(Vector2(positionExplosion.x, positionExplosion.y))
        : Imp(Vector2(positionExplosion.x, positionExplosion.y));

    gameRef.add(
      AnimatedGameObject(
        animation: GameSpriteSheet.smokeExplosion(),
        position: positionExplosion,
        size: Vector2(32, 32),
        loop: false,
      ),
    );

    childrenEnemy.add(e);
    gameRef.add(e);
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

  void _drawBarSummonEnemy(Canvas canvas) {
    double yPosition = 0;
    double barWidth = (width - 10) / 3;

    if (childrenEnemy.length < 1) {
      canvas.drawLine(
        Offset(0, yPosition),
        Offset(barWidth, yPosition),
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..style = PaintingStyle.fill,
      );
    }

    double lastX = barWidth + 5;
    if (childrenEnemy.length < 2) {
      canvas.drawLine(
        Offset(lastX, yPosition),
        Offset(lastX + barWidth, yPosition),
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..style = PaintingStyle.fill,
      );
    }

    lastX = lastX + barWidth + 5;
    if (childrenEnemy.length < 3) {
      canvas.drawLine(
        Offset(lastX, yPosition),
        Offset(lastX + barWidth, yPosition),
        Paint()
          ..color = Colors.orange
          ..strokeWidth = 1
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _showConversation() {
    Sounds.interaction();
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [TextSpan(text: getString('talk_kid_1'))],
          person: CustomSpriteAnimationWidget(
            animation: NpcSpriteSheet.kidIdleLeft(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_boss_1'))],
          person: CustomSpriteAnimationWidget(
            animation: EnemySpriteSheet.bossIdleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_player_3'))],
          person: CustomSpriteAnimationWidget(
            animation: PlayerSpriteSheet.idleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_boss_2'))],
          person: CustomSpriteAnimationWidget(
            animation: EnemySpriteSheet.bossIdleRight(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
      ],
      onFinish: () {
        Sounds.interaction();
        _addInitChild();
        Future.delayed(Duration(milliseconds: 500), () {
          gameRef.camera.moveToPlayerAnimated(zoom: 1);
          Sounds.playBackgroundBoosSound();
        });
      },
      onChangeTalk: (index) {
        Sounds.interaction();
      },
      logicalKeyboardKeysToNext: [
        LogicalKeyboardKey.space,
      ],
    );
  }

  void _addInitChild() {
    _addImp(width * -2, 0);
    _addImp(width * -2, width);
  }

  void _addImp(double x, double y) {
    final p = position.translated(x, y);
    gameRef.add(
      AnimatedGameObject(
        animation: GameSpriteSheet.smokeExplosion(),
        position: p,
        size: Vector2.all(tileSize),
        loop: false,
      ),
    );
    gameRef.add(Imp(p));
  }
}
