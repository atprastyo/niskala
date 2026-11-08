import 'dart:async';
import 'dart:convert';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/services.dart';
import 'package:niskala/model/map_registry.dart';
import 'package:niskala/model/map_travel.dart';
import 'package:niskala/util/sounds.dart';
import 'package:flutter/material.dart';
import 'package:niskala/game.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/storage/save_repository.dart';

/// Holds the game widget stable while storage controls rebuild.
class SavedGame extends StatefulWidget {
  final GameSession session;
  final SaveRepository? repository;
  final MapRegistry? registry;
  const SavedGame({
    super.key,
    required this.session,
    this.repository,
    this.registry,
  });

  @override
  State<SavedGame> createState() => _SavedGameState();
}

class _SavedGameState extends State<SavedGame> {
  late final MapRegistry _registry = widget.registry ?? MapRegistry.development;
  late final MapTravel _travel = MapTravel(widget.session, _registry);
  late List<_Scene> _scenes = [
    _makeScene(
      _registry.resolve(
        widget.session.currentMapId,
        widget.session.currentSpawnId,
      ),
    ),
  ];
  bool _changing = false;

  _Scene _makeScene(MapDestination destination, [Completer<void>? ready]) {
    final scene = _Scene();
    scene.view = Game(
      initialSession: widget.session,
      destination: destination,
      onTravel: _go,
      focusNode: scene.focus,
      onReady: (engine) {
        scene.engine = engine;
        if (ready != null) {
          engine.pauseEngine();
          if (!ready.isCompleted) ready.complete();
        }
      },
      onRestart: _recover,
    );
    return scene;
  }

  Future<void> _load(MapDestination destination) async {
    final data =
        jsonDecode(
              await rootBundle.loadString(
                'assets/images/${destination.map.asset}',
              ),
            )
            as Map<String, dynamic>;
    if (data['width'] != destination.map.widthInTiles ||
        data['height'] != destination.map.heightInTiles) {
      throw const FormatException('Map dimensions do not match registry');
    }
    if (!mounted) throw StateError('Game closed');
    final ready = Completer<void>();
    final candidate = _makeScene(destination, ready);
    setState(() => _scenes = [..._scenes, candidate]);
    await ready.future.timeout(const Duration(seconds: 15));
    if (!mounted) throw StateError('Game closed');
  }

  Future<void> _go(String exitId) async {
    if (widget.session.health <= 0) return;
    await _change((load) => _travel.travel(exitId, load));
  }

  Future<void> _recover() => _change(_travel.recover, recovery: true);

  Future<void> _change(
    Future<bool> Function(Future<void> Function(MapDestination)) operation, {
    bool recovery = false,
  }) async {
    if (_changing || _saving || _scenes.single.engine == null) return;
    final old = _scenes.single;
    final health = widget.session.health, stamina = widget.session.stamina;
    old.engine!.pauseEngine();
    setState(() => _changing = true);
    try {
      final changed = await operation(_load);
      if (!mounted) return;
      if (changed) {
        final arrived = _scenes.last;
        setState(() => _scenes = [arrived]);
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => old.focus.dispose(),
        );
        arrived.engine!.resumeEngine();
      } else {
        old.engine!.resumeEngine();
      }
    } catch (_) {
      if (!mounted) return;
      widget.session.health = health;
      widget.session.stamina = stamina;
      final discarded = _scenes.where((scene) => scene != old).toList();
      setState(() => _scenes = [old]);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final scene in discarded) {
          scene.focus.dispose();
        }
      });
      old.engine!.resumeEngine();
      _message(
        recovery
            ? 'Could not recover. Retry checkpoint recovery.'
            : 'Could not travel. You are still in the previous area.',
      );
    } finally {
      if (mounted) {
        setState(() => _changing = false);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _scenes.single.focus.requestFocus();
            Sounds.playBackgroundSound();
          }
        });
      }
    }
  }

  bool _saving = false;

  @override
  void dispose() {
    for (final scene in _scenes) {
      scene.focus.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || _changing || widget.repository == null) return;
    if (widget.session.health <= 0) {
      _message('Cannot save after defeat.');
      return;
    }
    setState(() => _saving = true);
    final oldCheckpointMap = widget.session.checkpointMapId;
    final oldCheckpointSpawn = widget.session.checkpointSpawnId;
    try {
      _travel.setCheckpoint();
      await widget.repository!.save(widget.session);
      if (mounted) _message('Saved. Continue returns to this area’s entrance.');
    } catch (_) {
      widget.session.checkpointMapId = oldCheckpointMap;
      widget.session.checkpointSpawnId = oldCheckpointSpawn;
      if (mounted) {
        _message('Could not save. Try again.');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        for (final scene in _scenes)
          Positioned.fill(
            key: scene.key,
            child: ExcludeFocus(
              excluding: _changing || scene != _scenes.last,
              child: AbsorbPointer(absorbing: _changing, child: scene.view),
            ),
          ),
        if (_changing)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0xCC000000),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        Positioned(
          top: 8,
          right: 8,
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.session.health <= 0)
                  ElevatedButton(
                    onPressed: _changing || _saving ? null : _recover,
                    child: const Text('Retry recovery'),
                  ),
                if (widget.repository != null)
                  ElevatedButton(
                    onPressed: _saving || _changing ? null : _save,
                    child: Text(_saving ? 'Saving…' : 'Save at entrance'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saving || _changing
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Menu'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _Scene {
  final Key key = UniqueKey();
  final FocusNode focus = FocusNode();
  late Widget view;
  BonfireGameInterface? engine;
}
