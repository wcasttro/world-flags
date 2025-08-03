import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/language.dart';
import '../services/language_service.dart';
import '../services/ui_translation_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<MapEntry<int, DateTime>> _scores = [];
  bool _isLoading = true;
  Language? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
    _loadScores();
  }

  Future<void> _loadSelectedLanguage() async {
    final language = await LanguageService.getSelectedLanguage();
    setState(() {
      _selectedLanguage = language;
    });
  }

  Future<void> _loadScores() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scoresList = prefs.getStringList('scores') ?? [];
      
      final scores = <MapEntry<int, DateTime>>[];
      
      for (final scoreString in scoresList) {
        final parts = scoreString.split('_');
        if (parts.length == 2) {
          final score = int.tryParse(parts[0]);
          final timestamp = DateTime.fromMillisecondsSinceEpoch(
            int.tryParse(parts[1]) ?? 0,
          );
          
          if (score != null) {
            scores.add(MapEntry(score, timestamp));
          }
        }
      }
      
      // Ordenar por pontuação (maior primeiro)
      scores.sort((a, b) => b.key.compareTo(a.key));
      
      setState(() {
        _scores = scores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedLanguage == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(UITranslationService.translate('leaderboard_title', _selectedLanguage!)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadScores,
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
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      UITranslationService.translate('loading_message', _selectedLanguage!),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              )
            : _scores.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          UITranslationService.translate('no_scores_message', _selectedLanguage!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jogue algumas partidas para aparecer aqui!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _scores.length,
                    itemBuilder: (context, index) {
                      final score = _scores[index];
                      final isTop3 = index < 3;
                      
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: ListTile(
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: isTop3
                                  ? _getMedalColor(index)
                                  : Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: isTop3
                                  ? Icon(
                                      _getMedalIcon(index),
                                      color: Colors.white,
                                      size: 24,
                                    )
                                  : Text(
                                      '${index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ),
                          title: Text(
                            '${score.key}/10',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Text(
                            _formatDate(score.value),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          trailing: Text(
                            '${(score.key / 10 * 100).toInt()}%',
                            style: TextStyle(
                              color: _getScoreColor(score.key),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Color _getMedalColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Ouro
      case 1:
        return const Color(0xFFC0C0C0); // Prata
      case 2:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return Colors.white.withOpacity(0.2);
    }
  }

  IconData _getMedalIcon(int index) {
    switch (index) {
      case 0:
        return Icons.emoji_events;
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.emoji_events;
      default:
        return Icons.star;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 9) return Colors.green;
    if (score >= 7) return Colors.orange;
    if (score >= 5) return Colors.yellow;
    return Colors.red;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} min atrás';
      }
      return '${difference.inHours} h atrás';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} dias atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
} 