import 'country.dart';

class UserError {
  final Country country;
  final String userAnswer;
  final String correctAnswer;
  final DateTime timestamp;

  UserError({
    required this.country,
    required this.userAnswer,
    required this.correctAnswer,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'countryCode': country.code,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  factory UserError.fromJson(Map<String, dynamic> json) {
    return UserError(
      country: Country(
        code: json['countryCode'],
        name: json['correctAnswer'], // Usar a resposta correta como nome
        flagUrl: '', // Será carregado posteriormente
      ),
      userAnswer: json['userAnswer'],
      correctAnswer: json['correctAnswer'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
    );
  }
}
