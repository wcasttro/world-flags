import 'dart:math';

import 'package:flutter/material.dart';

import '../models/country.dart';
import '../models/country_hint.dart';
import '../models/game_state.dart';
import '../models/language.dart';
import '../models/user_error.dart';
import '../services/crashlytics_service.dart';
import '../services/error_review_service.dart';
import '../services/flags_service.dart';
import '../services/hint_service.dart';
import '../services/language_service.dart';
import '../services/ui_translation_service.dart';
import '../utils/admob.dart';
import '../widgets/animated_option_button.dart';
import '../widgets/flag_image.dart';
import 'game_over_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  GameState? _gameState;
  bool _isLoading = true;
  String? _error;
  Language? _selectedLanguage;
  late AdMod _adMod;

  @override
  void initState() {
    super.initState();

    _initializeGame();
  }

  @override
  void didChangeDependencies() {
    _initializeAdMod();
    super.didChangeDependencies();
  }

  void _initializeAdMod() {
    _adMod = AdMod(
      bannerIdAdMob: 'ca-app-pub-7971613376829432/6844840799',
      interstitialAdMob: 'ca-app-pub-7971613376829432/4829067459',
    );
    _adMod.createBannerAd();
    _adMod.createInterstitialAd();
  }

  void _showInterstitialAd() {
    _adMod.showInterstitialAd();
  }

  Future<void> _initializeGame() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final selectedLanguage = await LanguageService.getSelectedLanguage();
      setState(() {
        _selectedLanguage = selectedLanguage;
      });

      // Log da seleção de idioma no Crashlytics
      CrashlyticsService.logLanguageSelection(selectedLanguage.code);

      // Carregar dados das bandeiras e dicas
      try {
        await FlagsService.loadFlagsData();
        CrashlyticsService.logDataLoading(
          dataType: 'flags_data',
          success: true,
        );
      } catch (e) {
        CrashlyticsService.logDataLoading(
          dataType: 'flags_data',
          success: false,
          error: e.toString(),
        );
      }

      try {
        await HintService.loadHintsData();
        CrashlyticsService.logDataLoading(
          dataType: 'hints_data',
          success: true,
        );
      } catch (e) {
        CrashlyticsService.logDataLoading(
          dataType: 'hints_data',
          success: false,
          error: e.toString(),
        );
      }

      final countries = FlagsService.getRandomCountries(50);
      final gameCountries = countries.take(10).toList();

      setState(() {
        _gameState = GameState(
          currentQuestion: 0,
          totalQuestions: 10,
          score: 0,
          countries: gameCountries,
          options: [],
          isAnswered: false,
          isCorrect: false,
          errors: [],
        );
        _isLoading = false;
      });

      _loadNextQuestion();
    } catch (e) {
      // Log do erro no Crashlytics
      CrashlyticsService.recordError(e, StackTrace.current,
          reason: 'Game initialization error');

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _loadNextQuestion() {
    if (_gameState!.isGameOver) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameOverScreen(
            score: _gameState!.score,
            totalQuestions: _gameState!.totalQuestions,
          ),
        ),
      );
    }
    if (_gameState == null ||
        _gameState!.isGameOver ||
        _selectedLanguage == null) return;

    final currentCountry = _gameState!.countries[_gameState!.currentQuestion];
    final allCountries = List<Country>.from(_gameState!.countries);
    allCountries.shuffle();

    // Gerar opções: resposta correta + 3 opções aleatórias
    final options = <String>[
      currentCountry.getTranslatedName(_selectedLanguage!)
    ];
    final random = Random();

    while (options.length < 4) {
      final randomCountry = allCountries[random.nextInt(allCountries.length)];
      final translatedName =
          randomCountry.getTranslatedName(_selectedLanguage!);
      if (!options.contains(translatedName)) {
        options.add(translatedName);
      }
    }

    options.shuffle();

    setState(() {
      _gameState = _gameState!.copyWith(
        currentCountry: currentCountry,
        options: options,
        isAnswered: false,
        isCorrect: false,
      );
    });
  }

  void _answerQuestion(String selectedAnswer) {
    if (_gameState == null ||
        _gameState!.isAnswered ||
        _selectedLanguage == null) return;

    final correctAnswer =
        _gameState!.currentCountry!.getTranslatedName(_selectedLanguage!);
    final isCorrect = selectedAnswer == correctAnswer;
    final newScore = _gameState!.score + (isCorrect ? 1 : 0);

    // Salvar erro se a resposta estiver incorreta
    if (!isCorrect) {
      final error = UserError(
        country: _gameState!.currentCountry!,
        userAnswer: selectedAnswer,
        correctAnswer: correctAnswer,
        timestamp: DateTime.now(),
      );

      // Salvar erro no serviço
      ErrorReviewService.saveError(error);

      // Log do erro no Crashlytics
      CrashlyticsService.logUserError(
        countryCode: _gameState!.currentCountry!.code,
        userAnswer: selectedAnswer,
        correctAnswer: correctAnswer,
      );

      // Adicionar erro à lista do jogo
      final newErrors = List<UserError>.from(_gameState!.errors)..add(error);

      setState(() {
        _gameState = _gameState!.copyWith(
          score: newScore,
          isAnswered: true,
          isCorrect: isCorrect,
          errors: newErrors,
        );
      });
    } else {
      setState(() {
        _gameState = _gameState!.copyWith(
          score: newScore,
          isAnswered: true,
          isCorrect: isCorrect,
        );
      });
    }

    // Log da ação do jogo no Crashlytics
    CrashlyticsService.logGameInfo(
      action: 'answer_question',
      countryCode: _gameState!.currentCountry!.code,
      isCorrect: isCorrect,
      score: newScore,
      totalQuestions: _gameState!.totalQuestions,
    );

    // Aguardar um pouco antes de ir para próxima pergunta
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_gameState == null) return;

    if (_gameState!.isGameOver) {
      // Mostrar interstitial ad antes de ir para a tela de conclusão
      _showInterstitialAd();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => GameOverScreen(
            score: _gameState!.score,
            totalQuestions: _gameState!.totalQuestions,
          ),
        ),
      );
    } else {
      setState(() {
        _gameState = _gameState!.copyWith(
          currentQuestion: _gameState!.currentQuestion + 1,
        );
      });
      _loadNextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Carregando países...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Erro: $_error'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _initializeGame,
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_gameState == null) {
      return const Scaffold(
        body: Center(
          child: Text('Erro: Estado do jogo não inicializado'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('World Flags'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_gameState!.score}/${_gameState!.totalQuestions}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Progresso
                LinearProgressIndicator(
                  value: _gameState!.progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),

                const SizedBox(height: 12),

                // Pergunta
                Text(
                  UITranslationService.translate(
                      'game_question', _selectedLanguage!),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Bandeira
                FlagImage(
                  height: 250,
                  flagUrl: _gameState!.currentCountry!.flagUrl,
                ),

                const SizedBox(height: 40),

                // Opções
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        ..._gameState!.options
                            .map((option) => _buildOptionButton(option)),

                        const SizedBox(height: 8),

                        // Botão de dica
                        if (_gameState!.currentCountry != null)
                          _buildHintButton(),

                        const SizedBox(height: 8),

                        // Banner Ad
                        Center(
                          child: _adMod.banner(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    final isSelected = _gameState!.isAnswered &&
        option ==
            _gameState!.currentCountry!.getTranslatedName(_selectedLanguage!);
    final isCorrect =
        _gameState!.isAnswered && _gameState!.isCorrect && isSelected;
    final isWrong = _gameState!.isAnswered &&
        !_gameState!.isCorrect &&
        option ==
            _gameState!.currentCountry!.getTranslatedName(_selectedLanguage!);

    IconData? feedbackIcon;
    if (_gameState!.isAnswered) {
      if (isCorrect) {
        feedbackIcon = Icons.check_circle;
      } else if (isWrong) {
        feedbackIcon = Icons.cancel;
      }
    }

    return AnimatedOptionButton(
      text: option,
      onPressed: () => _answerQuestion(option),
      isCorrect: isCorrect,
      isWrong: isWrong,
      isAnswered: _gameState!.isAnswered,
      feedbackIcon: feedbackIcon,
    );
  }

  Widget _buildHintButton() {
    final countryCode = _gameState!.currentCountry!.code;
    final hint = HintService.getHint(countryCode);
    final hasHint = hint != null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ElevatedButton.icon(
        onPressed: hasHint
            ? () {
                // Log do uso de dica no Crashlytics
                CrashlyticsService.logHintUsage(
                  countryCode: countryCode,
                  hintType: 'full_hint',
                );
                _showHintBottomSheet(hint);
              }
            : null,
        icon: Icon(
          Icons.lightbulb,
          color: hasHint ? Colors.white : Colors.grey,
          size: 20,
        ),
        label: Text(
          UITranslationService.translate(
              'show_hint_button', _selectedLanguage!),
          style: TextStyle(
            color: hasHint ? Colors.white : Colors.grey,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: hasHint ? Colors.blue[600] : Colors.grey[400],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        ),
      ),
    );
  }

  void _showHintBottomSheet(CountryHint hint) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      color: Colors.orange[600],
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      UITranslationService.translate(
                          'hint_title', _selectedLanguage!),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[600],
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                      tooltip: UITranslationService.translate(
                          'close', _selectedLanguage!),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Informações da dica
                _buildHintInfo(
                  context,
                  Icons.public,
                  UITranslationService.translate(
                      'continent_label', _selectedLanguage!),
                  hint.continent,
                ),

                const SizedBox(height: 12),

                _buildHintInfo(
                  context,
                  Icons.language,
                  UITranslationService.translate(
                      'languages_label', _selectedLanguage!),
                  hint.getFormattedLanguages(),
                ),

                const SizedBox(height: 12),

                _buildHintInfo(
                  context,
                  Icons.location_city,
                  UITranslationService.translate(
                      'capital_label', _selectedLanguage!),
                  hint.capital,
                ),

                const SizedBox(height: 12),

                _buildHintInfo(
                  context,
                  Icons.people,
                  UITranslationService.translate(
                      'population_label', _selectedLanguage!),
                  hint.getFormattedPopulation(),
                ),

                const SizedBox(height: 12),

                _buildHintInfo(
                  context,
                  Icons.attach_money,
                  UITranslationService.translate(
                      'currency_label', _selectedLanguage!),
                  hint.currency,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHintInfo(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
