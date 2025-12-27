// lib/ui/widgets/animated/animated_score.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';

class AnimatedScore extends StatefulWidget {
  final int score;
  final int? previousScore;
  final TextStyle? style;

  const AnimatedScore({
    super.key,
    required this.score,
    this.previousScore,
    this.style,
  });

  @override
  State<AnimatedScore> createState() => _AnimatedScoreState();
}

class _AnimatedScoreState extends State<AnimatedScore> {
  late int _displayScore;

  @override
  void initState() {
    super.initState();
    _displayScore = widget.previousScore ?? widget.score;
  }

  @override
  void didUpdateWidget(AnimatedScore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      setState(() {
        _displayScore = widget.score;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreDiff = widget.score - (widget.previousScore ?? widget.score);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(
            begin: widget.previousScore ?? widget.score,
            end: widget.score,
          ),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) {
            return Text(
              value.toString(),
              style: widget.style ??
                  const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
            );
          },
        ),
        if (scoreDiff != 0)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: scoreDiff > 0
                    ? AppColors.success.withOpacity(0.2)
                    : AppColors.error.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${scoreDiff > 0 ? '+' : ''}$scoreDiff',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: scoreDiff > 0 ? AppColors.success : AppColors.error,
                ),
              ),
            )
                .animate()
                .fadeIn(duration: const Duration(milliseconds: 300))
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                ),
          ),
      ],
    );
  }
}
