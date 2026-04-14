/// Premium Glass Card Widget - Glassmorphism Effect
/// Advanced UI component with blur, gradient, and shadow effects

import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/design/premium_colors.dart';

class PremiumGlassCard extends StatelessWidget {
  final Widget child;
  final double blur;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final Border? border;
  final double borderRadius;
  final VoidCallback? onTap;
  final double? elevation;
  final BoxShadow? shadow;
  final bool enabled;

  const PremiumGlassCard({
    Key? key,
    required this.child,
    this.blur = 20.0,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(0),
    this.backgroundColor,
    this.border,
    this.borderRadius = 24,
    this.onTap,
    this.elevation = 0,
    this.shadow,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: GestureDetector(
            onTap: enabled ? onTap : null,
            child: Container(
              decoration: BoxDecoration(
                // Gradient glass effect
                gradient: LinearGradient(
                  colors: [
                    backgroundColor ?? PremiumColors.glassLight,
                    (backgroundColor ?? PremiumColors.glassLight).withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(borderRadius),
                border: border ??
                    Border.all(
                      color: PremiumColors.glassMedium,
                      width: 1.5,
                    ),
                boxShadow: shadow != null
                    ? [shadow!]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
              ),
              padding: padding,
              child: Opacity(
                opacity: enabled ? 1.0 : 0.5,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
