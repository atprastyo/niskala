import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/model/progression.dart';

abstract interface class SaveFiles {
  Future<String?> read({bool backup = false});
  Future<void> write(String encrypted, {bool backup = false});
}

abstract interface class SaveKeyStore {
  Future<String?> read();
  Future<void> write(String key);
}

class PlatformSaveKeyStore implements SaveKeyStore {
  final FlutterSecureStorage storage;
  PlatformSaveKeyStore({this.storage = const FlutterSecureStorage()});
  static const keyId = 'niskala_save_key_v1';

  @override
  Future<String?> read() => storage.read(key: keyId);
  @override
  Future<void> write(String key) => storage.write(key: keyId, value: key);
}

class SaveException implements Exception {
  final String message;
  const SaveException(this.message);
  @override
  String toString() => 'SaveException: $message';
}

class LoadedSave {
  final GameSession session;
  final bool recoveredFromBackup;
  LoadedSave(this.session, {this.recoveredFromBackup = false});
}

/// Use one instance per save slot. Operations are serialized, including key
/// creation. Payloads and keys must never be logged.
class SaveRepository {
  final SaveFiles files;
  final SaveKeyStore keys;
  final _cipher = AesGcm.with256bits();
  Future<void> _pending = Future.value();
  static final _aad = utf8.encode('niskala-save:v1');

  SaveRepository({required this.files, required this.keys});

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final result = _pending.then((_) => action());
    _pending = result.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return result;
  }

  Future<SecretKey> _key({required bool allowCreate}) async {
    var encoded = await keys.read();
    if (encoded == null) {
      if (!allowCreate) {
        throw const SaveException(
          'Save key is missing; existing data preserved.',
        );
      }
      encoded = base64Encode(
        await (await _cipher.newSecretKey()).extractBytes(),
      );
      await keys.write(encoded);
      if (await keys.read() != encoded) {
        throw const SaveException(
          'Secure storage did not retain the save key.',
        );
      }
    }
    try {
      final bytes = base64Decode(encoded);
      if (bytes.length != 32) throw const FormatException();
      return SecretKey(bytes);
    } on FormatException {
      throw const SaveException(
        'Save key is invalid; existing data preserved.',
      );
    }
  }

  Future<void> save(GameSession session) {
    // Capture before queuing so later actor mutations do not alter this request.
    final payload = _encodeSession(session);
    return _exclusive(() async {
      final primary = await files.read();
      final backup = await files.read(backup: true);
      final key = await _key(allowCreate: primary == null && backup == null);
      if (primary != null) {
        try {
          await _decrypt(primary, key);
          await files.write(primary, backup: true);
        } on SaveException {
          // Preserve a valid recovery copy rather than backing up corruption.
          if (backup == null) rethrow;
          await _decrypt(backup, key);
        }
      } else if (backup != null) {
        await _decrypt(backup, key);
      }
      final box = await _cipher.encrypt(
        utf8.encode(jsonEncode(payload)),
        secretKey: key,
        aad: _aad,
      );
      await files.write(
        jsonEncode({
          'version': 1,
          'nonce': base64Encode(box.nonce),
          'ciphertext': base64Encode(box.cipherText),
          'tag': base64Encode(box.mac.bytes),
        }),
      );
    });
  }

  Future<LoadedSave?> load() => _exclusive(() async {
    final primary = await files.read();
    final backup = await files.read(backup: true);
    if (primary == null && backup == null) return null;
    final key = await _key(allowCreate: false);
    if (primary != null) {
      try {
        return LoadedSave(await _decrypt(primary, key));
      } on SaveException {
        if (backup == null) rethrow;
      }
    }
    return LoadedSave(await _decrypt(backup!, key), recoveredFromBackup: true);
  });

  Future<GameSession> _decrypt(String encoded, SecretKey key) async {
    try {
      final data = jsonDecode(encoded) as Map<String, dynamic>;
      if (data['version'] != 1) throw const FormatException();
      final nonce = base64Decode(data['nonce'] as String);
      final tag = base64Decode(data['tag'] as String);
      if (nonce.length != 12 || tag.length != 16) {
        throw const FormatException();
      }
      final bytes = await _cipher.decrypt(
        SecretBox(
          base64Decode(data['ciphertext'] as String),
          nonce: nonce,
          mac: Mac(tag),
        ),
        secretKey: key,
        aad: _aad,
      );
      return _decodeSession(jsonDecode(utf8.decode(bytes)));
    } on SecretBoxAuthenticationError {
      throw const SaveException('Save authentication failed.');
    } on FormatException {
      throw const SaveException(
        'Save is corrupt or has an unsupported version.',
      );
    } on TypeError {
      throw const SaveException('Save has an invalid structure.');
    }
  }
}

Map<String, Object> _encodeSession(GameSession session) {
  final data = <String, Object>{
    'version': 1,
    'level': session.progression.level,
    'xp': session.progression.currentExp,
    'health': session.health,
    'stamina': session.stamina,
    'map': session.currentMapId,
    'spawn': session.currentSpawnId,
    'checkpointMap': session.checkpointMapId,
    'checkpointSpawn': session.checkpointSpawnId,
    'rewardClaims': session.rewardClaims.toList()..sort(),
  };
  _decodeSession(data);
  return data;
}

GameSession _decodeSession(dynamic value) {
  final data = value as Map<String, dynamic>;
  final level = data['level'] as int;
  final xp = data['xp'] as int;
  if (data['version'] != 1 ||
      level < 1 ||
      level > 100 ||
      xp < 0 ||
      (level == 100
          ? xp != 0
          : xp >= PlayerProgression.expToNextLevelFor(level))) {
    throw const FormatException('Invalid progression');
  }
  final session = GameSession(
    progression: PlayerProgression(level: level, currentExp: xp),
    rewardClaims: (data['rewardClaims'] as List<dynamic>? ?? const [])
        .cast<String>(),
  );
  double resource(String name, double maximum) {
    final result = (data[name] as num).toDouble();
    if (!result.isFinite || result < 0 || result > maximum) {
      throw const FormatException('Invalid resource');
    }
    return result;
  }

  String id(String name) {
    final result = data[name] as String;
    if (!RegExp(r'^[a-z][a-z0-9_]{0,127}$').hasMatch(result)) {
      throw const FormatException('Invalid location identifier');
    }
    return result;
  }

  session.health = resource('health', session.progression.maxLife);
  session.stamina = resource('stamina', session.progression.maxStamina);
  session.currentMapId = id('map');
  session.currentSpawnId = id('spawn');
  session.checkpointMapId = id('checkpointMap');
  session.checkpointSpawnId = id('checkpointSpawn');
  return session;
}
