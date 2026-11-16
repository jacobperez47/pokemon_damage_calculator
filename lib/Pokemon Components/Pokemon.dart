import 'package:pokemon_damage_calculator/Pokemon%20Components/Types.dart';

class Pokemon {
  List<int> baseStats; // stat order [HP,ATK,DEF,SATk,SDEF,SPD]
  List<int> EVs = []; // stat order is the same for EVs and IVs
  List<int> IVs = [];
  List<Types> types = [];
  int level;

  // Creating default constructor
  Pokemon()
    : baseStats = [1, 1, 1, 1, 1, 1],
      EVs = [0, 0, 0, 0, 0, 0],
      IVs = [0, 0, 0, 0, 0, 0],
      types = [],
      level = 1;

  // Creating parameterized Constructor
  Pokemon.filledConstructor(
    List<int> stats,
    List<int> evs,
    List<int> ivs,
    int userLevel,
  ) : baseStats = [...stats],
      EVs = [...evs],
      IVs = [...ivs],
      //types = [...typesList],
      level = userLevel;

  List<int> calculateFinalStats() {
    //HP is calculated differently from every other stat
    List<int> finalStats = [1, 1, 1, 1, 1, 1];

    finalStats[0] =
        (((2 * baseStats[0] + IVs[0] + (EVs[0] ~/ 4)) * level) ~/ 100) +
        level +
        10;

    for (var i = 1; i < 6; i++) {
     finalStats[i] = (((2 * baseStats[i] + IVs[i] + (EVs[i] ~/ 4)) * level) ~/ 100) + 5;
    }

    return finalStats;
  }
}
