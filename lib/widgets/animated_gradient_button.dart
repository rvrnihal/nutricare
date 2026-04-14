/// Animated Gradient Button - Premium Interactive Component
/// Advanced button with gradient, animation, and haptic feedback

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/design/premium_colors.dart';
import '../core/design/premium_typography.dart';

class AnimatedGradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final bool isLoading;
  final double borderRadius;
  final EdgeInsets padding;
  final TextStyle? textStyle;
  final Widget? icon;
  final bool isAnimated;
  final double width;
  final bool fullWidth;
  final VoidCallback? onLongPress;
  final bool hapticFeedback;

  const AnimatedGradientButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.gradient,
    this.isLoading = false,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
    this.textStyle,
    this.icon,
    this.isAnimated = true,
    this.width = double.infinity,
    this.fullWidth = false,
    this.onLongPress,
    this.hapticFeedback = true,
  }) : super(key: key);

  @override
  State<AnimatedGradientButton> createState() => _AnimatedGradientButtonState();
}

class _AnimatedGradientButtonState extends State<AnimatedGradientButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.isAnimated) {
      _animationController = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      );
      _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
      _shadowAnimation = Tween<double>(begin: 0.4, end: 0.2).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    if (widget.isAnimated) {
      _animationController.dispose();
    }
    super.dispose();
  }

  void _onTapDown(_) {
    if (widget.isAnimated) {
      _animationController.forward();
      if (widget.hapticFeedback) {
        HapticFeedback.lightImpact();
      }
    }
  }

  void _onTapUp(_) {
    if (widget.isAnimated) {
      _animationController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gradient = widget.gradient ?? PremiumColors.primaryGradient;

    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      spacing: widget.icon != null ? 8 : 0,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null && !widget.isLoading) widget.icon!,
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: const AlwaysStoppedAnimation(
                PremiumColors.textPrimary,
              ),
            ),
          )
        else
          Text(
            widget.label,
            style: widget.textStyle ??
                PremiumTypography.labelLarge.copyWith(
                  color: PremiumColors.darkLuxury,
                  fontWeight: FontWeight.w700,
                ),
          ),
      ],
    );

    if (widget.isAnimated) {
      buttonContent = ScaleTransition(scale: _scaleAnimation, child: buttonContent);
    }

    Widget button = GestureDetector(
      onTapDown: widget.isLoading ? null : _onTapDown,
      onTapUp: widget.isLoading ? null : _onTapUp,
      onTapCancel: () {
        if (widget.isAnimated) {
          _animationController.reverse();
        }
      },
      onTap: widget.isLoading ? null : widget.onPressed,
      onLongPress: widget.onLongPress,
      child: widget.isAnimated
          ? AnimatedBuilder(
              animation: _shadowAnimation,
              builder: (context, _) => Container(
                width: widget.fullWidth ? double.infinity : null,
                padding: widget.padding,
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  boxShadow: [
                    BoxShadow(
                      color: PremiumColors.primaryNeon.withOpacity(_shadowAnimation.value),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: buttonContent,
              ),
            )
          : Container(
              width: widget.fullWidth ? double.infinity : null,
              padding: widget.padding,
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                boxShadow: [
                  BoxShadow(
                    color: PremiumColors.primaryNeon.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: buttonContent,
            ),
    );

    if (!widget.fullWidth) {
      return button;
    }

    return SizedBox(
      width: widget.width,
      child: button,
    );
  }
}
