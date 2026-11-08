import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/storage/native_save_files.dart';
import 'package:niskala/storage/save_repository.dart';

class MemoryKeys implements SaveKeyStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async => value = key;
}

void main() {
  late Directory directory;
  late NativeSaveFiles files;
  late MemoryKeys keys;
  late SaveRepository repository;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('niskala-save-test-');
    files = NativeSaveFiles(directory);
    keys = MemoryKeys();
    repository = SaveRepository(files: files, keys: keys);
  });
  tearDown(() => directory.delete(recursive: true));

  test('empty slot does not create a key', () async {
    expect(await repository.load(), isNull);
    expect(keys.value, isNull);
  });

  test('encrypted disk round trip survives repository reconstruction',
      () async {
    final session = GameSession();
    session.progression.gainExp(20);
    session.health = 123;
    session.stamina = 42;
    session.currentMapId = 'hutan_embun';
    session.currentSpawnId = 'village_gate';
    session.checkpointMapId = 'kamboja';
    session.checkpointSpawnId = 'home';
    await repository.save(session);
    final encoded = (await files.read())!;
    expect(encoded, isNot(contains('hutan_embun')));
    expect(encoded, isNot(contains('health')));
    expect(encoded, isNot(contains(keys.value!)));
    final restored = (await SaveRepository(files: files, keys: keys).load())!;
    expect(restored.session.health, 123);
    expect(restored.session.stamina, 42);
    expect(restored.session.progression.currentExp, 20);
    expect(restored.session.currentMapId, 'hutan_embun');
    expect(restored.session.currentSpawnId, 'village_gate');
    expect(restored.session.checkpointMapId, 'kamboja');
    expect(restored.session.checkpointSpawnId, 'home');
    expect(restored.recoveredFromBackup, isFalse);
  });

  test('each save uses a fresh nonce and keeps an encrypted backup', () async {
    await repository.save(GameSession());
    final first = (await files.read())!;
    await repository.save(GameSession());
    expect(await files.read(), isNot(first));
    expect(await files.read(backup: true), first);
  });

  test('modified ciphertext is rejected without overwriting data', () async {
    await repository.save(GameSession());
    final data = jsonDecode((await files.read())!) as Map<String, dynamic>;
    final bytes = base64Decode(data['ciphertext'] as String);
    bytes[0] ^= 1;
    data['ciphertext'] = base64Encode(bytes);
    final modified = jsonEncode(data);
    await files.write(modified);
    await expectLater(repository.load(), throwsA(isA<SaveException>()));
    await expectLater(
        repository.save(GameSession()), throwsA(isA<SaveException>()));
    expect(await files.read(), modified);
  });

  test('corrupt primary recovers backup and subsequent save preserves it',
      () async {
    final session = GameSession()..health = 100;
    await repository.save(session);
    session.health = 150;
    await repository.save(session);
    await files.write('broken');
    final recovered = (await repository.load())!;
    expect(recovered.recoveredFromBackup, isTrue);
    expect(recovered.session.health, 100);
    await repository.save(recovered.session);
    expect((await repository.load())!.session.health, 100);
    expect(await files.read(backup: true), isNot('broken'));
  });

  test('missing key never silently replaces an existing key or save', () async {
    await repository.save(GameSession());
    final original = await files.read();
    keys.value = null;
    await expectLater(repository.load(), throwsA(isA<SaveException>()));
    await expectLater(
        repository.save(GameSession()), throwsA(isA<SaveException>()));
    expect(keys.value, isNull);
    expect(await files.read(), original);
  });

  test('wrong key fails authentication and preserves existing files', () async {
    await repository.save(GameSession());
    final original = await files.read();
    keys.value = base64Encode(List.filled(32, 0));
    await expectLater(repository.load(), throwsA(isA<SaveException>()));
    await expectLater(
        repository.save(GameSession()), throwsA(isA<SaveException>()));
    expect(await files.read(), original);
  });

  test('backup recovers when primary is missing after an interrupted write',
      () async {
    await repository.save(GameSession()..health = 100);
    await repository.save(GameSession()..health = 120);
    await File('${directory.path}/campaign.enc').delete();
    final result = (await repository.load())!;
    expect(result.recoveredFromBackup, isTrue);
    expect(result.session.health, 100);
  });

  test('queued saves retain request snapshots', () async {
    final session = GameSession()..health = 100;
    final first = repository.save(session);
    session.health = 120;
    final second = repository.save(session);
    await Future.wait([first, second]);
    expect((await repository.load())!.session.health, 120);
    await files.write('broken');
    expect((await repository.load())!.session.health, 100);
  });

  test('invalid session is rejected before writing', () async {
    expect(() => repository.save(GameSession()..health = double.nan),
        throwsFormatException);
    expect(await files.read(), isNull);
  });
}
