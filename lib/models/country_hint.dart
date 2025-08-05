class CountryHint {
  final String countryCode;
  final String continent;
  final List<String> languages;
  final String capital;
  final int population;
  final String currency;

  const CountryHint({
    required this.countryCode,
    required this.continent,
    required this.languages,
    required this.capital,
    required this.population,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'countryCode': countryCode,
      'continent': continent,
      'languages': languages,
      'capital': capital,
      'population': population,
      'currency': currency,
    };
  }

  factory CountryHint.fromJson(Map<String, dynamic> json) {
    return CountryHint(
      countryCode: json['countryCode'],
      continent: json['continent'],
      languages: List<String>.from(json['languages']),
      capital: json['capital'],
      population: json['population'],
      currency: json['currency'],
    );
  }

  String getFormattedLanguages() {
    if (languages.isEmpty) return '';
    if (languages.length == 1) return languages.first;
    return '${languages.take(languages.length - 1).join(', ')} e ${languages.last}';
  }

  String getFormattedPopulation() {
    if (population >= 1000000000) {
      return '${(population / 1000000000).toStringAsFixed(1)} bilhões';
    } else if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)} milhões';
    } else if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(1)} mil';
    }
    return population.toString();
  }
}
