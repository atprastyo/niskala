import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/game.dart';
import 'package:niskala/main.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/model/map_registry.dart';
import 'package:niskala/model/campaign_state.dart';
import 'package:niskala/player/knight.dart';
import 'package:niskala/util/sounds.dart';
import 'package:niskala/widgets/saved_game.dart';

void main() {
  testWidgets('portal travel loads all three maps and preserves the session', (
    tester,
  ) async {
    Sounds.enabled = false;
    Game.useJoystick = false;
    addTearDown(() => Game.useJoystick = true);
    final session = GameSession()
      ..currentMapId = 'prototype_village'
      ..currentSpawnId = 'start';
    session.progression.gainExp(20);
    session.campaign.recordFact('travel_test');
    await tester.pumpWidget(MaterialApp(home: SavedGame(session: session)));
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
      final current = tester.widget<Game>(find.byType(Game));
      current.onTravel!(route.$1);
      current.onTravel!(route.$1); // Repeated trigger while loading.
      await advance(60);
      expect(session.currentMapId, route.$2);
      expect(find.byType(Game), findsOneWidget);
      expect(player().session, same(session));
    }
    final arrived = player();
    tester.widget<Game>(find.byType(Game)).onTravel!('missing_exit');
    await advance(5);
    expect(player(), same(arrived));
    expect(session.currentMapId, 'prototype_village');
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
    session.currentSpawnId = 'start';
    await tester.pumpWidget(
      MaterialApp(
        home: SavedGame(session: session, registry: broken),
      ),
    );
    await advance(60);
    final beforeFailure = player();
    tester.widget<Game>(find.byType(Game)).onTravel!('bad_asset');
    await advance(10);
    expect(player(), same(beforeFailure));
    expect(session.currentMapId, 'prototype_village');
    expect(player().life.value, 150);
    expect(
      find.text('Could not travel. You are still in the previous area.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
