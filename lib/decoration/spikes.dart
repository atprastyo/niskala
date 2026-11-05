import 'package:bonfire/bonfire.dart';
import 'package:niskala/main.dart';
import 'package:niskala/player/knight.dart';
import 'package:niskala/util/game_sprite_sheet.dart';

// Bonfire v4: WithSensor<T>; callbacks via sensor API
// handleAttack → life.handleAttack()
class Spikes extends GameDecoration with WithSensor<Knight> {
  final double damage;
  Knight? _player;

  Spikes(Vector2 position, {this.damage = 60})
      : super.withAnimation(
          animation: GameSpriteSheet.spikes(),
          position: position,
          size: Vector2(tileSize, tileSize),
        );

  @override
  void onMount() {
    super.onMount();
    sensor.onContactListener((Knight knight) {
      _player = knight;
    });
    sensor.onContactEndListener((Knight knight) {
      _player = null;
    });
  }

  @override
  void update(double dt) {
    if (isAnimationLastFrame) {
      _player?.life.handleAttack(AttackOriginEnum.WORLD, damage, 0);
    }
    super.update(dt);
  }

  @override
  int get priority => LayerPriority.getComponentPriority(1);
}
