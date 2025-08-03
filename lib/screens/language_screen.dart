import 'package:flutter/material.dart';
import '../models/language.dart';
import '../services/language_service.dart';
import 'home_screen.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  Language? _selectedLanguage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentLanguage();
  }

  Future<void> _loadCurrentLanguage() async {
    final currentLanguage = await LanguageService.getSelectedLanguage();
    setState(() {
      _selectedLanguage = currentLanguage;
      _isLoading = false;
    });
  }

  Future<void> _selectLanguage(Language language) async {
    setState(() {
      _selectedLanguage = language;
    });

    await LanguageService.setSelectedLanguage(language);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecionar Idioma'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
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
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        'Escolha o idioma para os nomes dos países:',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      Text(
                        'Os nomes dos países aparecerão no idioma selecionado',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Lista de idiomas
                      Expanded(
                        child: ListView.builder(
                          itemCount: Language.availableLanguages.length,
                          itemBuilder: (context, index) {
                            final language = Language.availableLanguages[index];
                            final isSelected = _selectedLanguage?.code == language.code;
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ElevatedButton(
                                onPressed: () => _selectLanguage(language),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isSelected
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.white.withOpacity(0.1),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.white.withOpacity(0.3),
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                    horizontal: 20,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    if (isSelected) const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            language.nativeName,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (language.nativeName != language.name)
                                            Text(
                                              language.name,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white.withOpacity(0.7),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        language.code.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Botão para voltar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Voltar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
} 