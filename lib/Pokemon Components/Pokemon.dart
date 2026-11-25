import 'package:pokemon_damage_calculator/Pokemon%20Components/BattleModifiers.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Types.dart';

enum Natures {
  // +Attack Natures
  Hardy('Hardy', '+Atk -Atk', [0, 0, 0, 0, 0]),
  Lonely('Lonely', '+Atk -Def', [1, -1, 0, 0, 0]),
  Adamant('Adamant', '+Atk -SpAtk', [1, 0, -1, 0, 0]),
  Naughty('Naughty', '+Atk -SpDef', [1, 0, 0, -1, 0]),
  Brave('Brave', '+Atk -Spd', [1, 0, 0, 0, -1]),

  // +Defense Natures
  Bold('Bold', '+Def -Atk', [-1, 1, 0, 0, 0]),
  Docile('Docile', '+Def -Def', [0, 0, 0, 0, 0]),
  Impish('Impish', '+Def -SpAtk', [0, 1, -1, 0, 0]),
  Lax('Lax', '+Def -SpDef', [0, 1, 0, -1, 0]),
  Relaxed('Relaxed', '+Def -Spd', [0, 1, 0, 0, -1]),

  // +Special Attack Natures
  Modest('Modest', '+SpAtk -Atk', [-1, 0, 1, 0, 0]),
  Mild('Mild', '+SpAtk -Def', [0, -1, 1, 0, 0]),
  Bashful('Bashful', '+SpAtk -SpAtk', [0, 0, 0, 0, 0]),
  Rash('Rash', '+SpAtk -SpDef', [0, 0, 1, -1, 0]),
  Quiet('Quiet', '+SpAtk -Spd', [0, 0, 1, 0, -1]),

  // +Special Defense Natures
  Calm('Calm', '+SpDef -Atk', [-1, 0, 0, 1, 0]),
  Gentle('Gentle', '+SpDef -Def', [0, -1, 0, 1, 0]),
  Careful('Careful', '+SpDef -SpAtk', [0, 0, -1, 1, 0]),
  Quirky('Quirky', '+SpDef -SpDef', [0, 0, 0, 0, 0]),
  Sassy('Sassy', '+SpDef -Spd', [0, 0, 0, 1, -1]),

  // +Speed Natures
  Timid('Timid', '+Spd -Atk', [-1, 0, 0, 0, 1]),
  Hasty('Hasty', '+Spd -Def', [0, -1, 0, 0, 1]),
  Jolly('Jolly', '+Spd -SpAtk', [0, 0, -1, 0, 1]),
  Naive('Naive', '+Spd -SpDef', [0, 0, 0, -1, 1]),
  Serious('Serious', '+Spd -Spd', [0, 0, 0, 0, 0]);

  final String name;
  final String description;
  final List<int> statModif;

  const Natures(this.name, this.description, this.statModif);
}

class Pokemon {
  List<int> baseStats; // stat order [HP,ATK,DEF,SATk,SDEF,SPD]
  List<int> EVs = []; // stat order is the same for EVs and IVs
  List<int> IVs = [];
  List<Types> types = [];
  int level;
  Natures nature;
  HeldItems item;
  Abilities ability;

  // Creating default constructor
  Pokemon()
      : baseStats = [1, 1, 1, 1, 1, 1],
        EVs = [0, 0, 0, 0, 0, 0],
        IVs = [0, 0, 0, 0, 0, 0],
        types = [],
        level = 1,
        nature = Natures.Hardy,
        item = HeldItems.none,
        ability = Abilities.none;


  // Creating parameterized Constructor
  Pokemon.filledConstructor(List<int> stats,
      List<int> evs,
      List<int> ivs,
      List<Types> typelist,
      int userLevel,
      Natures natureInput,
      HeldItems itemHeld,
      Abilities currentAbility)
      : baseStats = [...stats],
        EVs = [...evs],
        IVs = [...ivs],
        types = [...typelist],
        level = userLevel,
        nature = natureInput,
        item = itemHeld,
        ability = currentAbility;

  List<int> calculateFinalStats(Natures nature) {
    //HP is calculated differently from every other stat
    List<int> finalStats = [1, 1, 1, 1, 1, 1];

    finalStats[0] =
        (((2 * baseStats[0] + IVs[0] + (EVs[0] ~/ 4)) * level) ~/ 100) +
            level +
            10;

    for (var i = 1; i < 6; i++) {
      finalStats[i] =
          (((2 * baseStats[i] + IVs[i] + (EVs[i] ~/ 4)) * level) ~/ 100) + 5;
      if (nature.statModif[i - 1] == 1) {
        finalStats[i] = (finalStats[i] * 1.1).toInt();
      } else if (nature.statModif[i - 1] == -1) {
        finalStats[i] = (finalStats[i] * .9).toInt();
      }
    }

    return finalStats;
  }
}
