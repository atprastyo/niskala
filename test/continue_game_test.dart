import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/model/map_registry.dart';
import 'package:niskala/storage/continue_game.dart';
import 'package:niskala/storage/save_repository.dart';

class _Files implements SaveFiles {
  String? primary, previous;
  @override
  Future<String?> read({bool backup = false}) async =>
      backup ? previous : primary;
  @override
  Future<void> write(String encrypted, {bool backup = false}) async {
    if (backup) {
      previous = encrypted;
    } else {
      primary = encrypted;
    }
  }
}

class _Keys implements SaveKeyStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async => value = key;
}

void main() {
  late _Files files;
  late _Keys keys;
  late SaveRepository repository;
  setUp(() {
    files = _Files();
    keys = _Keys();
    repository = SaveRepository(files: files, keys: keys);
  });
  GameSession seed() => GameSession()
    ..currentMapId = 'prototype_dungeon'
    ..currentSpawnId = 'forest_gate'
    ..checkpointMapId = 'prototype_village'
    ..checkpointSpawnId = 'start';

  test('fresh repository restores saved state without writing', () async {
    final session = seed();
    session.health = 120;
    session.progression.gainExp(20);
    session.campaign.recordArrival('prototype_dungeon', 'forest_gate');
    await repository.save(session);
    final original = files.primary;
    final result = (await ContinueGame(
      MapRegistry.development,
      (_) async {},
    ).load(SaveRepository(files: files, keys: keys)))!;
    expect(result.session, isNot(same(session)));
    expect(result.session.currentMapId, 'prototype_dungeon');
    expect(result.session.health, 120);
    expect(result.session.progression.currentExp, 20);
    expect(result.session.campaign.discoveredLocations['prototype_dungeon'], {
      'forest_gate',
    });
    expect(result.relocated, isFalse);
    expect(files.primary, original);
  });

  test(
    'missing current asset falls back to checkpoint without erasing save',
    () async {
      await repository.save(seed());
      final original = files.primary;
      final checked = <String>[];
      final result = (await ContinueGame(MapRegistry.development, (
        destination,
      ) async {
        checked.add(destination.map.id);
        if (destination.map.id == 'prototype_dungeon') {
          throw const FormatException('Missing image');
        }
      }).load(repository))!;
      expect(checked, ['prototype_dungeon', 'prototype_village']);
      expect(result.relocated, isTrue);
      expect(result.session.currentMapId, 'prototype_village');
      expect(files.primary, original);
    },
  );

  test(
    'removed location IDs fall back to the registered safe location',
    () async {
      await repository.save(
        seed()
          ..currentMapId = 'removed_map'
          ..checkpointMapId = 'removed_checkpoint',
      );
      final result = (await ContinueGame(
        MapRegistry.development,
        (_) async {},
      ).load(repository))!;
      expect(result.session.currentMapId, 'dev_dungeon');
      expect(result.session.currentSpawnId, 'start');
      expect(result.relocated, isTrue);
    },
  );

  test(
    'all asset failures preserve the slot and report load failure',
    () async {
      await repository.save(seed());
      final original = files.primary;
      await expectLater(
        ContinueGame(
          MapRegistry.development,
          (_) async => throw StateError('Unavailable'),
        ).load(repository),
        throwsA(isA<SaveException>()),
      );
      expect(files.primary, original);
    },
  );

  test('backup recovery is reported without rewriting primary', () async {
    await repository.save(seed());
    await repository.save(seed());
    files.primary = 'broken';
    final result = (await ContinueGame(
      MapRegistry.development,
      (_) async {},
    ).load(repository))!;
    expect(result.recoveredFromBackup, isTrue);
    expect(files.primary, 'broken');
  });

  test(
    'empty, incompatible, and keyless saves never start a fresh campaign',
    () async {
      final service = ContinueGame(MapRegistry.development, (_) async {});
      expect(await service.load(repository), isNull);
      await repository.save(seed());
      final original = files.primary;
      keys.value = null;
      await expectLater(
        service.load(repository),
        throwsA(isA<SaveException>()),
      );
      expect(files.primary, original);
      keys.value = base64Encode(List.filled(32, 1));
      files.primary = jsonEncode({'version': 99});
      await expectLater(
        service.load(repository),
        throwsA(isA<SaveException>()),
      );
      expect(files.primary, jsonEncode({'version': 99}));
    },
  );
}
