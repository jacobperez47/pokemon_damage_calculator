import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Pokemon.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Types.dart';

void main() {
  test('Stat formula is consistent with games', () {
    Pokemon garchomp = new Pokemon.filledConstructor(
      [108, 130, 95, 80, 85, 102],
      [74, 190, 91, 48, 84, 23],
      [24, 12, 30, 16, 23, 5],
      [Types.dragon, Types.ground],
      78,
    );

    var finalStats = garchomp.calculateFinalStats(Natures.Adamant);

    expect(finalStats, equals([289, 278, 193, 135, 171, 171]));
  });

  test('Type matchup calculation', () {
    // Fire (id 1) takes 0.5x from Fire (id 1) and 2.0x from Water (id 2)
    expect(Types.fire.matchups[Types.fire.id], equals(0.5));
    expect(Types.fire.matchups[Types.water.id], equals(2.0));
  });
}
