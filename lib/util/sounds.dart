import 'package:flame_audio/flame_audio.dart';

class Sounds {
  static bool enabled = true;
  static AudioPool? _attackPlayerPool;
  static AudioPool? _attackRangePool;
  static AudioPool? _attackEnemyPool;
  static AudioPool? _explosionPool;
  static AudioPool? _interactionPool;

  static Future<void> initialize() async {
    if (!enabled) return;
    FlameAudio.bgm.initialize();
    try {
      _attackPlayerPool = await FlameAudio.createPool(
        'attack_player.mp3',
        minPlayers: 3,
        maxPlayers: 6,
      );
      _attackRangePool = await FlameAudio.createPool(
        'attack_fire_ball.wav',
        minPlayers: 3,
        maxPlayers: 6,
      );
      _attackEnemyPool = await FlameAudio.createPool(
        'attack_enemy.mp3',
        minPlayers: 3,
        maxPlayers: 6,
      );
      _explosionPool = await FlameAudio.createPool(
        'explosion.wav',
        minPlayers: 3,
        maxPlayers: 6,
      );
      _interactionPool = await FlameAudio.createPool(
        'sound_interaction.wav',
        minPlayers: 1,
        maxPlayers: 3,
      );
    } catch (_) {
      await FlameAudio.audioCache.loadAll([
        'attack_player.mp3',
        'attack_fire_ball.wav',
        'attack_enemy.mp3',
        'explosion.wav',
        'sound_interaction.wav',
      ]);
    }
  }

  static void attackPlayerMelee() {
    if (!enabled) return;
    if (_attackPlayerPool != null) {
      _attackPlayerPool!.start(volume: 0.4);
    } else {
      FlameAudio.play('attack_player.mp3', volume: 0.4);
    }
  }

  static void attackRange() {
    if (!enabled) return;
    if (_attackRangePool != null) {
      _attackRangePool!.start(volume: 0.3);
    } else {
      FlameAudio.play('attack_fire_ball.wav', volume: 0.3);
    }
  }

  static void attackEnemyMelee() {
    if (!enabled) return;
    if (_attackEnemyPool != null) {
      _attackEnemyPool!.start(volume: 0.4);
    } else {
      FlameAudio.play('attack_enemy.mp3', volume: 0.4);
    }
  }

  static void explosion() {
    if (!enabled) return;
    if (_explosionPool != null) {
      _explosionPool!.start();
    } else {
      FlameAudio.play('explosion.wav');
    }
  }

  static void interaction() {
    if (!enabled) return;
    if (_interactionPool != null) {
      _interactionPool!.start(volume: 0.4);
    } else {
      FlameAudio.play('sound_interaction.wav', volume: 0.4);
    }
  }

  static Future<void> stopBackgroundSound() {
    if (!enabled) return Future.value();
    return FlameAudio.bgm.stop();
  }

  static void playBackgroundSound() async {
    if (!enabled) return;
    await FlameAudio.bgm.stop();
    FlameAudio.bgm.play('sound_bg.mp3');
  }

  static void playBackgroundBoosSound() {
    if (!enabled) return;
    FlameAudio.bgm.play('battle_boss.mp3');
  }

  static void pauseBackgroundSound() {
    if (!enabled) return;
    FlameAudio.bgm.pause();
  }

  static void resumeBackgroundSound() {
    if (!enabled) return;
    FlameAudio.bgm.resume();
  }

  static void dispose() {
    FlameAudio.bgm.dispose();
    _attackPlayerPool?.dispose();
    _attackRangePool?.dispose();
    _attackEnemyPool?.dispose();
    _explosionPool?.dispose();
    _interactionPool?.dispose();
  }
}

