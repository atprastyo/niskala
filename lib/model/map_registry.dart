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

class MapDefinition {
  final String id;
  final String asset;
  final MapKind kind;
  final int widthInTiles;
  final int heightInTiles;
  final Map<String, MapSpawn> spawns;

  MapDefinition({
    required this.id,
    required this.asset,
    required this.kind,
    required this.widthInTiles,
    required this.heightInTiles,
    required Map<String, MapSpawn> spawns,
  }) : spawns = Map.unmodifiable(spawns) {
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
  ], fallback: TravelLocation('dev_dungeon', 'start'));
}
