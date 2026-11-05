import 'package:bonfire/bonfire.dart';
import 'package:niskala/enemies/boss.dart';
import 'package:niskala/util/custom_sprite_animation_widget.dart';
import 'package:niskala/util/dialogs.dart';
import 'package:niskala/util/functions.dart';
import 'package:niskala/util/localization/strings_location.dart';
import 'package:niskala/util/npc_sprite_sheet.dart';
import 'package:niskala/util/player_sprite_sheet.dart';
import 'package:niskala/util/sounds.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Bonfire v4: checkInterval removed → use IntervalTick
class Kid extends GameDecoration {
  bool conversationWithHero = false;
  final IntervalTick _checkInterval = IntervalTick(1000);

  Kid(
    Vector2 position,
  ) : super.withAnimation(
          animation: NpcSpriteSheet.kidIdleLeft(),
          position: position,
          size: Vector2(valueByTileSize(8), valueByTileSize(11)),
        );

  @override
  void update(double dt) {
    super.update(dt);
    if (!conversationWithHero && _checkInterval.update(dt)) {
      try {
        gameRef.enemies().firstWhere((e) => e is Boss);
      } catch (e) {
        conversationWithHero = true;
        gameRef.camera.moveToTargetAnimated(
          target: this,
          onComplete: () {
            _startConversation();
          },
        );
      }
    }
  }

  void _startConversation() {
    Sounds.interaction();
    TalkDialog.show(
      gameRef.context,
      [
        Say(
          text: [TextSpan(text: getString('talk_kid_2'))],
          person: CustomSpriteAnimationWidget(
            animation: NpcSpriteSheet.kidIdleLeft(),
          ),
          personSayDirection: PersonSayDirection.RIGHT,
        ),
        Say(
          text: [TextSpan(text: getString('talk_player_4'))],
          person: CustomSpriteAnimationWidget(
            animation: PlayerSpriteSheet.idleRight(),
          ),
          personSayDirection: PersonSayDirection.LEFT,
        ),
      ],
      onFinish: () {
        Sounds.interaction();
        gameRef.camera.moveToPlayerAnimated(onComplete: () {
          Dialogs.showCongratulations(gameRef.context);
        });
      },
      onChangeTalk: (index) {
        Sounds.interaction();
      },
      logicalKeyboardKeysToNext: [
        LogicalKeyboardKey.space,
      ],
    );
  }
}
