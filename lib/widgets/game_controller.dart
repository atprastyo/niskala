import 'package:bonfire/bonfire.dart';
import 'package:niskala/game.dart';
import 'package:niskala/util/dialogs.dart';
import 'package:flutter/material.dart';

// Bonfire v4: checkInterval removed → use IntervalTick
class GameController extends GameComponent {
  bool showGameOver = false;
  final IntervalTick _checkInterval = IntervalTick(100);

  @override
  void update(double dt) {
    if (_checkInterval.update(dt)) {
      if (gameRef.player != null && gameRef.player?.isDead == true) {
        if (!showGameOver) {
          showGameOver = true;
          _showDialogGameOver();
        }
      }
    }
    super.update(dt);
  }

  void _showDialogGameOver() {
    Dialogs.showGameOver(
      context,
      () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => Game()),
          (Route<dynamic> route) => false,
        );
      },
    );
  }
}
