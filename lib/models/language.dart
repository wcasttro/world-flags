class Language {
  final String code;
  final String name;
  final String nativeName;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  static const List<Language> availableLanguages = [
    Language(code: 'pt', name: 'Português', nativeName: 'Português'),
    Language(code: 'en', name: 'English', nativeName: 'English'),
    Language(code: 'es', name: 'Español', nativeName: 'Español'),
    Language(code: 'fr', name: 'Français', nativeName: 'Français'),
    Language(code: 'de', name: 'Deutsch', nativeName: 'Deutsch'),
    Language(code: 'it', name: 'Italiano', nativeName: 'Italiano'),
    Language(code: 'ja', name: '日本語', nativeName: '日本語'),
    Language(code: 'ko', name: '한국어', nativeName: '한국어'),
    Language(code: 'zh', name: '中文', nativeName: '中文'),
    Language(code: 'ar', name: 'العربية', nativeName: 'العربية'),
  ];

  static Language get defaultLanguage => availableLanguages.first;
} 