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
  ];

  static Language get defaultLanguage => availableLanguages.first;
}
