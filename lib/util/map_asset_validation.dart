import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:niskala/model/map_registry.dart';

/// Preflight the map and external tileset/image dependencies before scene swap.
Future<void> validateMapAsset(
  MapDestination destination, {
  AssetBundle? bundle,
}) async {
  final assets = bundle ?? rootBundle;
  final path = 'assets/images/${destination.map.asset}';
  final data =
      jsonDecode(await assets.loadString(path)) as Map<String, dynamic>;
  if (data['width'] != destination.map.widthInTiles ||
      data['height'] != destination.map.heightInTiles ||
      data['layers'] is! List) {
    throw const FormatException('Map does not match registry');
  }
  String relative(String base, String reference) {
    final uri = Uri.parse(base).resolve(reference);
    if (uri.hasScheme ||
        !uri.path.startsWith('assets/images/tiled/') ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const FormatException('Invalid map dependency');
    }
    return uri.path;
  }

  for (final value in data['tilesets'] as List<dynamic>) {
    var tileset = value as Map<String, dynamic>;
    var tilesetPath = path;
    if (tileset['source'] != null) {
      tilesetPath = relative(path, tileset['source'] as String);
      tileset =
          jsonDecode(await assets.loadString(tilesetPath))
              as Map<String, dynamic>;
    }
    final image = relative(tilesetPath, tileset['image'] as String);
    final bytes = await assets.load(image);
    if (bytes.lengthInBytes == 0) {
      throw const FormatException('Empty tileset image');
    }
    try {
      final codec = await ui.instantiateImageCodec(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
      );
      try {
        final frame = await codec.getNextFrame();
        frame.image.dispose();
      } finally {
        codec.dispose();
      }
    } catch (_) {
      throw const FormatException('Invalid tileset image');
    }
  }
}
