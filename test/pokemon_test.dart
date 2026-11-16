import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Pokemon.dart';

void main() {
  test('Stat formula is consistent with games', () {
    Pokemon garchomp = new Pokemon.filledConstructor(
      [108, 130, 95, 80, 85, 102],
      [74, 190, 91, 48, 84, 23],
      [24, 12, 30, 16, 23, 5],
      78,
    );

    var finalStats = garchomp.calculateFinalStats();
    
    expect(finalStats, equals([289,253,193,151,171,171]));
  });
}
