import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:world_flags/firebase_options.dart';

import 'screens/home_screen.dart';
import 'services/crashlytics_service.dart';
import 'services/hint_service.dart';
import 'services/translation_service.dart';
import 'services/ui_translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

    // Inicializar Crashlytics Service primeiro
  CrashlyticsService.initialize();
  
  // Aguardar um pouco para garantir que o Crashlytics esteja inicializado
  await Future.delayed(const Duration(milliseconds: 100));
  
  // Configurar Crashlytics após inicialização
  try {
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      try {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      } catch (e) {
        print('Crashlytics fatal error handler failed: $e');
      }
      return true;
    };
  } catch (e) {
    print('Crashlytics error handler setup failed: $e');
  }

  // Inicializar Google Mobile Ads
  MobileAds.instance.initialize();

  await TranslationService.initialize();
  await UITranslationService.initialize();
  await HintService.loadHintsData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Flags',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E3A8A)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
