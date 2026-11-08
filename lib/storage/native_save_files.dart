import 'dart:io';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'save_repository.dart';

/// Create once and retain for the lifetime of the native application.
Future<SaveRepository> createNativeSaveRepository() async => SaveRepository(
      files: await NativeSaveFiles.applicationSupport(),
      keys: PlatformSaveKeyStore(
        storage: Platform.isMacOS
            ? const FlutterSecureStorage(
                mOptions: MacOsOptions(usesDataProtectionKeychain: false))
            : const FlutterSecureStorage(),
      ),
    );

/// Native mobile/desktop file adapter. Browser persistence is not wired yet.
class NativeSaveFiles implements SaveFiles {
  final Directory directory;
  NativeSaveFiles(this.directory);

  static Future<NativeSaveFiles> applicationSupport() async =>
      NativeSaveFiles(await getApplicationSupportDirectory());

  File _file(bool backup) => File(
      '${directory.path}${Platform.pathSeparator}campaign${backup ? '.backup' : ''}.enc');

  @override
  Future<String?> read({bool backup = false}) async {
    final file = _file(backup);
    return await file.exists()
        ? utf8.decode(await file.readAsBytes(), allowMalformed: true)
        : null;
  }

  @override
  Future<void> write(String encrypted, {bool backup = false}) async {
    await directory.create(recursive: true);
    final target = _file(backup);
    final temporary = File('${target.path}.tmp');
    await temporary.writeAsString(encrypted, flush: true);
    await temporary.rename(target.path);
  }
}
