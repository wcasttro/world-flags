import 'country.dart';

class GameState {
  final int currentQuestion;
  final int totalQuestions;
  final int score;
  final List<Country> countries;
  final Country? currentCountry;
  final List<String> options;
  final bool isAnswered;
  final bool isCorrect;

  GameState({
    required this.currentQuestion,
    required this.totalQuestions,
    required this.score,
    required this.countries,
    this.currentCountry,
    required this.options,
    required this.isAnswered,
    required this.isCorrect,
  });

  GameState copyWith({
    int? currentQuestion,
    int? totalQuestions,
    int? score,
    List<Country>? countries,
    Country? currentCountry,
    List<String>? options,
    bool? isAnswered,
    bool? isCorrect,
  }) {
    return GameState(
      currentQuestion: currentQuestion ?? this.currentQuestion,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      score: score ?? this.score,
      countries: countries ?? this.countries,
      currentCountry: currentCountry ?? this.currentCountry,
      options: options ?? this.options,
      isAnswered: isAnswered ?? this.isAnswered,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }

  bool get isGameOver => currentQuestion >= totalQuestions;
  double get progress => currentQuestion / totalQuestions;
} 