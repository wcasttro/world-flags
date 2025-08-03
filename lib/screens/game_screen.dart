import 'dart:math';
import 'package:flutter/material.dart';
import '../models/country.dart';
import '../models/game_state.dart';
import '../services/country_service.dart';
import '../services/language_service.dart';
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

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final selectedLanguage = await LanguageService.getSelectedLanguage();
      final countries = await CountryService.getRandomCountries(50, selectedLanguage);
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
        );
        _isLoading = false;
      });

      _loadNextQuestion();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _loadNextQuestion() {
    if (_gameState == null || _gameState!.isGameOver) return;

    final currentCountry = _gameState!.countries[_gameState!.currentQuestion];
    final allCountries = List<Country>.from(_gameState!.countries);
    allCountries.shuffle();

    // Gerar opções: resposta correta + 3 opções aleatórias
    final options = <String>[currentCountry.name];
    final random = Random();
    
    while (options.length < 4) {
      final randomCountry = allCountries[random.nextInt(allCountries.length)];
      if (!options.contains(randomCountry.name)) {
        options.add(randomCountry.name);
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
    if (_gameState == null || _gameState!.isAnswered) return;

    final isCorrect = selectedAnswer == _gameState!.currentCountry!.name;
    final newScore = _gameState!.score + (isCorrect ? 1 : 0);

    setState(() {
      _gameState = _gameState!.copyWith(
        score: newScore,
        isAnswered: true,
        isCorrect: isCorrect,
      );
    });

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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Progresso
                LinearProgressIndicator(
                  value: _gameState!.progress,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                
                const SizedBox(height: 24),
                
                // Pergunta
                Text(
                  'Qual é este país?',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Bandeira
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        _gameState!.currentCountry!.flagUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flag, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  'Erro ao carregar bandeira',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Opções
                ..._gameState!.options.map((option) => _buildOptionButton(option)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    final isSelected = _gameState!.isAnswered && option == _gameState!.currentCountry!.name;
    final isCorrect = _gameState!.isAnswered && _gameState!.isCorrect && isSelected;
    final isWrong = _gameState!.isAnswered && !_gameState!.isCorrect && option == _gameState!.currentCountry!.name;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (_gameState!.isAnswered) {
      if (isCorrect) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
        borderColor = Colors.green;
      } else if (isWrong) {
        backgroundColor = Colors.red;
        textColor = Colors.white;
        borderColor = Colors.red;
      } else {
        backgroundColor = Colors.white.withOpacity(0.1);
        textColor = Colors.white.withOpacity(0.7);
        borderColor = Colors.white.withOpacity(0.3);
      }
    } else {
      backgroundColor = Colors.white.withOpacity(0.1);
      textColor = Colors.white;
      borderColor = Colors.white.withOpacity(0.3);
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: _gameState!.isAnswered ? null : () => _answerQuestion(option),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: borderColor, width: 2),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
} 