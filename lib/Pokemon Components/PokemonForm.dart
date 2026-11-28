import 'package:pokemon_damage_calculator/Pokemon%20Components/BattleModifiers.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Moves.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Pokemon.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Types.dart';

// store ui input strings and dropdown selections for one pokemon so that data is saved when switching between attacking and defending views
class PokemonFormSnapshot {
  String? type1;
  String? type2;
  String? nature;
  int level;
  final Map<String, String> baseText;
  final Map<String, String> evText;
  final Map<String, String> ivText;

  static const List<String> statKeys = ['HP', 'Atk', 'DEF', 'SPA', 'SDEF', 'SPD'];

  PokemonFormSnapshot({
    this.type1,
    this.type2,
    this.nature,
    this.level = 100,
    Map<String, String>? baseText,
    Map<String, String>? evText,
    Map<String, String>? ivText,
  })  : baseText = baseText ?? {for (final k in statKeys) k: ''},
        evText = evText ?? {for (final k in statKeys) k: ''},
        ivText = ivText ?? {for (final k in statKeys) k: ''};

  // converts ui string name to team's types enum
  static Types parseType(String? typeName) {
    if (typeName == null || typeName.isEmpty) return Types.blank;
    return Types.values.firstWhere(
      (t) => t.name.toLowerCase() == typeName.toLowerCase(),
      orElse: () => Types.blank,
    );
  }

  // converts the UI string name to team's natures enum
  static Natures parseNature(String? natureName) {
    if (natureName == null || natureName.isEmpty) return Natures.Hardy;
    return Natures.values.firstWhere(
      (n) => n.name.toLowerCase() == natureName.toLowerCase(),
      orElse: () => Natures.Hardy,
    );
  }

  // converts UI weather string
  static Weather parseWeather(String? weatherName) {
    switch (weatherName) {
      case 'Sun':
        return Weather.sun;
      case 'Rain':
        return Weather.rain;
      case 'Sandstorm':
        return Weather.sand;
      case 'Snow':
        return Weather.snow;
      default:
        return Weather.none;
    }
  }

  // converts UI terrain string
  static Terrain parseTerrain(String? terrainName) {
    switch (terrainName) {
      case 'Electric':
        return Terrain.electric;
      case 'Grassy':
        return Terrain.grassy;
      case 'Misty':
        return Terrain.misty;
      case 'Psychic':
        return Terrain.psychic;
      default:
        return Terrain.none;
    }
  }

  // builds a Pokemon object from the current UI snapshot
  Pokemon toPokemon() {
    final List<int> baseStats = statKeys
        .map((k) => int.tryParse(baseText[k] ?? '') ?? 1)
        .toList();
    final List<int> evs = statKeys
        .map((k) => int.tryParse(evText[k] ?? '') ?? 0)
        .toList();
    final List<int> ivs = statKeys
        .map((k) => int.tryParse(ivText[k] ?? '') ?? 0)
        .toList();

    return Pokemon.filledConstructor(
      baseStats,
      evs,
      ivs,
      [parseType(type1), parseType(type2)],
      level,
    );
  }

  //calculates the 6 final stats using team's Pokemon.calculateFinalStats()
  List<int> calculateFinalStats() {
    return toPokemon().calculateFinalStats(parseNature(nature));
  }

  // builds a moves object from the UI move inputs
  static Moves buildMove({
    required String nameText,
    required String? moveTypeText,
    required String powerText,
    bool isSpecial = false,
  }) {
    final moveName = nameText.trim().isEmpty ? 'Tackle' : nameText.trim();
    final power = int.tryParse(powerText.trim()) ?? 0;
    return Moves(
      moveName,
      power: power,
      type: parseType(moveTypeText),
      isSpecial: isSpecial,
    );
  }
}