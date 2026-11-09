import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/game.dart';
import 'package:niskala/menu.dart';
import 'package:niskala/model/game_session.dart';
import 'package:niskala/model/map_registry.dart';
import 'package:niskala/model/map_travel.dart';
import 'package:niskala/storage/native_save_files.dart';
import 'package:niskala/storage/save_repository.dart';
import 'package:niskala/util/localization/my_localizations.dart';
import 'package:niskala/util/map_asset_validation.dart';
import 'package:niskala/util/sounds.dart';
import 'package:niskala/widgets/saved_game.dart';

class _Keys implements SaveKeyStore {
  String? value;
  @override
  Future<String?> read() async => value;
  @override
  Future<void> write(String key) async => value = key;
}

void main() {
  testWidgets(
    'fresh app menu continues encrypted progress across reconstruction',
    (tester) async {
      Sounds.enabled = false;
      await MyLocalizations(const Locale('en')).load();
      final directory = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('niskala-continue-'),
      ))!;
      addTearDown(() => directory.delete(recursive: true));
      final keys = _Keys(); // Substitute for the persistent OS key store only.
      var opens = 0;
      SaveRepository freshRepository() =>
          SaveRepository(files: NativeSaveFiles(directory), keys: keys);
      final original = GameSession()
        ..currentMapId = 'prototype_village'
        ..currentSpawnId = 'start'
        ..health = 120;
      original.progression.gainExp(20);
      original.campaign.addItem('sword');
      original.campaign.equip('weapon', 'sword');
      original.campaign.recordFact('permission_received');
      original.campaign.completeQuest('main_01_village');
      original.campaign.receiveIngredient('boss_01', 'daun_embun');
      await tester.runAsync(() async {
        final travel = MapTravel(original, MapRegistry.development);
        travel.setCheckpoint();
        await travel.travel('forest_gate', validateMapAsset);
        await travel.travel('dungeon_gate', validateMapAsset);
        await freshRepository().save(original);
      });

      Future<void> advance(int count) async {
        await tester.runAsync(() async {
          for (var i = 0; i < count; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 30));
            await tester.pump(const Duration(milliseconds: 100));
          }
        });
      }

      for (final expectedMap in ['prototype_dungeon', 'prototype_wilderness']) {
        final bytesBefore = await tester.runAsync(
          () => NativeSaveFiles(directory).read(),
        );
        await tester.pumpWidget(
          MaterialApp(
            home: Menu(
              saveRepositoryFactory: () async {
                opens++;
                return freshRepository();
              },
            ),
          ),
        );
        await advance(100);
        await tester.ensureVisible(find.text('Continue'));
        await tester.tap(find.text('Continue'));
        await advance(70);
        final restored = tester
            .widget<SavedGame>(find.byType(SavedGame))
            .session;
        expect(restored, isNot(same(original)));
        expect(restored.currentMapId, expectedMap);
        expect(restored.progression.currentExp, 20);
        expect(restored.health, 120);
        expect(restored.checkpointMapId, 'prototype_village');
        expect(restored.checkpointSpawnId, 'start');
        expect(
          restored.campaign.returnLocations['prototype_dungeon']!.mapId,
          'prototype_wilderness',
        );
        expect(
          restored.campaign.returnLocations['prototype_dungeon']!.spawnId,
          'dungeon_gate',
        );
        expect(restored.campaign.inventory['sword'], 1);
        expect(restored.campaign.equipment['weapon'], 'sword');
        expect(restored.campaign.facts, {'permission_received'});
        expect(restored.campaign.completedQuests, {'main_01_village'});
        expect(restored.campaign.ingredients, {'daun_embun'});
        expect(
          restored.campaign.discoveredLocations.keys,
          containsAll([
            'prototype_village',
            'prototype_wilderness',
            'prototype_dungeon',
          ]),
        );
        expect(restored.campaign.discoveredLocations['prototype_dungeon'], {
          'forest_gate',
        });
        expect(
          await tester.runAsync(() => NativeSaveFiles(directory).read()),
          bytesBefore,
        );
        if (expectedMap == 'prototype_dungeon') {
          tester.widget<Game>(find.byType(Game)).onTravel!('forest_gate');
          await advance(60);
          expect(
            (await tester.runAsync(
              () => freshRepository().load(),
            ))!.session.currentMapId,
            'prototype_wilderness',
          );
        }
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
      expect(opens, 2);
    },
  );
}
