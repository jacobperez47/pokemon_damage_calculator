import 'package:pokemon_damage_calculator/Pokemon%20Components/Moves.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Pokemon.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Types.dart';

// weather conditions
enum Weather { none, sun, rain, sand, snow }

// terrain conditions
enum Terrain { none, electric, grassy, misty, psychic }

// held items that modify damage or stats in battle
enum HeldItems {
  none('None', 'No item effect'),
  choiceBand('Choice Band', 'Boosts Attack by 1.5x'),
  choiceSpecs('Choice Specs', 'Boosts Sp. Atk by 1.5x'),
  lifeOrb('Life Orb', 'Boosts damage by 1.3x'),
  expertBelt('Expert Belt', 'Boosts super-effective moves by 1.2x'),
  muscleBand('Muscle Band', 'Boosts Physical moves by 1.1x'),
  wiseGlasses('Wise Glasses', 'Boosts Special moves by 1.1x'),
  assaultVest('Assault Vest', 'Boosts Sp. Def by 1.5x'),
  eviolite('Eviolite', 'Boosts Def and Sp. Def by 1.5x');

  final String name;
  final String description;
  const HeldItems(this.name, this.description);
}

// abilities that modify damage, stats, or type immunities
enum Abilities {
  none('None', 'No ability effect'),
  hugePower('Huge Power', 'Doubles Attack stat'),
  purePower('Pure Power', 'Doubles Attack stat'),
  technician('Technician', 'Boosts moves with <= 60 base power by 1.5x'),
  toughClaws('Tough Claws', 'Boosts physical contact moves by 1.3x'),
  adaptability('Adaptability', 'Boosts STAB from 1.5x to 2.0x'),
  guts('Guts', 'Boosts Attack by 1.5x when burned and ignores burn drop'),
  levitate('Levitate', 'Grants immunity to Ground-type moves'),
  thickFat('Thick Fat', 'Halves damage taken from Fire and Ice moves'),
  multiscale('Multiscale', 'Halves damage taken at full HP'),
  filter('Filter', 'Reduces super-effective damage by 0.75x');

  final String name;
  final String description;
  const Abilities(this.name, this.description);
}

// holds battle field conditions & temporary effects
class FieldEffects {
  Weather weather;
  Terrain terrain;
  bool isDoubles;
  bool isCriticalHit;
  bool hasReflect;
  bool hasLightScreen;
  bool hasAuroraVeil;

  FieldEffects({
    this.weather = Weather.none,
    this.terrain = Terrain.none,
    this.isDoubles = false,
    this.isCriticalHit = false,
    this.hasReflect = false,
    this.hasLightScreen = false,
    this.hasAuroraVeil = false,
  });
}

// framework class that computes all item, ability, and field multipliers
class DamageModifierFramework {
  static double getTypeEffectiveness(
    Types moveType,
    List<Types> defenderTypes, {
    Abilities defenderAbility = Abilities.none,
  }) {
    // ability-based type immunities
    if (defenderAbility == Abilities.levitate && moveType == Types.ground) {
      return 0.0;
    }

    double multiplier = 1.0;
    for (final defType in defenderTypes) {
      if (defType != Types.blank) {
        multiplier *= defType.matchups[moveType.id];
      }
    }
    return multiplier;
  }

  // base power modifiers
  static double getBasePowerMultiplier({
    required Moves move,
    required HeldItems attackerItem,
    required Abilities attackerAbility,
    required FieldEffects field,
  }) {
    double mult = 1.0;

    // item boosts
    if (attackerItem == HeldItems.muscleBand && !move.isSpecial) {
      mult *= 1.1;
    } else if (attackerItem == HeldItems.wiseGlasses && move.isSpecial) {
      mult *= 1.1;
    }

    // ability boosts
    if (attackerAbility == Abilities.technician && move.power <= 60) {
      mult *= 1.5;
    } else if (attackerAbility == Abilities.toughClaws && !move.isSpecial) {
      mult *= 1.3;
    }

    // terrain boosts
    if (field.terrain == Terrain.electric && move.type == Types.electric) {
      mult *= 1.3;
    } else if (field.terrain == Terrain.grassy && move.type == Types.grass) {
      mult *= 1.3;
    } else if (field.terrain == Terrain.psychic && move.type == Types.psychic) {
      mult *= 1.3;
    } else if (field.terrain == Terrain.misty && move.type == Types.dragon) {
      mult *= 0.5;
    }

    return mult;
  }

