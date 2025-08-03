class Country {
  final String name;
  final String flagUrl;
  final String code;

  Country({
    required this.name,
    required this.flagUrl,
    required this.code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name']['common'] ?? '',
      flagUrl: json['flags']['png'] ?? '',
      code: json['cca2'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {'common': name},
      'flags': {'png': flagUrl},
      'cca2': code,
    };
  }
} 