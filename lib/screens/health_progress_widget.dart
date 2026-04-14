import 'package:flutter/material.dart';

class HealthProgress extends StatelessWidget {
  final int progress;
  const HealthProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress / 100),
      duration: const Duration(seconds: 1),
      builder: (context, value, _) {
        return SizedBox(
          height: 120,
          width: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 10,
                color: Colors.deepPurple,
                backgroundColor: Colors.grey.shade300,
              ),
              Text(
                "${(value * 100).toInt()}%",
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
          