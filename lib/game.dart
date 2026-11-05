import 'package:bonfire/bonfire.dart';
import 'package:niskala/decoration/door.dart';
import 'package:niskala/decoration/key.dart';
import 'package:niskala/decoration/potion_life.dart';
import 'package:niskala/decoration/spikes.dart';
import 'package:niskala/decoration/torch.dart';
import 'package:niskala/enemies/boss.dart';
import 'package:niskala/enemies/goblin.dart';
import 'package:niskala/enemies/imp.dart';
import 'package:niskala/enemies/mini_boss.dart';
import 'package:niskala/interface/knight_interface.dart';
import 'package:niskala/main.dart';
import 'package:niskala/npc/kid.dart';
import 'package:niskala/npc/wizard_npc.dart';
import 'package:niskala/player/knight.dart';
import 'package:niskala/util/sounds.dart';
import 'package:niskala/widgets/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Game extends StatefulWidget {
  static bool useJoystick = true;
  const Game({Key? key}) : super(key: key);

  @override
  GameState createState() => GameState();
}

class GameState extends State<Game> {
  @override
  void initState() {
    Sounds.playBackgroundSound();
    super.initState();
  }

  @override
  void dispose() {
    Sounds.stopBackgroundSound();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    PlayerController joystick = Joystick(
      directional: JoystickDirectional(
        spriteBackgroundDirectional: Sprite.load('joystick_background.png'),
        spriteKnobDirectional: Sprite.load('joystick_knob.png'),
        size: 100,
        isFixed: false,
      ),
      actions: [
        JoystickAction(
          actionId: 0,
          sprite: Sprite.load('joystick_atack.png'),
          spritePressed: Sprite.load('joystick_atack_selected.png'),
          size: 80,
          margin: EdgeInsets.only(bottom: 50, right: 50),
        ),
        JoystickAction(
          actionId: 1,
          sprite: Sprite.load('joystick_atack_range.png'),
          spritePressed: Sprite.load('joystick_atack_range_selected.png'),
          size: 50,
          margin: EdgeInsets.only(bottom: 50, right: 160),
        )
      ],
    );

    if (!Game.useJoystick) {
      joystick = Keyboard(
        config: KeyboardConfig(
          directionalKeys: [KeyboardDirectionalKeys.arrows()],
          acceptedKeys: [
            LogicalKeyboardKey.space,
            LogicalKeyboardKey.keyZ,
            LogicalKeyboardKey.arrowUp,
            LogicalKeyboardKey.arrowDown,
            LogicalKeyboardKey.arrowLeft,
            LogicalKeyboardKey.arrowRight,
          ],
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: BonfireWidget(
        playerControllers: [
          joystick,
        ],
        player: Knight(
          Vector2(2 * tileSize, 3 * tileSize),
        ),
        map: WorldMapByTiled(
          WorldMapReader.fromAsset('tiled/map.json'),
          forceTileSize: Vector2(tileSize, tileSize),
          objectsBuilder: {
            'door': (p) => Door(p.position, p.size),
            'torch': (p) => Torch(p.position),
            'potion': (p) => PotionLife(p.position, 30),
            'wizard': (p) => WizardNPC(p.position),
            'spikes': (p) => Spikes(p.position),
            'key': (p) => DoorKey(p.position),
            'kid': (p) => Kid(p.position),
            'boss': (p) => Boss(p.position),
            'goblin': (p) => Goblin(p.position),
            'imp': (p) => Imp(p.position),
            'mini_boss': (p) => MiniBoss(p.position),
            'torch_empty': (p) => Torch(p.position, empty: true),
          },
        ),
        components: [GameController()],
        interface: KnightInterface(),
        lightingColorGame: Colors.black.withValues(alpha: 0.6),
        backgroundColor: Colors.grey[900]!,
        cameraConfig: CameraConfig(
          speed: 3,
          zoom: getZoomFromMaxVisibleTile(context, tileSize, 18),
        ),
      ),
    );
  }
}

