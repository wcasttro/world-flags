import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'game_screen.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final int totalQuestions;

  const GameOverScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen> {
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _saveScore();
  }

  Future<void> _saveScore() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final scores = prefs.getStringList('scores') ?? [];
      final newScore = '${widget.score}_${DateTime.now().millisecondsSinceEpoch}';
      scores.add(newScore);
      
      // Manter apenas os 10 melhores scores
      if (scores.length > 10) {
        scores.sort((a, b) {
          final scoreA = int.parse(a.split('_')[0]);
          final scoreB = int.parse(b.split('_')[0]);
          return scoreB.compareTo(scoreA);
        });
        scores.removeRange(10, scores.length);
      }
      
      await prefs.setStringList('scores', scores);
    } catch (e) {
      // Ignorar erros de salvamento
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  double get _percentage => widget.score / widget.totalQuestions;
  String get _message {
    if (_percentage >= 0.9) return 'Excelente! Você é um especialista em bandeiras!';
    if (_percentage >= 0.7) return 'Muito bom! Você conhece bem as bandeiras!';
    if (_percentage >= 0.5) return 'Bom! Continue praticando!';
    if (_percentage >= 0.3) return 'Razoável. Que tal tentar novamente?';
    return 'Continue estudando as bandeiras do mundo!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1E3A8A),
              Color(0xFF3B82F6),
              Color(0xFF60A5FA),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Ícone de resultado
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    _percentage >= 0.7 ? Icons.emoji_events : Icons.flag,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Título
                Text(
                  'Fim de Jogo!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Pontuação
                Text(
                  '${widget.score}/${widget.totalQuestions}',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Porcentagem
                Text(
                  '${(_percentage * 100).toInt()}%',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Mensagem
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    _message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Botões
                _buildActionButton(
                  'Jogar Novamente',
                  Icons.replay,
                  () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GameScreen(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                _buildActionButton(
                  'Menu Principal',
                  Icons.home,
                  () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                    (route) => false,
                  ),
                ),
                
                if (_isSaving) ...[
                  const SizedBox(height: 24),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(String text, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 0,
          side: BorderSide(
            color: Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 