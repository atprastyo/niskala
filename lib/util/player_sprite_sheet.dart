import 'package:bonfire/bonfire.dart';

class PlayerSpriteSheet {
  static const frameSize = 48.0;
  static const sheetFrameWidth = 96.0;
  static const sheetFrameHeight = 80.0;

  static Future<SpriteAnimation> _heroAnimation(
    String action, {
    String facing = 'right',
    double stepTime = 0.1,
  }) async {
    final filename = action.replaceAll('_', '');
    final animation = await SpriteAnimation.load(
      'player/arka/$action/${filename}_$facing.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        stepTime: stepTime,
        textureSize: Vector2(sheetFrameWidth, sheetFrameHeight),
      ),
    );
    if (action.startsWith('attack')) return animation;
    // Remove empty cell padding for locomotion without altering the artwork.
    // Attacks keep the full cell so the sword arcs are never cropped.
    return SpriteAnimation.spriteList(
      [
        for (final frame in animation.frames)
          Sprite(
            frame.sprite.image,
            srcPosition: frame.sprite.srcPosition + Vector2(24, 16),
            srcSize: Vector2.all(frameSize),
          ),
      ],
      stepTime: stepTime,
    );
  }

  static Future<SpriteAnimation> idleRight() => _heroAnimation('idle');

  static Future<SpriteAnimation> attack1(String facing) =>
      _heroAnimation('attack_1', facing: facing, stepTime: 0.065);

  static Future<SpriteAnimation> attack2(String facing) =>
      _heroAnimation('attack_2', facing: facing, stepTime: 0.065);

  static Future<SpriteAnimation> _combo(String facing) async {
    final first = await attack1(facing);
    final second = await attack2(facing);
    return SpriteAnimation([...first.frames, ...second.frames], loop: false);
  }

  static SimpleDirectionAnimation playerAnimations() =>
      SimpleDirectionAnimation(
        idleRight: idleRight(),
        idleLeft: _heroAnimation('idle', facing: 'left'),
        idleUp: _heroAnimation('idle', facing: 'up'),
        idleDown: _heroAnimation('idle', facing: 'down'),
        runRight: _heroAnimation('run', stepTime: 0.07),
        runLeft: _heroAnimation('run', facing: 'left', stepTime: 0.07),
        runUp: _heroAnimation('run', facing: 'up', stepTime: 0.07),
        runDown: _heroAnimation('run', facing: 'down', stepTime: 0.07),
        others: {
          for (final facing in ['right', 'left', 'up', 'down']) ...{
            // Arka has no separate walk sheet; use a slower run cadence.
            'walk_$facing':
                _heroAnimation('run', facing: facing, stepTime: 0.12),
            'attack1_$facing': attack1(facing),
            'attack2_$facing': attack2(facing),
            'combo_$facing': _combo(facing),
          },
        },
      );
}
