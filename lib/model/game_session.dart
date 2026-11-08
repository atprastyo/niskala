import 'progression.dart';
import 'game_events.dart';
import 'campaign_state.dart';

/// State shared by successive map actors. Contains no mounted components.
class GameSession {
  final PlayerProgression progression;
  final CampaignState campaign;
  final Set<String> _rewardClaims;
  Set<String> get rewardClaims => Set.unmodifiable(_rewardClaims);
  late double health;
  late double stamina;
  String currentMapId = 'dev_dungeon';
  String currentSpawnId = 'start';
  String checkpointMapId = 'dev_dungeon';
  String checkpointSpawnId = 'start';

  GameSession({
    PlayerProgression? progression,
    CampaignState? campaign,
    Iterable<String> rewardClaims = const [],
  }) : progression = progression ?? PlayerProgression(),
       campaign = campaign ?? CampaignState(),
       _rewardClaims = Set.of(rewardClaims) {
    for (final id in _rewardClaims) {
      _validateRewardId(id);
    }
    health = this.progression.maxLife;
    stamina = this.progression.maxStamina;
  }

  static void _validateRewardId(String id) {
    if (!RegExp(r'^[a-z][a-z0-9_]{0,127}$').hasMatch(id)) {
      throw const FormatException('Invalid reward identity');
    }
  }

  bool applyCampaignEvent(CampaignEvent event) => switch (event) {
    RegionDiscovered(:final regionId) => campaign.discoverRegion(regionId),
    InteractionRecorded(:final interactionId) => campaign.recordFact(
      interactionId,
    ),
    QuestCompleted(:final questId) => campaign.completeQuest(questId),
    IngredientReceived(:final bossId, :final ingredientId) =>
      campaign.receiveIngredient(bossId, ingredientId),
  };

  ExperienceGrant applyEnemyDefeat(
    EnemyDefeated event, {
    void Function(int)? onLevelUp,
  }) => grantExperience(
    event.experience,
    rewardId: event.rewardId,
    onLevelUp: onLevelUp,
  );

  /// Owns reward claims and progression. Presentation callbacks cannot grant XP.
  ExperienceGrant grantExperience(
    int amount, {
    String? rewardId,
    void Function(int)? onLevelUp,
  }) {
    if (rewardId != null) _validateRewardId(rewardId);
    if (health <= 0 ||
        amount <= 0 ||
        (rewardId != null && _rewardClaims.contains(rewardId))) {
      return const ExperienceGrant(false, 0);
    }
    if (rewardId != null) _rewardClaims.add(rewardId);
    final levels = progression.gainExp(
      amount,
      onLevelUp: (level) {
        health = progression.maxLife;
        stamina = progression.maxStamina;
        onLevelUp?.call(level);
      },
    );
    return ExperienceGrant(true, levels);
  }
}
