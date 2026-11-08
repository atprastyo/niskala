import 'dart:async' as async;

import 'package:bonfire/bonfire.dart';
import 'package:niskala/game.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/storage/save_factory.dart';
import 'package:niskala/storage/save_repository.dart';
import 'package:niskala/widgets/saved_game.dart';
import 'package:flutter/foundation.dart';
import 'package:niskala/util/custom_sprite_animation_widget.dart';
import 'package:niskala/util/enemy_sprite_sheet.dart';
import 'package:niskala/util/localization/strings_location.dart';
import 'package:niskala/util/player_sprite_sheet.dart';
import 'package:niskala/util/sounds.dart';
import 'package:niskala/widgets/custom_radio.dart';
import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Menu extends StatefulWidget {
  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  Future<SaveRepository>? _repository;
  bool _opening = false;

  Future<void> _openGame({required bool continuing}) async {
    if (_opening) return;
    setState(() => _opening = true);
    try {
      final repository = kIsWeb
          ? null
          : await (_repository ??= createNativeSaveRepository());
      var session = GameSession();
      if (continuing) {
        final loaded = await repository!.load();
        if (!mounted) return;
        if (loaded == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No saved adventure yet.')),
          );
          return;
        }
        session = loaded.session;
        if (session.currentMapId != 'dev_dungeon' ||
            session.currentSpawnId != 'start' ||
            session.health <= 0) {
          throw const SaveException('Saved location is not supported yet.');
        }
        if (loaded.recoveredFromBackup) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recovered the previous save.')),
          );
        }
      }
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SavedGame(session: session, repository: repository),
        ),
      );
    } catch (_) {
      _repository = null;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open local saves. Existing progress was not replaced.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  bool showSplash = true;
  int currentPosition = 0;
  late async.Timer _timer;
  List<Future<SpriteAnimation>> sprites = [
    PlayerSpriteSheet.idleRight(),
    EnemySpriteSheet.goblinIdleRight(),
    EnemySpriteSheet.impIdleRight(),
    EnemySpriteSheet.miniBossIdleRight(),
    EnemySpriteSheet.bossIdleRight(),
  ];

  @override
  void dispose() {
    Sounds.stopBackgroundSound();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      child: showSplash ? buildSplash() : buildMenu(),
    );
  }

  Widget buildMenu() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                "Darkness Dungeon",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Normal',
                  fontSize: 30.0,
                ),
              ),
              SizedBox(height: 20.0),
              if (sprites.isNotEmpty)
                SizedBox(
                  height: 100,
                  width: 100,
                  child: CustomSpriteAnimationWidget(
                    animation: sprites[currentPosition],
                  ),
                ),
              SizedBox(height: 30.0),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    minimumSize: Size(100, 40),
                  ),
                  onPressed: _opening
                      ? null
                      : () => _openGame(continuing: false),
                  child: Text(
                    'New Game',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Normal',
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (!kIsWeb)
                ElevatedButton(
                  onPressed: _opening
                      ? null
                      : () => _openGame(continuing: true),
                  child: Text(_opening ? 'Opening…' : 'Continue'),
                ),
              const Text(
                'Continue restores stats at the entrance; encounters restart.',
                textAlign: TextAlign.center,
              ),
              DefectorRadio<bool>(
                value: false,
                label: 'Keyboard',
                group: Game.useJoystick,
                onChange: (value) {
                  setState(() {
                    Game.useJoystick = value;
                  });
                },
              ),
              SizedBox(height: 10),
              DefectorRadio<bool>(
                value: true,
                group: Game.useJoystick,
                label: 'Joystick',
                onChange: (value) {
                  setState(() {
                    Game.useJoystick = value;
                  });
                },
              ),
              SizedBox(height: 20),
              if (!Game.useJoystick)
                SizedBox(
                  height: 80,
                  width: 200,
                  child: Sprite.load('keyboard_tip.png').asWidget(),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 20,
          margin: EdgeInsets.all(20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      getString('powered_by'),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Normal',
                        fontSize: 12.0,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _launchURL('https://github.com/RafaelBarbosatec');
                      },
                      child: Text(
                        'rafaelbarbosatec',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontFamily: 'Normal',
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      getString('built_with'),
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Normal',
                        fontSize: 12.0,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _launchURL(
                          'https://github.com/RafaelBarbosatec/bonfire',
                        );
                      },
                      child: Text(
                        'Bonfire',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.blue,
                          fontFamily: 'Normal',
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildSplash() {
    return FlameSplashScreen(
      theme: FlameSplashTheme.dark,
      onFinish: (BuildContext context) {
        setState(() {
          showSplash = false;
        });
        startTimer();
      },
    );
  }

  void startTimer() {
    _timer = async.Timer.periodic(Duration(seconds: 2), (timer) {
      setState(() {
        currentPosition++;
        if (currentPosition > sprites.length - 1) {
          currentPosition = 0;
        }
      });
    });
  }

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }
}
