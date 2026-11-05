import 'package:bonfire/bonfire.dart';
import 'package:niskala/player/knight.dart';
import 'package:flutter/material.dart';

// Bonfire v4: life is LifeApi (life.value, life.max)
class MyBarLifeComponent extends InterfaceComponent {
  double padding = 20;
  double widthBar = 90;
  double strokeWidth = 12;

  double maxLife = 0;
  double lifeValue = 0;
  double maxStamina = 100;
  double stamina = 0;

  MyBarLifeComponent()
      : super(
          id: 1,
          position: Vector2(20, 20),
          spriteUnselected: Sprite.load('health_ui.png'),
          size: Vector2(120, 40),
        );

  @override
  void update(double dt) {
    if (gameRef.player != null) {
      lifeValue = gameRef.player!.life.value;
      maxLife = gameRef.player!.life.max;
      if (gameRef.player is Knight) {
        stamina = (gameRef.player as Knight).stamina;
      }
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    try {
      _drawLife(canvas);
      _drawStamina(canvas);
    } catch (e) {
      // ignore render errors
    }
    super.render(canvas);
  }

  void _drawLife(Canvas canvas) {
    double xBar = 29;
    double yBar = 10;
    canvas.drawLine(
      Offset(xBar, yBar),
      Offset(xBar + widthBar, yBar),
      Paint()
        ..color = Colors.blueGrey[800]!
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill,
    );

    double currentBarLife = maxLife > 0 ? (lifeValue * widthBar) / maxLife : 0;
    canvas.drawLine(
      Offset(xBar, yBar),
      Offset(xBar + currentBarLife, yBar),
      Paint()
        ..color = _getColorLife(currentBarLife)
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  void _drawStamina(Canvas canvas) {
    double xBar = 29;
    double yBar = 27;

    double currentBarStamina = (stamina * widthBar) / maxStamina;
    canvas.drawLine(
      Offset(xBar, yBar),
      Offset(xBar + currentBarStamina, yBar),
      Paint()
        ..color = Colors.yellow
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  Color _getColorLife(double currentBarLife) {
    if (currentBarLife > widthBar - (widthBar / 3)) {
      return Colors.green;
    }
    if (currentBarLife > (widthBar / 3)) {
      return Colors.yellow;
    } else {
      return Colors.red;
    }
  }
}
