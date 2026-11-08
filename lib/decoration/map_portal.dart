import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:niskala/main.dart';
import 'package:niskala/model/map_registry.dart';
import 'package:niskala/player/knight.dart';

class MapPortal extends GameDecoration with WithSensor<Knight> {
  final MapExit exit;
  final void Function(String) onTravel;
  bool _contact = false;
  double _arrivalGrace = 1;

  MapPortal(this.exit, this.onTravel)
    : super(
        position: Vector2(exit.tileX * tileSize, exit.tileY * tileSize),
        size: Vector2.all(tileSize),
      );

  @override
  void onMount() {
    super.onMount();
    sensor.onContactListener((_) {
      if (_contact || _arrivalGrace > 0) return;
      _contact = true;
      onTravel(exit.id);
    });
    sensor.onContactEndListener((_) => _contact = false);
  }

  @override
  void update(double dt) {
    _arrivalGrace -= dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      Paint()..color = Colors.cyan.withValues(alpha: .6),
    );
    TextPainter(
        text: TextSpan(
          text: exit.label,
          style: const TextStyle(color: Colors.white, fontSize: 8),
        ),
        textDirection: TextDirection.ltr,
      )
      ..layout()
      ..paint(canvas, const Offset(0, -12));
  }
}
