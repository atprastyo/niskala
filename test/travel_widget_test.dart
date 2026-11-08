import 'dart:async';
import 'package:niskala/storage/save_repository.dart';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/game.dart';
import 'package:niskala/main.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/model/map_registry.dart';
import 'package:niskala/util/localization/my_localizations.dart';
import 'package:niskala/util/localization/strings_location.dart';
import 'package:niskala/model/campaign_state.dart';
import 'package:niskala/player/knight.dart';
import 'package:niskala/util/sounds.dart';
import 'package:niskala/widgets/saved_game.dart';

void main() {
  testWidgets('portal travel loads all three maps and preserves the session', (
    tester,
  ) async {
    Sounds.enabled = false;
    await MyLocalizations(const Locale('en')).load();
    Game.useJoystick = false;
    addTearDown(() => Game.useJoystick = true);
    final session = GameSession()
      ..currentMapId = 'prototype_village'
      ..currentSpawnId = 'start';
    session.progression.gainExp(20);
    session.campaign.recordFact('travel_test');
    final files = _AutoSaveFiles();
    final repository = SaveRepository(files: files, keys: _AutoSaveKeys());
    await tester.pumpWidget(
      MaterialApp(
        home: SavedGame(session: session, repository: repository),
      ),
    );
    Future<void> advance(int count) async {
      await tester.runAsync(() async {
        for (var i = 0; i < count; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          await tester.pump(const Duration(milliseconds: 30));
        }
      });
    }

    Knight player() {
      final finder = find.byWidgetPredicate(
        (w) => w.runtimeType.toString().startsWith('ListenerGameWidget'),
      );
      final engine = (tester.widget(finder) as dynamic).game as BonfireGame;
      return engine.player! as Knight;
    }

    await advance(70);
    final initial = player();
    initial.life.remove(50);
    // Move the foot hitbox onto the village's forest portal.
    initial.position = Vector2(13 * tileSize - 8, 5 * tileSize - 24);
    await advance(70);
    expect(session.currentMapId, 'prototype_wilderness');
    expect(player(), isNot(same(initial)));
    expect(player().session, same(session));
    expect(player().life.value, 150);
    expect(
      (await tester.runAsync(() => repository.load()))!.session.currentMapId,
      'prototype_wilderness',
    );
    await tester.tap(find.text('Save at entrance'));
    await advance(10);
    expect(
      (await tester.runAsync(() => repository.load()))!.session.checkpointMapId,
      'prototype_wilderness',
    );
    expect(session.progression.currentExp, 20);
    // Remaining idle at arrival must not trigger the reverse portal.
    await advance(40);
    expect(session.currentMapId, 'prototype_wilderness');
    final before = player().position.clone();
    await tester.sendKeyDownEvent(LogicalKeyboardKey.arrowRight);
    await advance(5);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.arrowRight);
    expect(player().position.x, greaterThan(before.x));

    for (final route in [
      ('dungeon_gate', 'prototype_dungeon'),
      ('forest_gate', 'prototype_wilderness'),
      ('village_gate', 'prototype_village'),
    ]) {
      if (route.$2 == 'prototype_dungeon') files.failWrites = true;
      if (route.$2 == 'prototype_wilderness') files.gate = Completer<void>();
      final current = tester.widget<Game>(find.byType(Game));
      final writesBeforeLoad = files.primaryWrites;
      current.onTravel!(route.$1);
      current.onTravel!(route.$1); // Repeated trigger while loading.
      tester
          .widget<ElevatedButton>(
            find.widgetWithText(ElevatedButton, 'Save at entrance'),
          )
          .onPressed
          ?.call();
      expect(files.primaryWrites, writesBeforeLoad);
      await advance(60);
      expect(session.currentMapId, route.$2);
      expect(find.byType(Game), findsOneWidget);
      expect(player().session, same(session));
      if (route.$2 == 'prototype_dungeon') {
        expect(find.text('Retry save'), findsOneWidget);
        expect(
          (await tester.runAsync(
            () => repository.load(),
          ))!.session.currentMapId,
          'prototype_wilderness',
        );
        files.failWrites = false;
        await tester.tap(find.text('Retry save'));
        await advance(10);
        expect(find.text('Retry save'), findsNothing);
        expect(
          (await tester.runAsync(
            () => repository.load(),
          ))!.session.checkpointMapId,
          'prototype_wilderness',
        );
      }
      if (route.$2 == 'prototype_wilderness') {
        expect(find.text('Saving…'), findsOneWidget);
        final menu = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Menu'),
        );
        expect(menu.onPressed, isNull);
        tester.widget<Game>(find.byType(Game)).onTravel!('village_gate');
        expect(session.currentMapId, 'prototype_wilderness');
        files.gate!.complete();
        files.gate = null;
        await advance(10);
      }
      expect(
        (await tester.runAsync(() => repository.load()))!.session.currentMapId,
        route.$2,
      );
    }
    final writesBeforeInvalidExit = files.primaryWrites;
    final arrived = player();
    tester.widget<Game>(find.byType(Game)).onTravel!('missing_exit');
    await advance(5);
    expect(player(), same(arrived));
    expect(files.primaryWrites, writesBeforeInvalidExit);
    expect(session.currentMapId, 'prototype_village');
    expect(session.campaign.facts, {'travel_test'});
    player().life.remove(player().life.max);
    await advance(15);
    await tester.tap(
      find.widgetWithText(ElevatedButton, getString('play_again_cap')),
    );
    await advance(60);
    expect(session.currentMapId, 'prototype_wilderness');
    expect(session.currentSpawnId, 'village_gate');
    final recoveredSave = (await tester.runAsync(
      () => repository.load(),
    ))!.session;
    expect(recoveredSave.currentMapId, 'prototype_wilderness');
    expect(recoveredSave.health, recoveredSave.progression.maxLife);
    expect(player().session, same(session));
    expect(player().life.value, player().progression.maxLife);
    expect(session.progression.currentExp, 20);
    expect(session.campaign.facts, {'travel_test'});
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    final village = MapRegistry.development
        .resolve('prototype_village', 'start')
        .map;
    final broken = MapRegistry([
      MapDefinition(
        id: village.id,
        asset: village.asset,
        kind: village.kind,
        widthInTiles: 16,
        heightInTiles: 12,
        spawns: village.spawns,
        exits: [
          const MapExit(
            id: 'bad_asset',
            label: 'Unavailable',
            tileX: 13,
            tileY: 5,
            destinationMapId: 'missing_map',
            destinationSpawnId: 'start',
            returnSpawnId: 'start',
          ),
        ],
      ),
      MapDefinition(
        id: 'missing_map',
        asset: 'tiled/not_present.json',
        kind: MapKind.dungeon,
        widthInTiles: 16,
        heightInTiles: 12,
        spawns: {'start': const MapSpawn(3, 5)},
      ),
    ], fallback: TravelLocation('prototype_village', 'start'));
    session.currentMapId = 'prototype_village';
    session.currentSpawnId = 'start';
    session.health = 150;
    await tester.pumpWidget(
      MaterialApp(
        home: SavedGame(
          session: session,
          registry: broken,
          repository: repository,
        ),
      ),
    );
    await advance(60);
    final beforeFailure = player();
    final writesBeforeFailedLoad = files.primaryWrites;
    tester.widget<Game>(find.byType(Game)).onTravel!('bad_asset');
    await advance(10);
    expect(player(), same(beforeFailure));
    expect(files.primaryWrites, writesBeforeFailedLoad);
    expect(session.currentMapId, 'prototype_village');
    expect(player().life.value, 150);
    expect(
      find.text('Could not travel. You are still in the previous area.'),
      findsOneWidget,
    );
    session.checkpointMapId = 'missing_map';
    session.checkpointSpawnId = 'start';
    player().life.remove(player().life.max);
    await advance(15);
    await tester.tap(
      find.widgetWithText(ElevatedButton, getString('play_again_cap')),
    );
    await advance(15);
    expect(player(), same(beforeFailure));
    expect(files.primaryWrites, writesBeforeFailedLoad);
    expect(session.health, 0);
    expect(find.text('Retry recovery'), findsOneWidget);
    session.checkpointMapId = 'prototype_village';
    await tester.tap(find.text('Retry recovery'));
    await advance(60);
    expect(player(), isNot(same(beforeFailure)));
    expect(player().session, same(session));
    expect(player().life.value, player().progression.maxLife);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}

class _AutoSaveKeys implements SaveKeyStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async => value = key;
}

class _AutoSaveFiles implements SaveFiles {
  String? primary, previous;
  bool failWrites = false;
  int primaryWrites = 0;
  Completer<void>? gate;
  @override
  Future<String?> read({bool backup = false}) async =>
      backup ? previous : primary;
  @override
  Future<void> write(String encrypted, {bool backup = false}) async {
    if (failWrites) throw StateError('Storage unavailable');
    await gate?.future;
    if (backup) {
      previous = encrypted;
    } else {
      primary = encrypted;
      primaryWrites++;
    }
  }
}
