import 'dart:convert';

import 'package:flutter/services.dart';

import '../Pokemon Components/Types.dart';

class PokemonEntry {
  final String id;
  final String name;
  final List<Types> types;

  // Same order as Pokemon.baseStats and the calculator's stat table.
  final List<int> baseStats;

  PokemonEntry.fromJson(Map<String, dynamic> json)
    : id = json['id'] as String,
      name = json['name'] as String,
      types = List.unmodifiable(
        (json['types'] as List<dynamic>).map(
          (type) => Types.values.byName(type as String),
        ),
      ),
      baseStats = _readBaseStats(json['baseStats'] as Map<String, dynamic>);

  static List<int> _readBaseStats(Map<String, dynamic> stats) {
    return List.unmodifiable([
      stats['hp'] as int,
      stats['attack'] as int,
      stats['defense'] as int,
      stats['specialAttack'] as int,
      stats['specialDefense'] as int,
      stats['speed'] as int,
    ]);
  }
}

class PokemonCatalog {
  final List<PokemonEntry> _entries;

  PokemonCatalog._(this._entries);

  static Future<PokemonCatalog> load() async {
    final json = await rootBundle.loadString(
      'assets/data/pokemon.json',
      cache: false,
    );
    final entries = (jsonDecode(json) as List<dynamic>)
        .map((entry) => PokemonEntry.fromJson(entry as Map<String, dynamic>))
        .toList();
    entries.sort((first, second) => first.name.compareTo(second.name));
    return PokemonCatalog._(entries);
  }

  Iterable<PokemonEntry> searchByName(String query) sync* {
    final term = _searchKey(query);
    if (term.isEmpty) return;

    final otherMatches = <PokemonEntry>[];
    for (final entry in _entries) {
      final name = _searchKey(entry.name);
      if (name.startsWith(term)) {
        yield entry;
      } else if (name.contains(term)) {
        otherMatches.add(entry);
      }
    }
    yield* otherMatches;
  }

  static final _nonSearchCharacters = RegExp(r'[^a-z0-9♀♂]');

  // Match the displayed spelling even when the user fails punctuation.
  static String _searchKey(String name) => name
      .toLowerCase()
      .replaceAll('é', 'e')
      .replaceAll(_nonSearchCharacters, '');
}
