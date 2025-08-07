import 'package:flutter/material.dart';

import '../services/feedback_service.dart';

class AnimatedOptionButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isCorrect;
  final bool isWrong;
  final bool isAnswered;
  final IconData? feedbackIcon;

  const AnimatedOptionButton({
    super.key,
    required this.text,
    this.onPressed,
    required this.isCorrect,
    required this.isWrong,
    required this.isAnswered,
    this.feedbackIcon,
  });

  @override
  State<AnimatedOptionButton> createState() => _AnimatedOptionButtonState();
}

class _AnimatedOptionButtonState extends State<AnimatedOptionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedOptionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Animar quando a resposta for dada
    if (widget.isAnswered && !oldWidget.isAnswered) {
      if (widget.isCorrect) {
        // Animação de sucesso
        _animationController.forward().then((_) {
          _animationController.reverse();
        });
        // Feedback de sucesso
        FeedbackService.successFeedback();
      } else if (widget.isWrong) {
        // Animação de erro (shake)
        _animationController.forward();
        // Feedback de erro
        FeedbackService.errorFeedback();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (widget.isAnswered) {
      if (widget.isCorrect) {
        backgroundColor = Colors.green;
        textColor = Colors.white;
        borderColor = Colors.green;
      } else if (widget.isWrong) {
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

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        double scale = widget.isCorrect ? _scaleAnimation.value : 1.0;
        double shake = widget.isWrong ? _shakeAnimation.value : 0.0;

        return Transform.scale(
          scale: scale,
          child: Transform.translate(
            offset: Offset(
              shake * 10 * (shake - 0.5) * 2, // Efeito shake
              0,
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              child: ElevatedButton(
                onPressed: widget.isAnswered ? null : widget.onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor,
                  foregroundColor: textColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: borderColor, width: 2),
                  ),
                  elevation:
                      widget.isAnswered && (widget.isCorrect || widget.isWrong)
                          ? 8
                          : 0,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isAnswered &&
                        (widget.isCorrect || widget.isWrong))
                      AnimatedOpacity(
                        opacity: widget.isAnswered ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          widget.feedbackIcon,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    if (widget.isAnswered &&
                        (widget.isCorrect || widget.isWrong))
                      const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
