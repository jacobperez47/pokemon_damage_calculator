import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
//
import 'package:pokemon_damage_calculator/Pokemon%20Components/Moves.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Pokemon.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/PokemonForm.dart';
import 'package:pokemon_damage_calculator/Pokemon%20Components/Types.dart';
//

class CalcUI extends StatefulWidget {
  const CalcUI({super.key});

  @override
  State<CalcUI> createState() => _CalcUIState();
}//end of CalcUI

class _CalcUIState extends State<CalcUI> {
  //colors from the mockup
  static const Color _bg = Color(0xFFFBF0BE);
  static const Color _pill = Color(0xFFCBD2DC);
  static const Color _blue = Color(0xFF8FBCF0);

  //stat labels
  final List<String> _stats = ['HP', 'Atk', 'DEF', 'SPA', 'SDEF', 'SPD'];
  final Map<String, List<String>> _natures = {
    'Hardy': [],
    'Lonely': ['Atk', 'DEF'],
    'Brave': ['Atk', 'SPD'],
    'Adamant': ['Atk', 'SPA'],
    'Naughty': ['Atk', 'SDEF'],
    'Bold': ['DEF', 'Atk'],
    'Docile': [],
    'Relaxed': ['DEF', 'SPD'],
    'Impish': ['DEF', 'SPA'],
    'Lax': ['DEF', 'SDEF'],
    'Timid': ['SPD', 'Atk'],
    'Hasty': ['SPD', 'DEF'],
    'Serious': [],
    'Jolly': ['SPD', 'SPA'],
    'Naive': ['SPD', 'SDEF'],
    'Modest': ['SPA', 'Atk'],
    'Mild': ['SPA', 'DEF'],
    'Quiet': ['SPA', 'SPD'],
    'Bashful': [],
    'Rash': ['SPA', 'SDEF'],
    'Calm': ['SDEF', 'Atk'],
    'Gentle': ['SDEF', 'DEF'],
    'Sassy': ['SDEF', 'SPD'],
    'Careful': ['SDEF', 'SPA'],
    'Quirky': [],
  };//end of _natures
  //weather options
  final List<String> _weathers = ['None', 'Sun', 'Rain', 'Sandstorm', 'Snow'];
  //terrain options
  final List<String> _terrains = ['None', 'Electric', 'Grassy', 'Misty', 'Psychic'];
  //type 1/type 2 options
  final List<String> _types = [
    'Normal', 'Fire', 'Water', 'Electric', 'Grass', 'Ice',
    'Fighting', 'Poison', 'Ground', 'Flying', 'Psychic', 'Bug',
    'Rock', 'Ghost', 'Dragon', 'Dark', 'Steel', 'Fairy',
  ];//end of _types

  //toggle state
  bool _isAttacking = true;

  //selected dropdown values
  String? _type1, _type2, _nature, _weather, _terrain, _moveType;

  //controllers for the input boxes
  late final Map<String, TextEditingController> _baseControllers;
  late final Map<String, TextEditingController> _evControllers;
  late final Map<String, TextEditingController> _ivControllers;
  late final Map<String, TextEditingController> _finalControllers;
  final TextEditingController _moveController = TextEditingController();
  final TextEditingController _powerController = TextEditingController();

// *
// saved inputs for attacking and defending pokemon to keep the data
  final PokemonFormSnapshot _attackerSnapshot = PokemonFormSnapshot();
  final PokemonFormSnapshot _defenderSnapshot = PokemonFormSnapshot();

  // the pokemon and move objects are filled from user input
  Pokemon attacker = Pokemon();
  Pokemon defender = Pokemon();
  Moves usedMove = Moves('tackle', power: 40, type: Types.normal, isSpecial: false);

  PokemonFormSnapshot get _activeSnapshot =>
      _isAttacking ? _attackerSnapshot : _defenderSnapshot;

  void _syncInputsToModels() {
    final snap = _activeSnapshot;
    snap.type1 = _type1;
    snap.type2 = _type2;
    snap.nature = _nature;

    for (final stat in _stats) {
      snap.baseText[stat] = _baseControllers[stat]!.text;
      snap.evText[stat] = _evControllers[stat]!.text;
      snap.ivText[stat] = _ivControllers[stat]!.text;
    }

    // fill the actual attacker, defender, and usedMove models
    attacker = _attackerSnapshot.toPokemon();
    defender = _defenderSnapshot.toPokemon();
    usedMove = PokemonFormSnapshot.buildMove(
      nameText: _moveController.text,
      moveTypeText: _moveType,
      powerText: _powerController.text,
    );

    // auto fill read-only 'final stats' boxes live 
    final finals = snap.calculateFinalStats();
    for (int i = 0; i < _stats.length; i++) {
      _finalControllers[_stats[i]]!.text = finals[i].toString();
    }
  }
// *
  @override
  void initState() {
    super.initState();
    //make one controller per stat
    _baseControllers = {for (final s in _stats) s: TextEditingController()};
    _evControllers = {for (final s in _stats) s: TextEditingController()};
    _ivControllers = {for (final s in _stats) s: TextEditingController()};
    _finalControllers = {for (final s in _stats) s: TextEditingController()};
  }//end of initState

