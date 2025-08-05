import 'package:flutter/material.dart';

import '../models/language.dart';
import '../models/user_error.dart';
import '../services/error_review_service.dart';
import '../services/language_service.dart';
import '../services/ui_translation_service.dart';
import '../widgets/flag_image.dart';

class ErrorReviewScreen extends StatefulWidget {
  const ErrorReviewScreen({super.key});

  @override
  State<ErrorReviewScreen> createState() => _ErrorReviewScreenState();
}

class _ErrorReviewScreenState extends State<ErrorReviewScreen> {
  List<UserError> _errors = [];
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  Language? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadErrors();
  }

  Future<void> _loadErrors() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final language = await LanguageService.getSelectedLanguage();
      final errors = await ErrorReviewService.loadErrors();
      final stats = await ErrorReviewService.getErrorStats();

      setState(() {
        _selectedLanguage = language;
        _errors = errors;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearErrors() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(UITranslationService.translate(
            'clear_errors_title', _selectedLanguage!)),
        content: Text(UITranslationService.translate(
            'clear_errors_message', _selectedLanguage!)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
                UITranslationService.translate('cancel', _selectedLanguage!)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
                UITranslationService.translate('clear', _selectedLanguage!)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ErrorReviewService.clearErrors();
      _loadErrors();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(UITranslationService.translate('error_review_title',
              _selectedLanguage ?? Language.availableLanguages[1])),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(UITranslationService.translate(
            'error_review_title', _selectedLanguage!)),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          if (_errors.isNotEmpty)
            IconButton(
              onPressed: _clearErrors,
              icon: const Icon(Icons.delete_sweep),
              tooltip: UITranslationService.translate(
                  'clear_errors', _selectedLanguage!),
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
        child: _errors.isEmpty ? _buildEmptyState() : _buildErrorList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            UITranslationService.translate(
                'no_errors_title', _selectedLanguage!),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            UITranslationService.translate(
                'no_errors_message', _selectedLanguage!),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorList() {
    return Column(
      children: [
        // Estatísticas
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                '${_stats['totalErrors'] ?? 0}',
                UITranslationService.translate(
                    'total_errors', _selectedLanguage!),
              ),
              _buildStatItem(
                '${_stats['uniqueCountries'] ?? 0}',
                UITranslationService.translate(
                    'unique_countries', _selectedLanguage!),
              ),
            ],
          ),
        ),

        // Lista de erros
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _errors.length,
            itemBuilder: (context, index) {
              final error = _errors[index];
              return _buildErrorCard(error);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
        ),
      ],
    );
  }

  Widget _buildErrorCard(UserError error) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Bandeira
            Container(
              width: 80,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: FlagImage(flagUrl: error.country.flagUrl),
              ),
            ),

            const SizedBox(width: 16),

            // Informações do erro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    error.country.getTranslatedName(_selectedLanguage!),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.red[300],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${UITranslationService.translate('your_answer', _selectedLanguage!)}: ${error.userAnswer}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.red[300],
                                  ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.check,
                        size: 16,
                        color: Colors.green[300],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${UITranslationService.translate('correct_answer', _selectedLanguage!)}: ${error.correctAnswer}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.green[300],
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