  // attack
  static double getAttackStatMultiplier({
    required Moves move,
    required HeldItems attackerItem,
    required Abilities attackerAbility,
    required Abilities defenderAbility,
    bool isAttackerBurned = false,
  }) {
    double mult = 1.0;

    // choice items
    if (attackerItem == HeldItems.choiceBand && !move.isSpecial) {
      mult *= 1.5;
    } else if (attackerItem == HeldItems.choiceSpecs && move.isSpecial) {
      mult *= 1.5;
    }

    // offensive abilities
    if ((attackerAbility == Abilities.hugePower ||
            attackerAbility == Abilities.purePower) &&
        !move.isSpecial) {
      mult *= 2.0;
    }
    if (attackerAbility == Abilities.guts &&
        isAttackerBurned &&
        !move.isSpecial) {
      mult *= 1.5;
    }

    // defensive abilities that reduce incoming offensive stat
    if (defenderAbility == Abilities.thickFat &&
        (move.type == Types.fire || move.type == Types.ice)) {
      mult *= 0.5;
    }

    return mult;
  }

  // defense 
  static double getDefenseStatMultiplier({
    required Moves move,
    required Pokemon defender,
    required HeldItems defenderItem,
    required FieldEffects field,
  }) {
    double mult = 1.0;

    // defensive items
    if (defenderItem == HeldItems.assaultVest && move.isSpecial) {
      mult *= 1.5;
    } else if (defenderItem == HeldItems.eviolite) {
      mult *= 1.5;
    }

    // weather stat boosts 
    if (field.weather == Weather.sand &&
        move.isSpecial &&
        defender.types.contains(Types.rock)) {
      mult *= 1.5;
    } else if (field.weather == Weather.snow &&
        !move.isSpecial &&
        defender.types.contains(Types.ice)) {
      mult *= 1.5;
    }

    return mult;
  }

  // final damage modifiers 
  static double getFinalDamageMultiplier({
    required Moves move,
    required HeldItems attackerItem,
    required Abilities attackerAbility,
    required Abilities defenderAbility,
    required FieldEffects field,
    required double typeEffectiveness,
    bool isAttackerBurned = false,
    bool isDefenderFullHp = true,
  }) {
    double mult = 1.0;

    // weather move boosts/nerfs
    if (field.weather == Weather.sun) {
      if (move.type == Types.fire) mult *= 1.5;
      if (move.type == Types.water) mult *= 0.5;
    } else if (field.weather == Weather.rain) {
      if (move.type == Types.water) mult *= 1.5;
      if (move.type == Types.fire) mult *= 0.5;
    }

    // screens 
    if (!field.isCriticalHit) {
      final double screenMult = field.isDoubles ? (2732 / 4096) : 0.5;
      if (field.hasAuroraVeil) {
        mult *= screenMult;
      } else if (!move.isSpecial && field.hasReflect) {
        mult *= screenMult;
      } else if (move.isSpecial && field.hasLightScreen) {
        mult *= screenMult;
      }
    }

    // attacker items
    if (attackerItem == HeldItems.lifeOrb) {
      mult *= 1.3;
    } else if (attackerItem == HeldItems.expertBelt && typeEffectiveness > 1.0) {
      mult *= 1.2;
    }

    // burn penalty on physical move
    if (isAttackerBurned &&
        !move.isSpecial &&
        attackerAbility != Abilities.guts) {
      mult *= 0.5;
    }

    // defender damage-reduction abilities
    if (defenderAbility == Abilities.multiscale && isDefenderFullHp) {
      mult *= 0.5;
    }
    if (defenderAbility == Abilities.filter && typeEffectiveness > 1.0) {
      mult *= 0.75;
    }

    return mult;
  }
}