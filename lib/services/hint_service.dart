import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/country_hint.dart';

class HintService {
  static Map<String, CountryHint>? _hintsData;
  static bool _isLoaded = false;

  /// Carrega os dados das dicas do arquivo JSON
  static Future<void> loadHintsData() async {
    if (_isLoaded) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/country_hints.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _hintsData = {};
      jsonData.forEach((countryCode, hintData) {
        _hintsData![countryCode] = CountryHint.fromJson({
          'countryCode': countryCode,
          ...hintData,
        });
      });

      _isLoaded = true;
    } catch (e) {
      _hintsData = {};
      _isLoaded = false;
    }
  }

  /// Obtém a dica para um país específico
  static CountryHint? getHint(String countryCode) {
    if (!_isLoaded || _hintsData == null) {
      return null;
    }

    return _hintsData![countryCode];
  }

  /// Verifica se existe dica para um país
  static bool hasHint(String countryCode) {
    if (!_isLoaded || _hintsData == null) return false;
    return _hintsData!.containsKey(countryCode);
  }

  /// Obtém uma dica aleatória de um continente específico
  static CountryHint? getRandomHintByContinent(String continent) {
    if (!_isLoaded || _hintsData == null) return null;

    final continentHints = _hintsData!.values
        .where((hint) => hint.continent == continent)
        .toList();

    if (continentHints.isEmpty) return null;

    continentHints.shuffle();
    return continentHints.first;
  }

  /// Obtém uma dica aleatória de um idioma específico
  static CountryHint? getRandomHintByLanguage(String language) {
    if (!_isLoaded || _hintsData == null) return null;

    final languageHints = _hintsData!.values
        .where((hint) => hint.languages.contains(language))
        .toList();

    if (languageHints.isEmpty) return null;

    languageHints.shuffle();
    return languageHints.first;
  }

  /// Obtém todos os continentes disponíveis
  static List<String> getAvailableContinents() {
    if (!_isLoaded || _hintsData == null) return [];

    return _hintsData!.values.map((hint) => hint.continent).toSet().toList();
  }

  /// Obtém todos os idiomas disponíveis
  static List<String> getAvailableLanguages() {
    if (!_isLoaded || _hintsData == null) return [];

    final languages = <String>{};
    for (final hint in _hintsData!.values) {
      languages.addAll(hint.languages);
    }

    return languages.toList();
  }

  /// Verifica se os dados foram carregados
  static bool get isLoaded => _isLoaded;

  /// Obtém estatísticas das dicas
  static Map<String, dynamic> getHintsStats() {
    if (!_isLoaded || _hintsData == null) {
      return {
        'totalCountries': 0,
        'continents': {},
        'languages': {},
      };
    }

    final continents = <String, int>{};
    final languages = <String, int>{};

    for (final hint in _hintsData!.values) {
      // Contar continentes
      continents[hint.continent] = (continents[hint.continent] ?? 0) + 1;

      // Contar idiomas
      for (final language in hint.languages) {
        languages[language] = (languages[language] ?? 0) + 1;
      }
    }

    return {
      'totalCountries': _hintsData!.length,
      'continents': continents,
      'languages': languages,
    };
  }
}
