import 'dart:core';

import 'package:pokemon_damage_calculator/Pokemon%20Components/BattleModifiers.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Moves.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Pokemon.dart';

class Damagecalculator {
  List<int> calculateDamage(
    Pokemon attacker,
    Pokemon defender,
    Moves moveUsed,
    FieldEffects effects,
  ) {
    int levelCalculation = ((2 * attacker.level) ~/ 5) + 2;

    // Index 1 = ATK, Index 2 = DEF, Index 3 = SATK, Index 4 = SDEF
    int attackUsed = moveUsed.isSpecial ? 3 : 1;
    int defenseUsed = moveUsed.isSpecial ? 4 : 2;

    List<int> attackerStats = List.from(attacker.calculateFinalStats(attacker.nature));
    List<int> defenderStats = List.from(defender.calculateFinalStats(defender.nature));

    int attackCalculation = (attackerStats[attackUsed] *
            DamageModifierFramework.getAttackStatMultiplier(
              move: moveUsed,
              attackerItem: attacker.item,
              attackerAbility: attacker.ability,
              defenderAbility: defender.ability,
            ))
        .toInt();

    int defenseCalculation = (defenderStats[defenseUsed] *
            DamageModifierFramework.getDefenseStatMultiplier(
              move: moveUsed,
              defender: defender,
              defenderItem: defender.item,
              field: effects,
            ))
        .toInt();

    int baseDamage =
        (((levelCalculation * moveUsed.power * attackCalculation) ~/
                    defenseCalculation) ~/
                50) +
            2;

    double basePowerMult = DamageModifierFramework.getBasePowerMultiplier(
      move: moveUsed,
      attackerItem: attacker.item,
      attackerAbility: attacker.ability,
      field: effects,
      attacker: attacker,
    );

    double typeEffectiveness = DamageModifierFramework.getTypeEffectiveness(
      moveUsed.type,
      defender.types,
      defenderAbility: defender.ability,
    );

    double finalDamageMult = DamageModifierFramework.getFinalDamageMultiplier(
      move: moveUsed,
      attackerItem: attacker.item,
      attackerAbility: attacker.ability,
      defenderAbility: defender.ability,
      field: effects,
      typeEffectiveness: typeEffectiveness,
    );

    int damageAfterMult =
        (baseDamage * basePowerMult * typeEffectiveness * finalDamageMult)
            .toInt();

    int minDamage = (damageAfterMult * 0.85).toInt();

    return [minDamage, damageAfterMult];
  }
}

