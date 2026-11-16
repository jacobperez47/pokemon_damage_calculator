import 'package:pokemon_damage_calculator/Pokemon%20Components/Types.dart';

class Pokemon {
  List<int> baseStats = [1,1,1,1,1,1]; // stat order [HP,ATK,DEF,SATk,SDEF,SPD]
  List<int> EVs = [0,0,0,0,0,0]; // stat order is the same for EVs and IVs
  List<int> IVs = [0,0,0,0,0,0];
  List<Types> types = [];

  // Creating default constructor
  Pokemon() {
    print('Default Constructor');
  }

  // Creating parameterized Constructor
  Pokemon.filledContsructor(List<int> stats, List<int> Evs, List<int> Ivs) {
    baseStats = [...stats];
    EVs = [...Evs];
    IVs = [...Ivs];
  }
}
