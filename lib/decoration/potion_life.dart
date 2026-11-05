import 'package:bonfire/bonfire.dart';
import 'package:niskala/main.dart';
import 'package:niskala/player/knight.dart';

// Bonfire v4: WithSensor; callbacks via sensor.onContactListener
class PotionLife extends GameDecoration with WithSensor<Knight> {
  final Vector2 initPosition;
  final double life;
  bool hasContact = false;

  PotionLife(this.initPosition, this.life)
      : super.withSprite(
          sprite: Sprite.load('items/potion_red.png'),
          position: initPosition,
          size: Vector2(tileSize, tileSize),
        );

  @override
  void onMount() {
    super.onMount();
    sensor.onContactListener((Knight knight) {
      if (!hasContact) {
        hasContact = true;
        _giveLife(knight);
        removeFromParent();
      }
    });
  }

  void _giveLife(Player player) {
    double lifeDistributed = 0;
    gameRef.add(
      ValueGeneratorComponent(
        const Duration(seconds: 1),
        onChange: (value) {
          if (lifeDistributed < life) {
            double newLife = life * value - lifeDistributed;
            lifeDistributed += newLife;
            player.life.add(newLife);
          }
        },
      ),
    );
  }
}