  @override
  void dispose() {
    //clean up every controller
    for (final c in [
      ..._baseControllers.values,
      ..._evControllers.values,
      ..._ivControllers.values,
      ..._finalControllers.values,
      _moveController,
      _powerController,
    ]) {
      c.dispose();
    }//end of for
    super.dispose();
  }//end of dispose

  //pill style used by every box
  InputDecoration _pillDecoration({String? hint, Color color = _pill}) {
    return InputDecoration(
      filled: true,
      fillColor: color,
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),//end of OutlineInputBorder
    );//end of InputDecoration
  }//end of _pillDecoration

  //number box (EV, IV, final stat)
  Widget _numberField(
      TextEditingController controller, {
        int? maxValue,
        Color color = _pill,
        bool readOnly = false,
      }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      onChanged: readOnly ? null : (_) => setState(()=> _syncInputsToModels()),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        if (maxValue != null) _MaxValueFormatter(maxValue),
      ],//end of inputFormatters
      decoration: _pillDecoration(color: color),
    );//end of TextField
  }//end of _numberField

  //dropdown (types, natures)
  Widget _dropdown({
    required String hint,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? value,
    Color color = _pill,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      hint: Text(hint, style: const TextStyle(fontSize: 13)),
      decoration: _pillDecoration(color: color),
      borderRadius: BorderRadius.circular(16),
      items: items.map((t) {
        return DropdownMenuItem<String>(value: t, child: Text(t));
      }).toList(),
      onChanged: onChanged,
    );//end of DropdownButtonFormField
  }//end of _dropdown

  //centered text label
  Widget _label(String text, {double size = 14}) {
    return Center(
      child: Text(
        text,
        style: TextStyle(fontSize: size, fontWeight: FontWeight.w500),
      ),//end of Text
    );//end of Center
  }//end of _label

  //headers
  TableRow _headerRow() {
    return TableRow(
      children: [
        const SizedBox(),
        _label('Base', size: 16),
        _label('EVS', size: 16),
        _label('IVS', size: 16),
        _label('Final Stat', size: 16),
      ],//end of children
    );//end of TableRow
  }//end of _headerRow

  //stats (1 label + the 3 input fields)
  TableRow _statRow(String stat) {
    return TableRow(
      children: [
        //stat label
        Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _pill,
              borderRadius: BorderRadius.circular(20),
            ),//end of BoxDecoration
            child: _label(stat, size: 16),
          ),//end of Container
        ),//end of Padding
        //base stat box
        Padding(
          padding: const EdgeInsets.all(6),
          child: _numberField(_baseControllers[stat]!, maxValue: 255),
        ),//end of Padding
        //EV box
        Padding(
          padding: const EdgeInsets.all(6),
          child: _numberField(_evControllers[stat]!, maxValue: 252),
        ),//end of Padding
        //IV box
        Padding(
          padding: const EdgeInsets.all(6),
          child: _numberField(_ivControllers[stat]!, maxValue: 31),
        ),//end of Padding
        //final stat box
        Padding(
          padding: const EdgeInsets.all(6),
          child: _numberField(_finalControllers[stat]!, readOnly: true),
        ),//end of Padding
      ],//end of children
    );//end of TableRow
  }//end of _statRow

  //text under the nature dropdown 
  String _natureEffect() {
    if (_nature == null) return '';
    final effect = _natures[_nature]!;
    if (effect.isEmpty) return 'No stat change';
    return '+${effect[0]}   -${effect[1]}';
  }//end of _natureEffect

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //background color
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //toggle button
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _pill,
                    foregroundColor: Colors.black87,
                  ),//end of styleFrom
                  onPressed: () {
                    setState(() {
                      _syncInputsToModels(); // save current side
                      _isAttacking = !_isAttacking;

                      final next = _activeSnapshot;
                        _type1 = next.type1;
                        _type2 = next.type2;
                        _nature = next.nature;
                        for (final stat in _stats) {
                          _baseControllers[stat]!.text = next.baseText[stat] ?? '';
                          _evControllers[stat]!.text = next.evText[stat] ?? '';
                          _ivControllers[stat]!.text = next.ivText[stat] ?? '';
                        }
                        _syncInputsToModels();//refresg final stat column
                    });//end of setState
                  },//end of onPressed
                  child: Text(
                    _isAttacking
                        ? 'Switch to defending\npokemon stats'
                        : 'Switch to attacking\npokemon stats',
                    textAlign: TextAlign.center,
                  ),//end of Text
                ),//end of FilledButton
              ),//end of Align
              const SizedBox(height: 24),

              //screen title
              const Center(
                child: Text(
                  'Final Calculation Range',
                  style: TextStyle(fontSize: 26),
                ),//end of Text
              ),//end of Center
              const SizedBox(height: 24),

              //type 1/type 2 row
              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      hint: 'Type 1',
                      value: _type1,
                      items: _types,
                      onChanged: (v) {
                        setState(() {
                          _type1 = v;
                          _syncInputsToModels();
                        });//end of setState
                      },//end of onChanged
                    ),//end of _dropdown
                  ),//end of Expanded
                  const SizedBox(width: 16),
                  Expanded(
                    child: _dropdown(
                      hint: 'Type 2',
                      value: _type2,
                      items: _types,
                      onChanged: (v) {
                        setState(() {
                          _type2 = v;
                          _syncInputsToModels();
                        });//end of setState
                      },//end of onChanged
                    ),//end of _dropdown
                  ),//end of Expanded
                ],//end of children
              ),//end of Row
              const SizedBox(height: 16),

              //weather/terrain row
              Row(
                children: [
                  Expanded(
                    child: _dropdown(
                      hint: 'Weather',
                      items: _weathers,
                      onChanged: (v) {
                        setState(() {
                          _weather = v;
                        });//end of setState
                      },//end of onChanged
                    ),//end of _dropdown
                  ),//end of Expanded
                  const SizedBox(width: 16),
                  Expanded(
                    child: _dropdown(
                      hint: 'Terrain',
                      items: _terrains,
                      onChanged: (v) {
                        setState(() {
                          _terrain = v;
                        });//end of setState
                      },//end of onChanged
                    ),//end of _dropdown
                  ),//end of Expanded
                ],//end of children
              ),//end of Row
              const SizedBox(height: 16),

              //headers + the 6 stat rows
              Table(
                columnWidths: const {0: FixedColumnWidth(72)},
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  _headerRow(),
                  for (final stat in _stats) _statRow(stat),
                ],//end of children
              ),//end of Table
              const SizedBox(height: 16),

              //Nature (one dropdown, shows what it changes)
              _dropdown(
                hint: 'Nature',
                items: _natures.keys.toList(),
                onChanged: (v) {
                  setState(() {
                    _nature = v;
                    _syncInputsToModels();
                  });//end of setState
                },//end of onChanged
              ),//end of _dropdown
              const SizedBox(height: 6),
              Center(
                child: Text(_natureEffect()),
              ),//end of Center
              const SizedBox(height: 24),

              //Move/type/power
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _moveController,
                      onChanged: (_) => setState(() => _syncInputsToModels()),
                      decoration: _pillDecoration(hint: 'Move', color: _blue),
                    ),//end of TextField
                  ),//end of Expanded
                  const SizedBox(width: 12),
                  Expanded(
                    child: _dropdown(
                      hint: 'Type',
                      items: _types,
                      color: _blue,
                      onChanged: (v) {
                        setState(() {
                          _moveType = v;
                          _syncInputsToModels();
                        });//end of setState
                      },//end of onChanged
                    ),//end of _dropdown
                  ),//end of Expanded
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _powerController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() => _syncInputsToModels()),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _pillDecoration(hint: 'Power', color: _blue),
                    ),//end of TextField
                  ),//end of Expanded
                ],//end of children
              ),//end of Row
            ],//end of children
          ),//end of Column
        ),//end of SingleChildScrollView
      ),//end of SafeArea
    );//end of Scaffold
  }//end of build
}//end of _CalcUIState

//stops typing a number above max (IV 31, EV 252)
class _MaxValueFormatter extends TextInputFormatter {
  final int max;
  _MaxValueFormatter(this.max);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    final value = int.tryParse(newValue.text);
    return (value != null && value <= max) ? newValue : oldValue;
  }//end of formatEditUpdate
}//end of _MaxValueFormatter