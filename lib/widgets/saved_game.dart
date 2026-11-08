import 'package:flutter/material.dart';
import 'package:niskala/game.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/storage/save_repository.dart';

/// Holds the game widget stable while storage controls rebuild.
class SavedGame extends StatefulWidget {
  final GameSession session;
  final SaveRepository? repository;
  const SavedGame({super.key, required this.session, this.repository});

  @override
  State<SavedGame> createState() => _SavedGameState();
}

class _SavedGameState extends State<SavedGame> {
  late final Widget _game = Game(
    initialSession: widget.session,
    onRestart: () => Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            SavedGame(session: GameSession(), repository: widget.repository),
      ),
    ),
  );
  bool _saving = false;

  Future<void> _save() async {
    if (_saving || widget.repository == null) return;
    if (widget.session.health <= 0) {
      _message('Cannot save after defeat.');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.repository!.save(widget.session);
      if (mounted) _message('Saved. Continue returns to the dungeon entrance.');
    } catch (_) {
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
        Positioned.fill(child: _game),
        Positioned(
          top: 8,
          right: 8,
          child: SafeArea(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.repository != null)
                  ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: Text(_saving ? 'Saving…' : 'Save at entrance'),
                  ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saving ? null : () => Navigator.of(context).pop(),
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
