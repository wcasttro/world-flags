import '../services/translation_service.dart';
import 'language.dart';

class Country {
  final String name;
  final String flagUrl;
  final String code;

  Country({
    required this.name,
    required this.flagUrl,
    required this.code,
  });

  String getTranslatedName(Language language) {
    return TranslationService.translateCountryName(name, language, code);
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {'common': name},
      'flags': {'png': flagUrl},
      'cca2': code,
    };
  }
}
