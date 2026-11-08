import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Every Arka strip has complete, transparent, nonempty frames', () async {
    for (final action in ['idle', 'run', 'attack_1', 'attack_2']) {
      const frames = 8;
      const width = 384;
      const height = 320;
      for (final direction in ['right', 'left', 'up', 'down']) {
        final filename = action.replaceAll('_', '');
        final name =
            'assets/images/player/arka/$action/${filename}_$direction.png';
        final data = await rootBundle.load(name);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final image = (await codec.getNextFrame()).image;
        expect(image.width, frames * width, reason: name);
        expect(image.height, height, reason: name);
        final rgba = (await image.toByteData())!;
        for (var frame = 0; frame < frames; frame++) {
          var visibleSamples = 0;
          var outsideMovementCrop = 0;
          for (var y = 0; y < height; y += 2) {
            for (var x = 0; x < width; x += 2) {
              final alpha =
                  rgba.getUint8((y * image.width + frame * width + x) * 4 + 3);
              if (alpha > 128) {
                visibleSamples++;
                if ((action == 'idle' || action == 'run') &&
                    (x < 96 || x >= 288 || y < 64 || y >= 256)) {
                  outsideMovementCrop++;
                }
              }
            }
          }
          expect(visibleSamples, greaterThan(200),
              reason: '$name frame $frame is empty');
          expect(outsideMovementCrop, 0,
              reason: '$name frame $frame would clip during movement');
          // Transparent corner padding is required for every cell, not just the sheet.
          for (final y in [0, height - 1]) {
            for (final x in [0, width - 1]) {
              expect(
                  rgba.getUint8((y * image.width + frame * width + x) * 4 + 3),
                  0,
                  reason: '$name frame $frame has an opaque background');
            }
          }
        }
        image.dispose();
        codec.dispose();
      }
    }
  });
}
