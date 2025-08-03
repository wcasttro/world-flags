import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class FeedbackService {
  static bool _isEnabled = true;

  static void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  static bool get isEnabled => _isEnabled;

  static Future<void> successFeedback() async {
    if (!_isEnabled) return;

    try {
      // Vibração de sucesso (curta)
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }

      // Som de sucesso (se disponível)
      HapticFeedback.lightImpact();
    } catch (e) {
      // Ignorar erros de feedback
    }
  }

  static Future<void> errorFeedback() async {
    if (!_isEnabled) return;

    try {
      // Vibração de erro (longa)
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(pattern: [0, 100, 50, 100]);
      }

      // Som de erro (se disponível)
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Ignorar erros de feedback
    }
  }

  static Future<void> tapFeedback() async {
    if (!_isEnabled) return;

    try {
      // Vibração de toque (muito curta)
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50);
      }

      // Feedback tátil
      HapticFeedback.selectionClick();
    } catch (e) {
      // Ignorar erros de feedback
    }
  }
} 