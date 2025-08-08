import 'package:flutter/material.dart';

import '../models/language.dart';
import '../services/language_service.dart';
import '../services/ui_translation_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Language? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    final language = await LanguageService.getSelectedLanguage();
    setState(() {
      _selectedLanguage = language;
    });
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
        title: Text(
          UITranslationService.translate('about_title', _selectedLanguage!),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo e título do app
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.flag,
                          size: 80,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'World Flags Quiz',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Version 1.0.0',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Descrição do app
                _buildInfoSection(
                  context,
                  Icons.info_outline,
                  UITranslationService.translate(
                      'about_section_title', _selectedLanguage!),
                  UITranslationService.translate(
                      'about_section_description', _selectedLanguage!),
                ),

                const SizedBox(height: 24),

                // Recursos
                _buildInfoSection(
                  context,
                  Icons.star,
                  UITranslationService.translate(
                      'features_section_title', _selectedLanguage!),
                  UITranslationService.translate(
                      'features_section_description', _selectedLanguage!),
                ),

                const SizedBox(height: 24),

                // Como jogar
                _buildInfoSection(
                  context,
                  Icons.play_circle_outline,
                  UITranslationService.translate(
                      'how_to_play_section_title', _selectedLanguage!),
                  UITranslationService.translate(
                      'how_to_play_section_description', _selectedLanguage!),
                ),

                const SizedBox(height: 24),

                // Estatísticas
                _buildInfoSection(
                  context,
                  Icons.analytics,
                  UITranslationService.translate(
                      'app_stats_section_title', _selectedLanguage!),
                  UITranslationService.translate(
                      'app_stats_section_description', _selectedLanguage!),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(
    BuildContext context,
    IconData icon,
    String title,
    String content,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
