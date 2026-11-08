import 'campaign_state.dart';

enum MapKind { sandbox, village, wilderness, dungeon }

void _identifier(String value) {
  if (!RegExp(r'^[a-z][a-z0-9_]{0,127}$').hasMatch(value)) {
    throw ArgumentError.value(value, 'identifier');
  }
}

/// Coordinates are in tiles; the renderer converts them to world units.
class MapSpawn {
  final double tileX;
  final double tileY;
  const MapSpawn(this.tileX, this.tileY);
}

class MapExit {
  final String id, label, destinationMapId, destinationSpawnId, returnSpawnId;
  final double tileX, tileY;
  const MapExit({
    required this.id,
    required this.label,
    required this.tileX,
    required this.tileY,
    required this.destinationMapId,
    required this.destinationSpawnId,
    required this.returnSpawnId,
  });
}

class MapDefinition {
  final String id;
  final String asset;
  final MapKind kind;
  final int widthInTiles;
  final int heightInTiles;
  final Map<String, MapSpawn> spawns;
  final List<MapExit> exits;

  MapDefinition({
    required this.id,
    required this.asset,
    required this.kind,
    required this.widthInTiles,
    required this.heightInTiles,
    required Map<String, MapSpawn> spawns,
    List<MapExit> exits = const [],
  }) : spawns = Map.unmodifiable(spawns),
       exits = List.unmodifiable(exits) {
    _identifier(id);
    if (!asset.startsWith('tiled/') ||
        !asset.endsWith('.json') ||
        asset.contains('..') ||
        asset.contains('\\') ||
        widthInTiles <= 0 ||
        heightInTiles <= 0 ||
        spawns.isEmpty) {
      throw ArgumentError('Invalid map definition: $id');
    }
    for (final entry in spawns.entries) {
      _identifier(entry.key);
      final spawn = entry.value;
      if (!spawn.tileX.isFinite ||
          !spawn.tileY.isFinite ||
          spawn.tileX < 0 ||
          spawn.tileY < 0 ||
          spawn.tileX >= widthInTiles ||
          spawn.tileY >= heightInTiles) {
        throw ArgumentError('Spawn is outside map bounds: $id/${entry.key}');
      }
    }
    final ids = <String>{};
    for (final exit in exits) {
      for (final id in [
        exit.id,
        exit.destinationMapId,
        exit.destinationSpawnId,
        exit.returnSpawnId,
      ]) {
        _identifier(id);
      }
      if (!ids.add(exit.id) ||
          !exit.tileX.isFinite ||
          !exit.tileY.isFinite ||
          exit.tileX < 0 ||
          exit.tileY < 0 ||
          exit.tileX + 1 > widthInTiles ||
          exit.tileY + 1 > heightInTiles ||
          !spawns.containsKey(exit.returnSpawnId)) {
        throw ArgumentError('Invalid map exit: ${exit.id}');
      }
    }
  }
}

class MapDestination {
  final MapDefinition map;
  final String spawnId;
  MapSpawn get spawn => map.spawns[spawnId]!;
  MapDestination._(this.map, this.spawnId);
}

class MapRegistry {
  final Map<String, MapDefinition> _maps = {};
  final TravelLocation fallback;

  MapRegistry(Iterable<MapDefinition> maps, {required this.fallback}) {
    for (final map in maps) {
      if (_maps.containsKey(map.id)) {
        throw ArgumentError('Duplicate map: ${map.id}');
      }
      _maps[map.id] = map;
    }
    resolve(fallback.mapId, fallback.spawnId);
    for (final map in _maps.values) {
      for (final exit in map.exits) {
        resolve(exit.destinationMapId, exit.destinationSpawnId);
      }
    }
  }

  MapDestination resolve(String mapId, String spawnId) {
    final map = _maps[mapId];
    if (map == null || !map.spawns.containsKey(spawnId)) {
      throw ArgumentError('Unknown map/spawn: $mapId/$spawnId');
    }
    return MapDestination._(map, spawnId);
  }

  /// Validates IDs only. Asset loading and collision checks belong to the loader.
  MapDestination resolveSavedLocation(
    TravelLocation current,
    TravelLocation checkpoint,
  ) {
    for (final location in [current, checkpoint, fallback]) {
      final map = _maps[location.mapId];
      if (map != null && map.spawns.containsKey(location.spawnId)) {
        return MapDestination._(map, location.spawnId);
      }
    }
    throw StateError('Registry fallback must be valid');
  }

  static final development = MapRegistry([
    MapDefinition(
      id: 'dev_dungeon',
      asset: 'tiled/map.json',
      kind: MapKind.sandbox,
      widthInTiles: 50,
      heightInTiles: 50,
      spawns: {'start': const MapSpawn(2, 3)},
    ),
    MapDefinition(
      id: 'prototype_village',
      asset: 'tiled/prototype_village.json',
      kind: MapKind.village,
      widthInTiles: 16,
      heightInTiles: 12,
      spawns: {
        'start': const MapSpawn(8, 6),
        'forest_gate': const MapSpawn(11, 5),
      },
      exits: [
        const MapExit(
          id: 'forest_gate',
          label: 'Forest',
          tileX: 13,
          tileY: 5,
          destinationMapId: 'prototype_wilderness',
          destinationSpawnId: 'village_gate',
          returnSpawnId: 'forest_gate',
        ),
      ],
    ),
    MapDefinition(
      id: 'prototype_wilderness',
      asset: 'tiled/prototype_wilderness.json',
      kind: MapKind.wilderness,
      widthInTiles: 16,
      heightInTiles: 12,
      spawns: {
        'village_gate': const MapSpawn(3, 5),
        'dungeon_gate': const MapSpawn(11, 5),
      },
      exits: [
        const MapExit(
          id: 'village_gate',
          label: 'Village',
          tileX: 1,
          tileY: 5,
          destinationMapId: 'prototype_village',
          destinationSpawnId: 'forest_gate',
          returnSpawnId: 'village_gate',
        ),
        const MapExit(
          id: 'dungeon_gate',
          label: 'Dungeon',
          tileX: 13,
          tileY: 5,
          destinationMapId: 'prototype_dungeon',
          destinationSpawnId: 'forest_gate',
          returnSpawnId: 'dungeon_gate',
        ),
      ],
    ),
    MapDefinition(
      id: 'prototype_dungeon',
      asset: 'tiled/prototype_dungeon.json',
      kind: MapKind.dungeon,
      widthInTiles: 16,
      heightInTiles: 12,
      spawns: {'forest_gate': const MapSpawn(3, 5)},
      exits: [
        const MapExit(
          id: 'forest_gate',
          label: 'Forest',
          tileX: 1,
          tileY: 5,
          destinationMapId: 'prototype_wilderness',
          destinationSpawnId: 'dungeon_gate',
          returnSpawnId: 'forest_gate',
        ),
      ],
    ),
  ], fallback: TravelLocation('dev_dungeon', 'start'));
}
