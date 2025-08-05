import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/country.dart';
import '../models/user_error.dart';
import '../services/flags_service.dart';

class ErrorReviewService {
  static const String _errorsKey = 'user_errors';

  // Salvar um erro do usuário
  static Future<void> saveError(UserError error) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorsJson = prefs.getStringList(_errorsKey) ?? [];

      // Adicionar novo erro
      errorsJson.add(jsonEncode(error.toJson()));

      // Manter apenas os últimos 50 erros
      if (errorsJson.length > 50) {
        errorsJson.removeRange(0, errorsJson.length - 50);
      }

      await prefs.setStringList(_errorsKey, errorsJson);
    } catch (e) {
      // Ignorar erros de salvamento
    }
  }

  // Carregar todos os erros do usuário
  static Future<List<UserError>> loadErrors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorsJson = prefs.getStringList(_errorsKey) ?? [];

      final errors = <UserError>[];
      for (final errorJson in errorsJson) {
        try {
          final errorData = jsonDecode(errorJson) as Map<String, dynamic>;
          final error = UserError.fromJson(errorData);

          // Carregar dados completos do país
          final flagUrl = FlagsService.getFlagUrl(error.country.code);
          if (flagUrl != null) {
            final completeError = UserError(
              country: Country(
                code: error.country.code,
                name: error.correctAnswer,
                flagUrl: flagUrl,
              ),
              userAnswer: error.userAnswer,
              correctAnswer: error.correctAnswer,
              timestamp: error.timestamp,
            );
            errors.add(completeError);
          }
        } catch (e) {
          // Ignorar erros de parsing
        }
      }

      // Ordenar por timestamp (mais recentes primeiro)
      errors.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return errors;
    } catch (e) {
      return [];
    }
  }

  // Limpar todos os erros
  static Future<void> clearErrors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_errorsKey);
    } catch (e) {
      // Ignorar erros
    }
  }

  // Obter estatísticas dos erros
  static Future<Map<String, dynamic>> getErrorStats() async {
    final errors = await loadErrors();

    if (errors.isEmpty) {
      return {
        'totalErrors': 0,
        'uniqueCountries': 0,
        'mostCommonErrors': [],
      };
    }

    // Contar países únicos
    final uniqueCountries = errors.map((e) => e.country.code).toSet().length;

    // Encontrar erros mais comuns
    final errorCounts = <String, int>{};
    for (final error in errors) {
      final key = '${error.country.code}_${error.userAnswer}';
      errorCounts[key] = (errorCounts[key] ?? 0) + 1;
    }

    final mostCommonErrors = errorCounts.entries.map((entry) {
      final parts = entry.key.split('_');
      final countryCode = parts[0];
      final userAnswer = parts.sublist(1).join('_');
      return {
        'countryCode': countryCode,
        'userAnswer': userAnswer,
        'count': entry.value,
      };
    }).toList()
      ..sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

    return {
      'totalErrors': errors.length,
      'uniqueCountries': uniqueCountries,
      'mostCommonErrors': mostCommonErrors.take(5).toList(),
    };
  }
}
