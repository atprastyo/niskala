import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/model/map_registry.dart';
import 'package:niskala/util/map_asset_validation.dart';

class _Bundle extends CachingAssetBundle {
  final Map<String, String> overrides;
  final Set<String> unavailable;
  _Bundle({this.overrides = const {}, this.unavailable = const {}});
  @override
  Future<ByteData> load(String key) async {
    if (unavailable.contains(key)) throw StateError('Missing asset');
    final text = overrides[key];
    return text == null
        ? rootBundle.load(key)
        : ByteData.sublistView(Uint8List.fromList(utf8.encode(text)));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final destination = MapRegistry.development.resolve('dev_dungeon', 'start');
  test('registered map and tileset image preflight successfully', () async {
    await validateMapAsset(destination);
  });
  test('missing tileset dependency is rejected before rendering', () async {
    await expectLater(
      validateMapAsset(
        destination,
        bundle: _Bundle(unavailable: {'assets/images/tiled/tileSet.json'}),
      ),
      throwsStateError,
    );
  });
  test('corrupt image is rejected before rendering', () async {
    await expectLater(
      validateMapAsset(
        destination,
        bundle: _Bundle(
          overrides: {'assets/images/tiled/tile_set.png': 'broken'},
        ),
      ),
      throwsFormatException,
    );
  });
  test('mismatched dimensions are rejected before rendering', () async {
    final data =
        jsonDecode(await rootBundle.loadString('assets/images/tiled/map.json'))
            as Map<String, dynamic>;
    data['width'] = 1;
    await expectLater(
      validateMapAsset(
        destination,
        bundle: _Bundle(
          overrides: {'assets/images/tiled/map.json': jsonEncode(data)},
        ),
      ),
      throwsFormatException,
    );
  });
}
