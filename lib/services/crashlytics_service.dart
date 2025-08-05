import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsService {
  static final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Configura o Crashlytics para capturar erros
  static void initialize() {
    try {
      // Configurar para capturar erros não fatais
      _crashlytics.setCrashlyticsCollectionEnabled(true);
    } catch (e) {
      // Ignorar erros de inicialização do Crashlytics
      print('Crashlytics initialization error: $e');
    }
  }

  /// Registra um erro não fatal
  static void recordError(dynamic error, StackTrace? stackTrace,
      {String? reason}) {
    try {
      _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
      );
    } catch (e) {
      // Ignorar erros do Crashlytics
      print('Crashlytics recordError failed: $e');
    }
  }

  /// Registra uma mensagem de log
  static void log(String message) {
    try {
      _crashlytics.log(message);
    } catch (e) {
      // Ignorar erros do Crashlytics
      print('Crashlytics log failed: $e');
    }
  }

  /// Define um atributo personalizado
  static void setCustomKey(String key, dynamic value) {
    try {
      _crashlytics.setCustomKey(key, value);
    } catch (e) {
      // Ignorar erros do Crashlytics
      print('Crashlytics setCustomKey failed: $e');
    }
  }

  /// Define o ID do usuário
  static void setUserIdentifier(String userId) {
    try {
      _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      // Ignorar erros do Crashlytics
      print('Crashlytics setUserIdentifier failed: $e');
    }
  }

  /// Registra uma exceção não fatal
  static void recordException(dynamic exception, StackTrace? stackTrace) {
    try {
      _crashlytics.recordError(
        exception,
        stackTrace,
        reason: 'Non-fatal exception',
      );
    } catch (e) {
      // Ignorar erros do Crashlytics
      print('Crashlytics recordException failed: $e');
    }
  }

  /// Registra informações sobre o jogo
  static void logGameInfo({
    required String action,
    required String countryCode,
    required bool isCorrect,
    required int score,
    required int totalQuestions,
  }) {
    setCustomKey('game_action', action);
    setCustomKey('country_code', countryCode);
    setCustomKey('is_correct', isCorrect);
    setCustomKey('score', score);
    setCustomKey('total_questions', totalQuestions);

    log('Game action: $action - Country: $countryCode - Correct: $isCorrect - Score: $score/$totalQuestions');
  }

  /// Registra informações sobre erros do usuário
  static void logUserError({
    required String countryCode,
    required String userAnswer,
    required String correctAnswer,
  }) {
    setCustomKey('error_country_code', countryCode);
    setCustomKey('user_answer', userAnswer);
    setCustomKey('correct_answer', correctAnswer);

    log('User error - Country: $countryCode - User answer: $userAnswer - Correct: $correctAnswer');
  }

  /// Registra informações sobre o uso de dicas
  static void logHintUsage({
    required String countryCode,
    required String hintType,
  }) {
    setCustomKey('hint_country_code', countryCode);
    setCustomKey('hint_type', hintType);

    log('Hint used - Country: $countryCode - Type: $hintType');
  }

  /// Registra informações sobre o idioma selecionado
  static void logLanguageSelection(String languageCode) {
    setCustomKey('selected_language', languageCode);
    log('Language selected: $languageCode');
  }

  /// Registra informações sobre o carregamento de dados
  static void logDataLoading({
    required String dataType,
    required bool success,
    String? error,
  }) {
    setCustomKey('data_type', dataType);
    setCustomKey('loading_success', success);
    if (error != null) {
      setCustomKey('loading_error', error);
    }

    log('Data loading - Type: $dataType - Success: $success${error != null ? ' - Error: $error' : ''}');
  }
}
