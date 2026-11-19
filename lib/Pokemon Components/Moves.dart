import 'package:pokemon_damage_calculator/Pokemon%20Components/Types.dart';

class Moves {
  final String name;
  final int power;
  final Types type;
  final bool isSpecial;

  Moves(
    this.name, {
    required this.power,
    required this.type,
    required this.isSpecial,
  });
}
