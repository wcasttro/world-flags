import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/language.dart';

class UITranslationService {
  static final Map<String, Map<String, String>> _uiTranslations = {};
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Carregar traduções da interface em português
      final ptData = await rootBundle.loadString('assets/translations/ui_pt.json');
      final ptTranslations = Map<String, String>.from(json.decode(ptData));
      _uiTranslations['pt'] = ptTranslations;

      // Carregar traduções da interface em espanhol
      final esData = await rootBundle.loadString('assets/translations/ui_es.json');
      final esTranslations = Map<String, String>.from(json.decode(esData));
      _uiTranslations['es'] = esTranslations;

      // Carregar traduções da interface em francês
      final frData = await rootBundle.loadString('assets/translations/ui_fr.json');
      final frTranslations = Map<String, String>.from(json.decode(frData));
      _uiTranslations['fr'] = frTranslations;

      // Carregar traduções da interface em inglês
      final enData = await rootBundle.loadString('assets/translations/ui_en.json');
      final enTranslations = Map<String, String>.from(json.decode(enData));
      _uiTranslations['en'] = enTranslations;

      _isInitialized = true;
    } catch (e) {
      // Ignorar erros de carregamento de traduções
    }
  }

  static String translate(String key, Language language) {
    if (!_isInitialized) {
      return key; // Retorna a chave se não foi inicializado
    }

    final translations = _uiTranslations[language.code];
    if (translations != null && translations.containsKey(key)) {
      return translations[key]!;
    }

    // Se não encontrar tradução, retorna a chave
    return key;
  }

  static String translateWithParams(String key, Language language, Map<String, String> params) {
    String translation = translate(key, language);
    
    // Substituir parâmetros na tradução
    params.forEach((param, value) {
      translation = translation.replaceAll('{$param}', value);
    });
    
    return translation;
  }
} 