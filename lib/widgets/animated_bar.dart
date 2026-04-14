import 'package:flutter/material.dart';

class AnimatedBar extends StatelessWidget {
  final String title;
  final double value;
  final Color color;

  const AnimatedBar({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: value),
          duration: const Duration(seconds: 1),
          builder: (context, v, _) {
            return LinearProgressIndicator(
              value: v,
              minHeight: 10,
              color: color,
              backgroundColor: Colors.grey.shade300,
            );
          },
        ),
      ],
    );
  }
}
