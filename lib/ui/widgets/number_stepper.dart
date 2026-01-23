// lib/ui/widgets/number_stepper.dart
import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class NumberStepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String? label;

  const NumberStepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Decrease button
        Container(
          decoration: BoxDecoration(
            color: value > min
                ? DesignTokens.primaryPurple
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          child: IconButton(
            icon: Icon(
              Icons.remove_rounded,
              color: value > min
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
        ),

        // Value display
        Container(
          margin: const EdgeInsets.symmetric(horizontal: DesignTokens.space12),
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space16,
            vertical: DesignTokens.space12,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          child: Text(
            value.toString(),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),

        // Increase button
        Container(
          decoration: BoxDecoration(
            color: value < max
                ? DesignTokens.primaryPurple
                : Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMedium),
          ),
          child: IconButton(
            icon: Icon(
              Icons.add_rounded,
              color: value < max
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ),
      ],
    );
  }
}
