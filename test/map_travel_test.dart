import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/model/map_registry.dart';
import 'package:niskala/model/map_travel.dart';
import 'package:niskala/model/campaign_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'exit requirements are checked before loading or changing location',
    () async {
      final map = MapDefinition(
        id: 'test_map',
        asset: 'tiled/map.json',
        kind: MapKind.sandbox,
        widthInTiles: 50,
        heightInTiles: 50,
        spawns: {'start': const MapSpawn(2, 3)},
        exits: [
          const MapExit(
            id: 'gate',
            label: 'Gate',
            tileX: 5,
            tileY: 5,
            destinationMapId: 'test_map',
            destinationSpawnId: 'start',
            returnSpawnId: 'start',
            requiredFact: 'permission_received',
          ),
        ],
      );
      final registry = MapRegistry([
        map,
      ], fallback: TravelLocation('test_map', 'start'));
      final session = GameSession()..currentMapId = 'test_map';
      final travel = MapTravel(session, registry);
      await expectLater(
        travel.travel('gate', (_) async => fail('Locked exit loaded')),
        throwsStateError,
      );
      expect(session.campaign.returnLocations, isEmpty);
      session.campaign.recordFact('permission_received');
      expect(await travel.travel('gate', (_) async {}), isTrue);
    },
  );
  GameSession start() => GameSession()
    ..currentMapId = 'prototype_village'
    ..currentSpawnId = 'start';

  test(
    'defeat recovery preserves the campaign and refills resources at checkpoint',
    () async {
      final session = start();
      session.progression.gainExp(20);
      session.campaign.addItem('potion', quantity: 2);
      session.campaign.receiveIngredient('boss_01', 'daun_embun');
      final travel = MapTravel(session, MapRegistry.development);
      travel.setCheckpoint();
      await travel.travel('forest_gate', (_) async {});
      session.health = 0;
      session.stamina = 5;
      await travel.recover((destination) async {
        expect(destination.map.id, 'prototype_village');
        expect(session.currentMapId, 'prototype_wilderness');
        expect(travel.busy, isTrue);
        expect(session.health, session.progression.maxLife);
      });
      expect(session.currentMapId, 'prototype_village');
      expect(session.currentSpawnId, 'start');
      expect(session.health, session.progression.maxLife);
      expect(session.stamina, session.progression.maxStamina);
      expect(session.progression.currentExp, 20);
      expect(session.campaign.inventory['potion'], 2);
      expect(session.campaign.ingredients, {'daun_embun'});
      expect(
        await travel.recover((_) async => fail('Alive recovery')),
        isFalse,
      );
    },
  );

  test('failed recovery rolls back resources and permits retry', () async {
    final session = start()..health = 0;
    session.stamina = 5;
    final travel = MapTravel(session, MapRegistry.development);
    await expectLater(
      travel.recover((_) async => throw StateError('Unavailable')),
      throwsStateError,
    );
    expect(session.health, 0);
    expect(session.stamina, 5);
    expect(session.currentMapId, 'prototype_village');
    expect(travel.busy, isFalse);
    expect(await travel.recover((_) async {}), isTrue);
  });

  test(
    'unavailable checkpoint uses and records the registered fallback',
    () async {
      final session = start()..health = 0;
      session.checkpointMapId = 'removed_map';
      final travel = MapTravel(session, MapRegistry.development);
      await travel.recover((destination) async {
        expect(destination.map.id, 'dev_dungeon');
      });
      expect(session.checkpointMapId, 'dev_dungeon');
      expect(session.checkpointSpawnId, 'start');
    },
  );

  test('full travel loop retains resources and campaign state', () async {
    final session = start()..health = 150;
    session.stamina = 50;
    session.progression.gainExp(20);
    session.campaign.recordFact('talked_to_ratih');
    final travel = MapTravel(session, MapRegistry.development);
    final maps = <String>[];
    for (final exit in [
      'forest_gate',
      'dungeon_gate',
      'forest_gate',
      'village_gate',
    ]) {
      expect(
        await travel.travel(
          exit,
          (destination) async => maps.add(destination.map.id),
        ),
        isTrue,
      );
    }
    expect(maps, [
      'prototype_wilderness',
      'prototype_dungeon',
      'prototype_wilderness',
      'prototype_village',
    ]);
    expect(session.currentSpawnId, 'forest_gate');
    expect(session.health, 150);
    expect(session.stamina, 50);
    expect(session.progression.currentExp, 20);
    expect(session.campaign.facts, {'talked_to_ratih'});
    expect(
      session.campaign.returnLocations['prototype_dungeon']!.mapId,
      'prototype_wilderness',
    );
    expect(
      session.campaign.returnLocations['prototype_dungeon']!.spawnId,
      'dungeon_gate',
    );
  });

  test(
    'duplicate requests are locked and location commits only after ready',
    () async {
      final session = start();
      final travel = MapTravel(session, MapRegistry.development);
      final ready = Completer<void>();
      final first = travel.travel('forest_gate', (_) => ready.future);
      expect(travel.busy, isTrue);
      expect(session.currentMapId, 'prototype_village');
      expect(session.campaign.returnLocations, isEmpty);
      expect(
        await travel.travel('forest_gate', (_) async => fail('Duplicate load')),
        isFalse,
      );
      ready.complete();
      expect(await first, isTrue);
      expect(session.currentMapId, 'prototype_wilderness');
      expect(travel.busy, isFalse);
    },
  );

  test(
    'failed load leaves location and returns untouched and allows retry',
    () async {
      final session = start();
      final travel = MapTravel(session, MapRegistry.development);
      await expectLater(
        travel.travel(
          'forest_gate',
          (_) async => throw StateError('Failed asset load'),
        ),
        throwsStateError,
      );
      expect(session.currentMapId, 'prototype_village');
      expect(session.campaign.returnLocations, isEmpty);
      expect(travel.busy, isFalse);
      expect(await travel.travel('forest_gate', (_) async {}), isTrue);
    },
  );

  test(
    'all prototype spawns are walkable and separated from triggers',
    () async {
      for (final id in [
        'prototype_village',
        'prototype_wilderness',
        'prototype_dungeon',
      ]) {
        final spawnId = id == 'prototype_village'
            ? 'start'
            : id == 'prototype_dungeon'
            ? 'forest_gate'
            : 'village_gate';
        final map = MapRegistry.development.resolve(id, spawnId).map;
        final asset =
            jsonDecode(
                  await rootBundle.loadString('assets/images/${map.asset}'),
                )
                as Map<String, dynamic>;
        final tiles = ((asset['layers'] as List).first as Map)['data'] as List;
        expect(asset['width'], map.widthInTiles);
        expect(asset['height'], map.heightInTiles);
        for (final spawn in map.spawns.values) {
          expect(
            tiles[spawn.tileY.toInt() * map.widthInTiles + spawn.tileX.toInt()],
            isNot(1),
          );
          for (final exit in map.exits) {
            expect(
              (spawn.tileX - exit.tileX).abs() +
                  (spawn.tileY - exit.tileY).abs(),
              greaterThanOrEqualTo(2),
            );
          }
        }
      }
    },
  );
}
