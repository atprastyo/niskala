/// Stable data records for campaign systems; contains no scene components.
class TravelLocation {
  final String mapId;
  final String spawnId;
  TravelLocation(this.mapId, this.spawnId) {
    _id(mapId);
    _id(spawnId);
  }
  Map<String, Object> toJson() => {'map': mapId, 'spawn': spawnId};
}

void _id(String value) {
  if (!RegExp(r'^[a-z][a-z0-9_]{0,127}$').hasMatch(value)) {
    throw const FormatException('Invalid campaign identifier');
  }
}

class CampaignState {
  final Map<String, int> _inventory = {};
  final Map<String, String> _equipment = {};
  final Set<String> _facts = {};
  final Set<String> _discoveredRegions = {};
  final Map<String, Set<String>> _discoveredLocations = {};
  final Set<String> _completedQuests = {};
  final Map<String, String> _bossIngredients = {};
  final Map<String, int> _habitatCooldowns = {};
  final Map<String, TravelLocation> _returnLocations = {};

  Map<String, int> get inventory => Map.unmodifiable(_inventory);
  Map<String, String> get equipment => Map.unmodifiable(_equipment);
  Set<String> get facts => Set.unmodifiable(_facts);
  Set<String> get discoveredRegions => Set.unmodifiable(_discoveredRegions);
  Map<String, Set<String>> get discoveredLocations => Map.unmodifiable({
    for (final entry in _discoveredLocations.entries)
      entry.key: Set<String>.unmodifiable(entry.value),
  });
  Set<String> get completedQuests => Set.unmodifiable(_completedQuests);
  Map<String, String> get bossIngredients => Map.unmodifiable(_bossIngredients);
  Set<String> get ingredients => Set.unmodifiable(_bossIngredients.values);
  Map<String, int> get habitatCooldowns => Map.unmodifiable(_habitatCooldowns);
  Map<String, TravelLocation> get returnLocations =>
      Map.unmodifiable(_returnLocations);

  void addItem(String itemId, {int quantity = 1}) {
    _id(itemId);
    if (quantity <= 0) throw ArgumentError.value(quantity, 'quantity');
    _inventory[itemId] = (_inventory[itemId] ?? 0) + quantity;
  }

  bool removeItem(String itemId, {int quantity = 1}) {
    _id(itemId);
    if (quantity <= 0) throw ArgumentError.value(quantity, 'quantity');
    final available = _inventory[itemId] ?? 0;
    if (available < quantity) return false;
    final remaining = available - quantity;
    if (remaining == 0) {
      _inventory.remove(itemId);
      _equipment.removeWhere((_, item) => item == itemId);
    } else {
      _inventory[itemId] = remaining;
    }
    return true;
  }

  void equip(String slotId, String itemId) {
    _id(slotId);
    _id(itemId);
    if (!_inventory.containsKey(itemId)) throw StateError('Item is not owned');
    _equipment[slotId] = itemId;
  }

  bool recordFact(String factId) {
    _id(factId);
    return _facts.add(factId);
  }

  bool discoverRegion(String regionId) {
    _id(regionId);
    return _discoveredRegions.add(regionId);
  }

  bool recordArrival(String mapId, String spawnId) {
    _id(mapId);
    _id(spawnId);
    return (_discoveredLocations[mapId] ??= <String>{}).add(spawnId);
  }

  bool completeQuest(String questId) {
    _id(questId);
    return _completedQuests.add(questId);
  }

  /// Commits both facts together. Ingredients live outside consumable inventory.
  bool receiveIngredient(String bossId, String ingredientId) {
    _id(bossId);
    _id(ingredientId);
    if (_bossIngredients.containsKey(bossId) ||
        _bossIngredients.containsValue(ingredientId)) {
      return false;
    }
    _bossIngredients[bossId] = ingredientId;
    return true;
  }

  void setHabitatCooldown(String habitatId, int remainingSeconds) {
    _id(habitatId);
    if (remainingSeconds < 0) throw ArgumentError.value(remainingSeconds);
    _habitatCooldowns[habitatId] = remainingSeconds;
  }

  void setReturnLocation(String entranceId, TravelLocation location) {
    _id(entranceId);
    _returnLocations[entranceId] = location;
  }

  Map<String, Object> toJson() => {
    'version': 1,
    'inventory': Map<String, int>.of(_inventory),
    'equipment': Map<String, String>.of(_equipment),
    'facts': _facts.toList()..sort(),
    'regions': _discoveredRegions.toList()..sort(),
    'locations': {
      for (final entry in _discoveredLocations.entries)
        entry.key: entry.value.toList()..sort(),
    },
    'quests': _completedQuests.toList()..sort(),
    'bossIngredients': Map<String, String>.of(_bossIngredients),
    'cooldowns': Map<String, int>.of(_habitatCooldowns),
    'returns': {
      for (final entry in _returnLocations.entries)
        entry.key: entry.value.toJson(),
    },
  };

  static CampaignState fromJson(Map<String, dynamic> data) {
    if (data['version'] != 1) {
      throw const FormatException('Unsupported campaign version');
    }
    final state = CampaignState();
    final inventory = data['inventory'] as Map<String, dynamic>;
    for (final entry in inventory.entries) {
      _id(entry.key);
      final count = entry.value as int;
      if (count <= 0) throw const FormatException('Invalid inventory quantity');
      state.addItem(entry.key, quantity: count);
    }
    for (final entry in (data['equipment'] as Map<String, dynamic>).entries) {
      final item = entry.value as String;
      if (!state._inventory.containsKey(item)) {
        throw const FormatException('Equipment is not owned');
      }
      state.equip(entry.key, item);
    }
    for (final fact in data['facts'] as List<dynamic>) {
      state.recordFact(fact as String);
    }
    for (final region in data['regions'] as List<dynamic>) {
      state.discoverRegion(region as String);
    }
    for (final entry
        in (data['locations'] as Map<String, dynamic>? ?? {}).entries) {
      _id(entry.key);
      for (final spawn in entry.value as List<dynamic>) {
        state.recordArrival(entry.key, spawn as String);
      }
    }
    for (final quest in data['quests'] as List<dynamic>) {
      state.completeQuest(quest as String);
    }
    for (final entry
        in (data['bossIngredients'] as Map<String, dynamic>).entries) {
      if (!state.receiveIngredient(entry.key, entry.value as String)) {
        throw const FormatException('Duplicate ingredient');
      }
    }
    for (final entry in (data['cooldowns'] as Map<String, dynamic>).entries) {
      final seconds = entry.value as int;
      if (seconds < 0) throw const FormatException('Invalid cooldown');
      state.setHabitatCooldown(entry.key, seconds);
    }
    for (final entry in (data['returns'] as Map<String, dynamic>).entries) {
      final location = entry.value as Map<String, dynamic>;
      state.setReturnLocation(
        entry.key,
        TravelLocation(location['map'] as String, location['spawn'] as String),
      );
    }
    return state;
  }
}
