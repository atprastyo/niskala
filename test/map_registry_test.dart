import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/model/campaign_state.dart';
import 'package:niskala/model/map_registry.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  MapDefinition definition({Map<String, MapSpawn>? spawns}) => MapDefinition(
    id: 'village_test',
    asset: 'tiled/village_test.json',
    kind: MapKind.village,
    widthInTiles: 10,
    heightInTiles: 10,
    spawns: spawns ?? {'gate': const MapSpawn(2, 3)},
  );

  test(
    'sandbox registry matches the existing map asset and entry point',
    () async {
      final destination = MapRegistry.development.resolve(
        'dev_dungeon',
        'start',
      );
      final map =
          jsonDecode(
                await rootBundle.loadString(
                  'assets/images/${destination.map.asset}',
                ),
              )
              as Map<String, dynamic>;
      expect(destination.map.widthInTiles, map['width']);
      expect(destination.map.heightInTiles, map['height']);
      expect(destination.spawn.tileX, 2);
      expect(destination.spawn.tileY, 3);
    },
  );

  test('unknown maps and named spawns are rejected', () {
    expect(
      () => MapRegistry.development.resolve('missing', 'start'),
      throwsArgumentError,
    );
    expect(
      () => MapRegistry.development.resolve('dev_dungeon', 'missing'),
      throwsArgumentError,
    );
  });

  test('spawn maps are immutable copies', () {
    final spawns = {'gate': const MapSpawn(2, 3)};
    final map = definition(spawns: spawns);
    spawns.clear();
    expect(map.spawns.containsKey('gate'), isTrue);
    expect(() => map.spawns.clear(), throwsUnsupportedError);
  });

  test('invalid and out-of-bounds spawns are rejected', () {
    for (final spawn in [
      const MapSpawn(-1, 0),
      const MapSpawn(10, 0),
      const MapSpawn(0, double.nan),
    ]) {
      expect(() => definition(spawns: {'gate': spawn}), throwsArgumentError);
    }
    expect(() => definition(spawns: {}), throwsArgumentError);
  });

  test('duplicate maps and invalid registry fallback are rejected', () {
    expect(
      () => MapRegistry([
        definition(),
        definition(),
      ], fallback: TravelLocation('village_test', 'gate')),
      throwsArgumentError,
    );
    expect(
      () => MapRegistry([
        definition(),
      ], fallback: TravelLocation('village_test', 'missing')),
      throwsArgumentError,
    );
  });

  test('saved location resolves current, then checkpoint, then fallback', () {
    final registry = MapRegistry([
      definition(),
      MapDefinition(
        id: 'forest_test',
        asset: 'tiled/forest_test.json',
        kind: MapKind.wilderness,
        widthInTiles: 10,
        heightInTiles: 10,
        spawns: {'path': const MapSpawn(4, 4)},
      ),
    ], fallback: TravelLocation('village_test', 'gate'));
    final current = TravelLocation('forest_test', 'path');
    final checkpoint = TravelLocation('village_test', 'gate');
    expect(
      registry.resolveSavedLocation(current, checkpoint).map.id,
      'forest_test',
    );
    expect(
      registry
          .resolveSavedLocation(
            TravelLocation('forest_test', 'missing'),
            checkpoint,
          )
          .map
          .id,
      'village_test',
    );
    expect(
      registry
          .resolveSavedLocation(
            TravelLocation('missing', 'start'),
            TravelLocation('missing', 'start'),
          )
          .spawnId,
      'gate',
    );
  });
}
