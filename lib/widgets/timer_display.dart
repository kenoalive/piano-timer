import 'package:flutter/material.dart';
import '../utils/utils.dart';

class TimerDisplay extends StatelessWidget {
  final int seconds;
  final bool isLarge;

  const TimerDisplay({
    super.key,
    required this.seconds,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        formatDuration(seconds),
        style: TextStyle(
          fontSize: isLarge ? 58 : 38,
          fontWeight: FontWeight.w300,
          fontFamily: 'monospace',
          letterSpacing: 3,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
