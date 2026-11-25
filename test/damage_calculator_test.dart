import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/BattleModifiers.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/DamageCalculator.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Pokemon.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Types.dart';

import 'package:pokemon_damage_calculator/Pokemon%20Components/Moves.dart';

void main() {
  test('glaceon garchomp damage', () {
    Pokemon garchomp = Pokemon.filledConstructor(
        [108, 130, 95, 80, 85, 102],
        [0, 0, 0, 0, 0, 0],
        [31, 23, 21, 31, 31, 31],
        [Types.dragon, Types.ground],
        75,
        Natures.Hardy,
        HeldItems.none,
        Abilities.none
    );

    Pokemon glaceon = Pokemon.filledConstructor(
        [65, 60, 110, 130, 95, 65],
        [0, 0, 0, 0, 0, 0],
        [31, 23, 21, 31, 31, 31],
        [Types.ice, Types.blank],
        75,
        Natures.Hardy,
        HeldItems.muscleBand,
        Abilities.none
    );

    Moves icefang = Moves("ice fang", power: 65, type: Types.ice, isSpecial: false);



    var finalStatsGlace = glaceon.calculateFinalStats(Natures.Adamant);

    expect(finalStatsGlace, equals([205, 123, 185, 200, 170, 125]));

    List<int> damageRoll = Damagecalculator().calculateDamage(glaceon, garchomp, icefang, FieldEffects());

    expect(damageRoll, equals([168, 198]));
  });
}

