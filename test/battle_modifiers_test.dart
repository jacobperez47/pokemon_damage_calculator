import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/BattleModifiers.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Moves.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Pokemon.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Types.dart';

void main() {
  test('Type effectiveness & Levitate immunity work properly', () {
    final earthquake = Moves(
      'Earthquake',
      power: 100,
      type: Types.ground,
      isSpecial: false,
    );

    // ground vs fire/flying without levitate 
    expect(
      DamageModifierFramework.getTypeEffectiveness(
        earthquake.type,
        [Types.fire, Types.flying],
      ),
      0.0,
    );

    // ground vs electric with levitate 
    expect(
      DamageModifierFramework.getTypeEffectiveness(
        earthquake.type,
        [Types.electric],
        defenderAbility: Abilities.levitate,
      ),
      0.0,
    );

    // ground vs fire/steel 
    expect(
      DamageModifierFramework.getTypeEffectiveness(
        earthquake.type,
        [Types.fire, Types.steel],
      ),
      4.0,
    );
  });

  test('Item, Ability, and Field multipliers calculate accurately', () {
    final tackle = Moves(
      'Tackle',
      power: 40,
      type: Types.normal,
      isSpecial: false,
    );
    final iceDefender = Pokemon.filledConstructor(
      [90, 92, 75, 92, 85, 60],
      [0, 0, 0, 0, 0, 0],
      [31, 31, 31, 31, 31, 31],
      [Types.ice],
      100,
    );

    // technician (1.5x) * muscle band (1.1x)
    final powerMult = DamageModifierFramework.getBasePowerMultiplier(
      move: tackle,
      attackerItem: HeldItems.muscleBand,
      attackerAbility: Abilities.technician,
      field: FieldEffects(),
    );
    expect(powerMult, closeTo(1.65, 0.001));

    // snow boosts ice-type physical defense by 1.5x
    final defMult = DamageModifierFramework.getDefenseStatMultiplier(
      move: tackle,
      defender: iceDefender,
      defenderItem: HeldItems.none,
      field: FieldEffects(weather: Weather.snow),
    );
    expect(defMult, 1.5);
  });
}