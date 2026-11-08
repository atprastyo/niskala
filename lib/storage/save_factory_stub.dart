import 'save_repository.dart';

Future<SaveRepository> createNativeSaveRepository() async =>
    throw UnsupportedError('Local encrypted saves are unavailable on web.');
