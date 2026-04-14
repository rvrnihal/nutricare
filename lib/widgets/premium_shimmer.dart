/// Premium Shimmer Loading Effect
/// Advanced skeleton/placeholder with smooth shimmer animation

import 'package:flutter/material.dart';
import '../core/design/premium_colors.dart';

class PremiumShimmer extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool enabled;

  const PremiumShimmer({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  }) : super(key: key);

  @override
  State<PremiumShimmer> createState() => _PremiumShimmerState();
}

class _PremiumShimmerState extends State<PremiumShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    if (widget.enabled) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(PremiumShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_animationController.isAnimating) {
      _animationController.repeat();
    } else if (!widget.enabled && _animationController.isAnimating) {
      _animationController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 - 2.0 * _animationController.value, 0),
              end: Alignment(1.0 - 2.0 * _animationController.value, 0),
              colors: [
                PremiumColors.darkLuxuryLighter,
                PremiumColors.darkLuxuryLighter.withOpacity(0.3),
                PremiumColors.darkLuxuryLighter.withOpacity(0.8),
                PremiumColors.darkLuxuryLighter.withOpacity(0.3),
                PremiumColors.darkLuxuryLighter,
              ],
              stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// Premium Skeleton/Placeholder Card
class PremiumShimmerCard extends StatelessWidget {
  final EdgeInsets padding;
  final EdgeInsets margin;
  final double borderRadius;
  final double? height;
  final double? width;
  final bool isCircle;

  const PremiumShimmerCard({
    Key? key,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = 24,
    this.height,
    this.width,
    this.isCircle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      height: height ?? 100,
      width: width,
      decoration: BoxDecoration(
        color: PremiumColors.darkLuxuryLighter,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
      ),
      child: PremiumShimmer(
        child: Container(
          color: PremiumColors.darkLuxuryLighter,
        ),
      ),
    );
  }
}

/// Premium Skeleton Lines (for text placeholder)
class PremiumShimmerLine extends StatelessWidget {
  final double width;
  final double height;
  final EdgeInsets margin;
  final double borderRadius;

  const PremiumShimmerLine({
    Key? key,
    this.width = double.infinity,
    this.height = 16,
    this.margin = const EdgeInsets.symmetric(vertical: 4),
    this.borderRadius = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: PremiumColors.darkLuxuryLighter,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: PremiumShimmer(
        child: Container(
          color: PremiumColors.darkLuxuryLighter,
        ),
      ),
    );
  }
}
