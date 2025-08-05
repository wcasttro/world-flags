import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/language.dart';

class TranslationService {
  static final Map<String, Map<String, String>> _translations = {};
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Carregar traduções do português
      final ptData = await rootBundle.loadString('assets/translations/pt.json');
      final ptTranslations = Map<String, String>.from(json.decode(ptData));
      _translations['pt'] = ptTranslations;

      // Carregar traduções do espanhol
      final esData = await rootBundle.loadString('assets/translations/es.json');
      final esTranslations = Map<String, String>.from(json.decode(esData));
      _translations['es'] = esTranslations;

      // Carregar traduções do francês
      final frData = await rootBundle.loadString('assets/translations/fr.json');
      final frTranslations = Map<String, String>.from(json.decode(frData));
      _translations['fr'] = frTranslations;

      // Carrega traduções em inglês
      final enData = await rootBundle.loadString('assets/translations/en.json');
      final enTranslations = Map<String, String>.from(json.decode(enData));
      _translations['en'] = enTranslations;

      _isInitialized = true;
    } catch (e) {
      // Ignorar erros de carregamento de traduções
    }
  }

  static String translateCountryName(
    String englishName,
    Language language,
    String countryCode,
  ) {
    final translations = _translations[language.code];
    if (translations != null && translations.containsKey(countryCode)) {
      return translations[countryCode]!;
    }

    // Se não encontrar tradução, retorna o nome original
    return englishName;
  }

  /// Obtém o nome do país pelo código em português
  static String getCountryNameByCode(String countryCode) {
    final translations = _translations['pt'];
    if (translations != null && translations.containsKey(countryCode)) {
      return translations[countryCode]!;
    }

    // Se não encontrar tradução, retorna o código
    return countryCode;
  }
}
