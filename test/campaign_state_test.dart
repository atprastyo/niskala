import 'package:flutter_test/flutter_test.dart';
import 'package:niskala/model/campaign_state.dart';
import 'package:niskala/model/game_events.dart';
import 'package:niskala/model/game_session.dart';

void main() {
  test('discovered entrances persist as independent, read-only records', () {
    final state = CampaignState();
    expect(state.recordArrival('village', 'gate'), isTrue);
    expect(state.recordArrival('village', 'gate'), isFalse);
    final snapshot = state.toJson();
    state.recordArrival('village', 'home');
    final restored = CampaignState.fromJson(snapshot);
    expect(restored.discoveredLocations['village'], {'gate'});
    expect(
      () => restored.discoveredLocations['village']!.clear(),
      throwsUnsupportedError,
    );
    final legacy = state.toJson()..remove('locations');
    expect(CampaignState.fromJson(legacy).discoveredLocations, isEmpty);
  });
  test('campaign facts are idempotent and sessions remain independent', () {
    final session = GameSession();
    final events = <CampaignEvent>[
      const RegionDiscovered('hutan_embun'),
      const InteractionRecorded('talked_to_ratih'),
      const QuestCompleted('main_01_village'),
      const IngredientReceived('penjaga_lumut', 'daun_embun'),
    ];
    for (final event in events) {
      expect(session.applyCampaignEvent(event), isTrue);
      expect(session.applyCampaignEvent(event), isFalse);
    }
    expect(session.campaign.discoveredRegions, {'hutan_embun'});
    expect(session.campaign.facts, {'talked_to_ratih'});
    expect(session.campaign.completedQuests, {'main_01_village'});
    expect(GameSession().campaign.ingredients, isEmpty);
  });

  test(
    'boss and ingredient facts commit together outside normal inventory',
    () {
      final state = CampaignState();
      expect(state.receiveIngredient('boss_01', 'ingredient_01'), isTrue);
      expect(state.receiveIngredient('boss_01', 'ingredient_02'), isFalse);
      expect(state.receiveIngredient('boss_02', 'ingredient_01'), isFalse);
      expect(state.bossIngredients, {'boss_01': 'ingredient_01'});
      expect(state.removeItem('ingredient_01'), isFalse);
      expect(state.ingredients, {'ingredient_01'});
    },
  );

  test(
    'equipment references require ownership and clear when item is removed',
    () {
      final state = CampaignState();
      expect(() => state.equip('weapon', 'sword'), throwsStateError);
      state.addItem('sword');
      state.equip('weapon', 'sword');
      expect(state.removeItem('sword', quantity: 2), isFalse);
      expect(state.equipment['weapon'], 'sword');
      expect(state.removeItem('sword'), isTrue);
      expect(state.equipment, isEmpty);
      expect(() => state.inventory['sword'] = 1, throwsUnsupportedError);
      expect(() => state.addItem('potion', quantity: 0), throwsArgumentError);
    },
  );

  test('records round trip without sharing mutable maps', () {
    final state = CampaignState();
    state.addItem('sword');
    state.equip('weapon', 'sword');
    state.setHabitatCooldown('forest_pack_01', 120);
    state.setReturnLocation(
      'dungeon_01',
      TravelLocation('hutan_embun', 'portal_01'),
    );
    final snapshot = state.toJson();
    state.addItem('sword');
    final restored = CampaignState.fromJson(snapshot);
    expect(restored.inventory['sword'], 1);
    expect(restored.equipment['weapon'], 'sword');
    expect(restored.habitatCooldowns['forest_pack_01'], 120);
    expect(restored.returnLocations['dungeon_01']!.mapId, 'hutan_embun');
    expect(restored.returnLocations['dungeon_01']!.spawnId, 'portal_01');
  });

  test('invalid persisted records are rejected', () {
    final data = CampaignState().toJson();
    expect(
      () => CampaignState.fromJson({...data, 'version': 2}),
      throwsFormatException,
    );
    expect(
      () => CampaignState.fromJson({
        ...data,
        'inventory': {'potion': -1},
      }),
      throwsFormatException,
    );
    expect(
      () => CampaignState.fromJson({
        ...data,
        'cooldowns': {'pack': -1},
      }),
      throwsFormatException,
    );
    expect(
      () => CampaignState.fromJson({
        ...data,
        'equipment': {'weapon': 'missing'},
      }),
      throwsFormatException,
    );
    expect(() => TravelLocation('bad/map', 'start'), throwsFormatException);
  });
}
