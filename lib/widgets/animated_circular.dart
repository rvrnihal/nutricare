import 'package:flutter/material.dart';

class AnimatedCircular extends StatelessWidget {
  final double value;
  final String label;
  final Color color;

  const AnimatedCircular({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(seconds: 1),
      builder: (context, v, _) {
        return Column(
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: v,
                    strokeWidth: 10,
                    color: color,
                    backgroundColor: Colors.grey.shade300,
                  ),
                  Text("${(v * 100).toInt()}%",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        );
      },
    );
  }
}
