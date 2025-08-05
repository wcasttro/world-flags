import 'package:flutter/material.dart';
import '../models/country_hint.dart';
import '../models/language.dart';
import '../services/ui_translation_service.dart';

class HintWidget extends StatelessWidget {
  final CountryHint hint;
  final Language selectedLanguage;
  final VoidCallback? onClose;

  const HintWidget({
    super.key,
    required this.hint,
    required this.selectedLanguage,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
                UITranslationService.translate('hint_title', selectedLanguage),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange[600],
                    ),
              ),
              const Spacer(),
              if (onClose != null)
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  iconSize: 20,
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Informações da dica
          _buildHintInfo(
            context,
            Icons.public,
            UITranslationService.translate('continent_label', selectedLanguage),
            hint.continent,
          ),

          const SizedBox(height: 8),

          _buildHintInfo(
            context,
            Icons.language,
            UITranslationService.translate('languages_label', selectedLanguage),
            hint.getFormattedLanguages(),
          ),

          const SizedBox(height: 8),

          _buildHintInfo(
            context,
            Icons.location_city,
            UITranslationService.translate('capital_label', selectedLanguage),
            hint.capital,
          ),

          const SizedBox(height: 8),

          _buildHintInfo(
            context,
            Icons.people,
            UITranslationService.translate(
                'population_label', selectedLanguage),
            hint.getFormattedPopulation(),
          ),

          const SizedBox(height: 8),

          _buildHintInfo(
            context,
            Icons.attach_money,
            UITranslationService.translate('currency_label', selectedLanguage),
            hint.currency,
          ),
        ],
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
