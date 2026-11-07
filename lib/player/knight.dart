import 'dart:async';

import 'package:bonfire/bonfire.dart';
import 'package:niskala/main.dart';
import 'package:niskala/model/progression.dart';
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
  static const double spriteScale = 1.5;
  final PlayerProgression progression;
  double attackDamage = 25;
  double stamina = 100;
  double _staminaElapsed = 0;
  bool _isAttacking = false;
  bool _attackPending = false;
  Direction _attackDirection = Direction.right;
  int _comboStep = 1;
  bool _comboQueued = false;
  double _comboDebounceTime = 0.0;
  static const double comboDebounceWindow = 0.35;
  final bool keyboardMovement;
  final Set<LogicalKeyboardKey> _sprintKeys = {};

  /// Threshold ratio of vertical velocity to horizontal velocity (|vel.y| / |vel.x|)
  /// required to switch facing to vertical (up/down).
  ///
  /// - Standard Bonfire behavior: 1.0 (diagonal ties default to vertical).
  /// - Default: 1.73 (~60° angle from horizontal, meaning the analog must be
  ///   within ~30° of pure vertical).
  ///
  /// As long as |vel.y| <= |vel.x| * verticalThresholdRatio, the player keeps using
  /// horizontal sprites (left and right).
  double verticalThresholdRatio = 1.73;

  Direction _resolveDirectionFromVelocity(Vector2 vel) {
    if (vel.x.abs() <= 0.1 && vel.y.abs() <= 0.1) {
      return direction;
    }
    if (vel.x.abs() > 0.1) {
      hDirection = vel.x > 0 ? Direction.right : Direction.left;
    }
    if (vel.y.abs() > 0.1) {
      vDirection = vel.y > 0 ? Direction.down : Direction.up;
    }

    if (vel.y.abs() > vel.x.abs() * verticalThresholdRatio) {
      return vDirection;
    } else {
      return hDirection;
    }
  }

  @override
  set velocity(Vector2 newVelocity) {
    super.velocity = newVelocity;
    if (!newVelocity.isZero()) {
      direction = _resolveDirectionFromVelocity(newVelocity);
    }
  }

  bool get isAttacking => _isAttacking;
  bool get isRunning => velocity.length > tileSize * 1.65;

  static String facingFor(Direction facing) => switch (facing) {
        Direction.up => 'up',
        Direction.down => 'down',
        Direction.left || Direction.upLeft || Direction.downLeft => 'left',
        _ => 'right',
      };

  bool _selectLocomotion(DirectionAnimationMethod method) {
    if (_isAttacking) return false;
    if (method.name.startsWith('onPlayRun') && !isRunning) {
      animation?.playOther(
        'walk_${facingFor(direction)}',
        flipX: false,
        flipY: false,
      );
      return false;
    }
    return true;
  }

  bool containKey = false;
  bool showObserveEnemy = false;

  Knight(
    Vector2 position, {
    this.keyboardMovement = false,
    PlayerProgression? progression,
  })  : progression = progression ?? PlayerProgression(),
        super(
          animation: PlayerSpriteSheet.playerAnimations(),
          size: Vector2.all(tileSize * spriteScale),
          // Grow upward around the original tile-sized player's foot anchor.
          position: position -
              Vector2(
                tileSize * (spriteScale - 1) / 2,
                tileSize * (spriteScale - 1),
              ),
          life: (progression ?? PlayerProgression()).maxLife,
          speed: tileSize * (keyboardMovement ? 1.4 : 2.5),
        ) {
    if (this.progression.level > 1) {
      life.initial(this.progression.maxLife);
    }
    stamina = this.progression.maxStamina;
    attackDamage = this.progression.attack1Damage;
    lighting.setup(
      LightingConfig(
        radius: tileSize * 1.5,
        blurBorder: tileSize,
        color: Colors.deepOrangeAccent.withValues(alpha: 0.2),
      ),
    );
    directionAnimation.onAnimationExecutionListener(_selectLocomotion);
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
          size.x / 2 - valueByTileSize(4),
          size.y - valueByTileSize(8),
        ),
      ),
    );
    return super.onLoad();
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (event.id == LogicalKeyboardKey.shiftLeft ||
        event.id == LogicalKeyboardKey.shiftRight) {
      final key = event.id as LogicalKeyboardKey;
      if (event.event == ActionEvent.DOWN) {
        _sprintKeys.add(key);
      } else if (event.event == ActionEvent.UP) {
        _sprintKeys.remove(key);
      }
      if (keyboardMovement) {
        speed = tileSize * (_sprintKeys.isEmpty ? 1.4 : 2.5);
      }
    }

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
    _isAttacking = false;
    _comboQueued = false;
    _comboStep = 1;
    _comboDebounceTime = 0.0;
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
    if (isDead) return;

    // If already attacking: queue the second attack if we're currently on Attack 1.
    if (_isAttacking) {
      if (_comboStep == 1 && !_comboQueued) {
        _comboQueued = true;
      }
      return;
    }

    if (stamina < 15) return;

    // If pressed within debounce window after Attack 1, continue combo into Attack 2.
    if (_comboStep == 2 && _comboDebounceTime > 0) {
      _executeAttack2();
    } else {
      _executeAttack1();
    }
  }

  void _executeAttack1() {
    _isAttacking = true;
    _comboStep = 1;
    _comboQueued = false;
    _comboDebounceTime = 0.0;
    _attackPending = true;
    _attackDirection = direction;
    attackDamage = progression.attack1Damage;
    decrementStamina(15);
    velocity = Vector2.zero();
    setupMovementByJoystick(intensityEnabled: true, enabled: false);
    animation?.playOnceOther(
      'attack1_${facingFor(_attackDirection)}',
      flipX: false,
      runToTheEnd: true,
      size: Vector2(size.x * 2, size.y * 80 / 48),
      offset: Vector2(-size.x / 2, -size.y / 3),
      onFinish: () {
        _applyAttackDamage();
        if (_comboQueued && stamina >= 15 && !isDead && !isRemoving) {
          _comboQueued = false;
          scheduleMicrotask(() {
            if (!isDead && !isRemoving) {
              _executeAttack2();
            }
          });
        } else {
          _isAttacking = false;
          _comboStep = 2;
          _comboDebounceTime = comboDebounceWindow;
          if (!isDead && !isRemoving) {
            setupMovementByJoystick(intensityEnabled: true);
            directionAnimation.playIdleAnimation();
          }
        }
      },
    );
  }

  void _executeAttack2() {
    _isAttacking = true;
    _comboStep = 2;
    _comboQueued = false;
    _comboDebounceTime = 0.0;
    _attackPending = true;
    _attackDirection = direction;
    attackDamage = progression.attack2Damage;
    decrementStamina(15);
    velocity = Vector2.zero();
    setupMovementByJoystick(intensityEnabled: true, enabled: false);
    animation?.playOnceOther(
      'attack2_${facingFor(_attackDirection)}',
      flipX: false,
      runToTheEnd: true,
      size: Vector2(size.x * 2, size.y * 80 / 48),
      offset: Vector2(-size.x / 2, -size.y / 3),
      onFinish: () {
        _applyAttackDamage();
        _isAttacking = false;
        _comboStep = 1;
        _comboDebounceTime = 0.0;
        if (!isDead && !isRemoving) {
          setupMovementByJoystick(intensityEnabled: true);
          directionAnimation.playIdleAnimation();
        }
      },
    );
  }

  void _applyAttackDamage() {
    if (!_attackPending || isDead || isRemoving) return;
    _attackPending = false;
    Sounds.attackPlayerMelee();
    attack.melee(
      damage: attackDamage,
      size: Vector2.all(tileSize),
      direction: _attackDirection,
    );
  }

  void actionAttackRange() {
    if (stamina < 10 || _isAttacking || isDead) return;

    Sounds.attackRange();
    decrementStamina(10);
    final radAngle = direction.toRadians();
    final fireballSize = tileSize * 0.65;
    final hitboxSize = tileSize / 3;
    attack.range(
      angle: radAngle,
      animation: GameSpriteSheet.fireBallAttackRight(),
      animationDestroy: GameSpriteSheet.fireBallExplosion(),
      size: Vector2.all(fireballSize),
      damage: progression.skillDamage,
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

  /// Grants EXP to the player and handles level progression.
  int gainExp(int amount) {
    if (isDead) return 0;
    if (hasGameRef) {
      gameRef.add(
        TextDamageComponent(
          '+$amount EXP',
          Vector2(position.x + size.x / 4, position.y),
          config: TextStyle(
            fontSize: valueByTileSize(5),
            color: Colors.lightGreenAccent,
            fontFamily: 'Normal',
            fontWeight: FontWeight.bold,
          ),
          onlyUp: true,
        ),
      );
    }
    final levelsGained = progression.gainExp(
      amount,
      onLevelUp: (newLevel) {
        life.initial(progression.maxLife);
        stamina = progression.maxStamina;
        attackDamage = progression.attack1Damage;
        if (hasGameRef) {
          gameRef.add(
            TextDamageComponent(
              'LEVEL UP! Lv.$newLevel',
              Vector2(position.x, position.y - valueByTileSize(10)),
              config: TextStyle(
                fontSize: valueByTileSize(7),
                color: Colors.amberAccent,
                fontFamily: 'Normal',
                fontWeight: FontWeight.bold,
              ),
              onlyUp: true,
            ),
          );
          _showEmote();
        }
      },
    );
    return levelsGained;
  }

  @override
  void update(double dt) {
    if (isDead) return;
    _verifyStamina(dt);
    if (_comboDebounceTime > 0) {
      _comboDebounceTime -= dt;
      if (_comboDebounceTime <= 0) {
        _comboStep = 1;
        _comboDebounceTime = 0.0;
      }
    }
    if (hasGameRef) {
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
    }
    super.update(dt);
    if (_isAttacking && (animation?.fastAnimationcurrentIndex ?? 0) >= 1) {
      _applyAttackDamage();
    }
  }

  void _verifyStamina(double dt) {
    _staminaElapsed += dt;
    final interval = progression.staminaRegenInterval;
    final ticks = (_staminaElapsed / interval).floor();
    if (ticks == 0) return;
    _staminaElapsed -= ticks * interval;
    stamina = (stamina + ticks * 2).clamp(0, progression.maxStamina).toDouble();
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
