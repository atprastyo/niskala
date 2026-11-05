import 'package:bonfire/bonfire.dart';
import 'package:niskala/main.dart';
import 'package:niskala/util/game_sprite_sheet.dart';
import 'package:flutter/material.dart';

// Bonfire v4: Lighting → WithLighting; setup via lighting.setup(); withOpacity → withValues
class Torch extends GameDecoration with WithLighting {
  bool empty = false;

  Torch(Vector2 position, {this.empty = false})
      : super.withAnimation(
          animation: GameSpriteSheet.torch(),
          position: position,
          size: Vector2.all(tileSize),
        ) {
    lighting.setup(
      LightingConfig(
        radius: tileSize * 2.5,
        blurBorder: tileSize,
        pulseVariation: 0.1,
        color: Colors.deepOrangeAccent.withValues(alpha: 0.2),
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    if (!empty) {
      super.render(canvas);
    }
  }
}
