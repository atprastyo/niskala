import 'package:bonfire/bonfire.dart';
import 'package:niskala/main.dart';
import 'package:niskala/player/knight.dart';

// Bonfire v4: WithSensor; callbacks via sensor.onContactListener / sensor.onContactEndListener
class DoorKey extends GameDecoration with WithSensor<Knight> {
  DoorKey(Vector2 position)
      : super.withSprite(
          sprite: Sprite.load('items/key_silver.png'),
          position: position,
          size: Vector2(tileSize, tileSize),
        );

  @override
  void onMount() {
    super.onMount();
    sensor.onContactListener((Knight knight) {
      knight.containKey = true;
      removeFromParent();
    });
  }
}
