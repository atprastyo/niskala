import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('HD dungeon tiles preserve map layout and world geometry', () async {
    final map =
        jsonDecode(await rootBundle.loadString('assets/images/tiled/map.json'))
            as Map<String, dynamic>;
    final tileset = jsonDecode(
            await rootBundle.loadString('assets/images/tiled/tileSet.json'))
        as Map<String, dynamic>;
    // Captured before migration in world units at the existing 32px tile scale.
    final baseline = jsonDecode(
        await File('test/fixtures/dungeon_world_geometry.json')
            .readAsString()) as Map<String, dynamic>;
    expect(map['tilewidth'], 64);
    expect(map['tileheight'], 64);
    expect(map['width'], baseline['mapWidth']);
    expect(map['height'], baseline['mapHeight']);
    expect(tileset['tilewidth'], 64);
    expect(tileset['tileheight'], 64);
    expect(tileset['columns'], 7);
    expect(tileset['tilecount'], 49);
    expect(tileset['margin'], 0);
    expect(tileset['spacing'], 0);
    final data = await rootBundle.load('assets/images/tiled/tile_set.png');
    final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
    final image = (await codec.getNextFrame()).image;
    expect(image.width, 448);
    expect(image.height, 448);
    expect(tileset['imagewidth'], image.width);
    expect(tileset['imageheight'], image.height);
    image.dispose();
    codec.dispose();

    final factor =
        (baseline['worldTileSize'] as num) / (map['tilewidth'] as num);
    void checkRectangle(
        Map<String, dynamic> actual, Map<String, dynamic> expected) {
      for (final key in ['x', 'y', 'width', 'height']) {
        expect((actual[key] as num) * factor,
            closeTo(expected[key] as num, 0.000001),
            reason: '$key world coordinate changed');
      }
    }

    final objects = <int, Map<String, dynamic>>{};
    for (final layer in map['layers'] as List) {
      if (layer['type'] == 'tilelayer') {
        var hash = 2166136261;
        for (final gid in layer['data'] as List) {
          hash = ((hash ^ (gid as int)) * 16777619) & 0xffffffff;
        }
        expect(hash, baseline['layers'][layer['name']],
            reason: 'Tile IDs or ordering changed');
      } else if (layer['type'] == 'objectgroup') {
        for (final object in layer['objects'] as List) {
          objects[object['id'] as int] = object as Map<String, dynamic>;
        }
      }
    }
    expect(objects.length, (baseline['objects'] as List).length);
    for (final expected in baseline['objects'] as List) {
      final actual = objects[expected['id']]!;
      expect(actual['name'], expected['name']);
      checkRectangle(actual, expected as Map<String, dynamic>);
    }

    final collisions = <String, List<dynamic>>{};
    for (final tile in tileset['tiles'] as List) {
      if (tile['objectgroup'] != null) {
        collisions['${tile['id']}'] = tile['objectgroup']['objects'] as List;
      }
    }
    expect(
        collisions.keys, unorderedEquals((baseline['collisions'] as Map).keys));
    for (final entry
        in (baseline['collisions'] as Map<String, dynamic>).entries) {
      final expected = entry.value as List;
      final actual = collisions[entry.key]!;
      expect(actual.length, expected.length);
      for (var i = 0; i < actual.length; i++) {
        checkRectangle(actual[i] as Map<String, dynamic>,
            expected[i] as Map<String, dynamic>);
      }
    }
  });
}
