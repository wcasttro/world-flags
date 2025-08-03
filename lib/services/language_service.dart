import 'package:shared_preferences/shared_preferences.dart';
import '../models/language.dart';

class LanguageService {
  static const String _languageKey = 'selected_language';
  
  static Future<Language> getSelectedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey) ?? Language.defaultLanguage.code;
    
    return Language.availableLanguages.firstWhere(
      (lang) => lang.code == languageCode,
      orElse: () => Language.defaultLanguage,
    );
  }

  static Future<void> setSelectedLanguage(Language language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.code);
  }

  static Future<void> resetToDefault() async {
    await setSelectedLanguage(Language.defaultLanguage);
  }
} 