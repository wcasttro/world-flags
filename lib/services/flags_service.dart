import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/country.dart';
import 'translation_service.dart';

class FlagsService {
  static Map<String, String>? _flagsData;
  static List<Country>? _allCountries;
  static bool _isLoaded = false;

  /// Carrega os dados das bandeiras do arquivo JSON
  static Future<void> loadFlagsData() async {
    if (_isLoaded) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/flags_data.json');
      _flagsData = Map<String, String>.from(json.decode(jsonString));
      _isLoaded = true;
      debugPrint(
          'Flags data loaded successfully. Total flags: ${_flagsData!.length}');

      // Criar lista de países baseada nos dados das bandeiras
      _createCountriesList();
    } catch (e) {
      debugPrint('Error loading flags data: $e');
      _flagsData = {};
      _isLoaded = false;
    }
  }

  /// Cria a lista de países baseada nos dados das bandeiras
  static void _createCountriesList() {
    if (_flagsData == null) return;

    _allCountries = _flagsData!.entries.map((entry) {
      final code = entry.key;
      final flagUrl = entry.value;

      // Nome do país baseado no código usando TranslationService
      final name = _getCountryNameFromCode(code);

      return Country(
        name: name,
        flagUrl: flagUrl,
        code: code,
      );
    }).toList();
  }

  /// Obtém o nome do país baseado no código usando TranslationService
  static String _getCountryNameFromCode(String code) {
    // Inicializar TranslationService se necessário
    TranslationService.initialize();

    // Obter nome do país usando TranslationService
    return TranslationService.getCountryNameByCode(code);
  }

  /// Obtém a URL da bandeira PNG para um código de país
  static String? getFlagUrl(String countryCode) {
    if (!_isLoaded || _flagsData == null) {
      debugPrint('Flags data not loaded yet');
      return null;
    }

    final code = countryCode.toUpperCase();
    return _flagsData![code];
  }

  /// Verifica se uma bandeira existe para o código do país
  static bool hasFlag(String countryCode) {
    if (!_isLoaded || _flagsData == null) return false;

    final code = countryCode.toUpperCase();
    return _flagsData!.containsKey(code);
  }

  /// Obtém todos os códigos de países disponíveis
  static List<String> getAvailableCountryCodes() {
    if (!_isLoaded || _flagsData == null) return [];

    return _flagsData!.keys.toList();
  }

  /// Obtém o número total de bandeiras disponíveis
  static int getTotalFlags() {
    if (!_isLoaded || _flagsData == null) return 0;

    return _flagsData!.length;
  }

  /// Obtém todos os países
  static List<Country> getAllCountries() {
    if (!_isLoaded || _allCountries == null) return [];
    return List.from(_allCountries!);
  }

  /// Obtém países aleatórios
  static List<Country> getRandomCountries(int count) {
    if (!_isLoaded || _allCountries == null) return [];

    final allCountries = List<Country>.from(_allCountries!);
    allCountries.shuffle();
    return allCountries.take(count).toList();
  }

  /// Verifica se os dados foram carregados
  static bool get isLoaded => _isLoaded;
}
