import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:niskala/main.dart';
import 'package:niskala/util/functions.dart';
import 'package:niskala/util/game_sprite_sheet.dart';
import 'package:niskala/util/player_sprite_sheet.dart';
import 'package:niskala/util/sounds.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Bonfire v4:
// - Lighting mixin → WithLighting; setup via lighting.setup()
// - BlockMovementCollision → WithCollision
// - `attack` field renamed to `attackDamage` (WithAttack already defines `attack`)
// - simpleAttackMelee → attack.melee()
// - simpleAttackRange → attack.range()
// - seeEnemy → vision.seeEnemy()
// - showDamage → util.showDamage()
// - onDie / onReceiveDamage → life.onDieListener / life.onReceiveDamageListener
// - withOpacity → withValues
class Knight extends SimplePlayer with WithLighting, WithCollision {
  double attackDamage = 25;
  double stamina = 100;
  async.Timer? _timerStamina;
  bool containKey = false;
  bool showObserveEnemy = false;

  Knight(Vector2 position)
      : super(
          animation: PlayerSpriteSheet.playerAnimations(),
          size: Vector2.all(tileSize),
          position: position,
          life: 200,
          speed: tileSize * 2.5,
        ) {
    lighting.setup(
      LightingConfig(
        radius: tileSize * 1.5,
        blurBorder: tileSize,
        color: Colors.deepOrangeAccent.withValues(alpha: 0.2),
      ),
    );
    setupMovementByJoystick(intensityEnabled: true);
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
        size: Vector2(valueByTileSize(8), valueByTileSize(8)),
        position: Vector2(
          valueByTileSize(4),
          valueByTileSize(8),
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == 0 && event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == LogicalKeyboardKey.space &&
        event.event == ActionEvent.DOWN) {
      actionAttack();
    }

    if (event.id == LogicalKeyboardKey.keyZ &&
        event.event == ActionEvent.DOWN) {
      actionAttackRange();
    }

    if (event.id == 1 && event.event == ActionEvent.DOWN) {
      actionAttackRange();
    }
    super.onJoystickAction(event);
  }

  void _onDie() {
    removeFromParent();
    gameRef.add(
      GameDecoration.withSprite(
        sprite: Sprite.load('player/crypt.png'),
        position: Vector2(position.x, position.y),
        size: Vector2.all(30),
      ),
    );
  }

  void actionAttack() {
    if (stamina < 15) return;

    Sounds.attackPlayerMelee();
    decrementStamina(15);
    attack.melee(
      damage: attackDamage,
      animation: PlayerSpriteSheet.attackEffectRight(),
      size: Vector2.all(tileSize),
    );
  }

  void actionAttackRange() {
    if (stamina < 10) return;

    Sounds.attackRange();
    decrementStamina(10);
    attack.range(
      animation: GameSpriteSheet.fireBallAttackRight(),
      animationDestroy: GameSpriteSheet.fireBallExplosion(),
      size: Vector2(tileSize * 0.65, tileSize * 0.65),
      damage: 10,
      speed: speed * 2.5,
      onDestroy: () {
        Sounds.explosion();
      },
      collision: RectangleHitbox(
        size: Vector2(tileSize / 3, tileSize / 3),
        position: Vector2(10, 5),
      ),
      lightingConfig: LightingConfig(
        radius: tileSize * 0.9,
        blurBorder: tileSize / 2,
        color: Colors.deepOrangeAccent.withValues(alpha: 0.4),
      ),
    );
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _verifyStamina();
    vision.seeEnemy(
      radiusVision: tileSize * 6,
      notObserved: () {
        showObserveEnemy = false;
      },
      observed: (enemies) {
        if (showObserveEnemy) return;
        showObserveEnemy = true;
        _showEmote();
      },
    );
    super.update(dt);
  }

  void _verifyStamina() {
    if (_timerStamina == null) {
      _timerStamina = async.Timer(
        Duration(milliseconds: 150),
        () {
          _timerStamina = null;
        },
      );
    } else {
      return;
    }

    stamina += 2;
    if (stamina > 100) {
      stamina = 100;
    }
  }

  void decrementStamina(int i) {
    stamina -= i;
    if (stamina < 0) {
      stamina = 0;
    }
  }

  void _onReceiveDamage(AttackOriginEnum attacker, double damage, dynamic id) {
    if (isDead) return;
    util.showDamage(
      damage,
      config: TextStyle(
        fontSize: valueByTileSize(5),
        color: Colors.orange,
        fontFamily: 'Normal',
      ),
    );
  }

  void _showEmote({String emote = 'emote/emote_exclamacao.png'}) {
    gameRef.add(
      AnimatedFollowerGameObject(
        animation: SpriteAnimation.load(
          emote,
          SpriteAnimationData.sequenced(
            amount: 8,
            stepTime: 0.1,
            textureSize: Vector2(32, 32),
          ),
        ),
        target: this,
        loop: false,
        size: Vector2.all(tileSize / 2),
        offset: Vector2(18, -6),
      ),
    );
  }
}
