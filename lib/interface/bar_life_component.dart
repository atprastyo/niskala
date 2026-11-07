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

  int playerLevel = 1;
  int currentExp = 0;
  int expToNextLevel = 0;
  double expRatio = 0.0;

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
        final knight = gameRef.player as Knight;
        stamina = knight.stamina;
        maxStamina = knight.progression.maxStamina;
        playerLevel = knight.progression.level;
        currentExp = knight.progression.currentExp;
        expToNextLevel = knight.progression.expToNextLevel;
        expRatio = knight.progression.expProgressRatio;
      }
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    try {
      _drawLife(canvas);
      _drawStamina(canvas);
      _drawExp(canvas);
      _drawLevelBadge(canvas);
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

    double currentBarStamina =
        maxStamina > 0 ? (stamina * widthBar) / maxStamina : 0;
    canvas.drawLine(
      Offset(xBar, yBar),
      Offset(xBar + currentBarStamina, yBar),
      Paint()
        ..color = Colors.yellow
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.fill,
    );
  }

  void _drawExp(Canvas canvas) {
    double xBar = 29;
    double yBar = 36;
    double strokeExp = 3;

    canvas.drawLine(
      Offset(xBar, yBar),
      Offset(xBar + widthBar, yBar),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.6)
        ..strokeWidth = strokeExp
        ..style = PaintingStyle.fill,
    );

    double currentBarExp = (expRatio * widthBar).clamp(0.0, widthBar);
    if (currentBarExp > 0) {
      canvas.drawLine(
        Offset(xBar, yBar),
        Offset(xBar + currentBarExp, yBar),
        Paint()
          ..color = Colors.deepPurpleAccent
          ..strokeWidth = strokeExp
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawLevelBadge(Canvas canvas) {
    final textSpan = TextSpan(
      text: 'Lv.$playerLevel',
      style: const TextStyle(
        color: Colors.amberAccent,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        fontFamily: 'Normal',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(125, 8, textPainter.width + 12, textPainter.height + 6),
      const Radius.circular(4),
    );

    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.75)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = Colors.amberAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    textPainter.paint(canvas, const Offset(131, 11));
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
