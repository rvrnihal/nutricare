/// Animated Widget Variants with Premium Animations
/// Enhanced versions of premium components with built-in animations

import 'package:flutter/material.dart';
import '../core/design/premium_colors.dart';
import '../core/design/premium_typography.dart';
import '../../widgets/premium_glass_card.dart';
import '../../widgets/premium_stats_card.dart';
import '../core/animations/premium_animations.dart';

/// Animated Glass Card with Entrance Animation
class AnimatedGlassCard extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final AnimationType animationType;
  final double blur;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final VoidCallback? onTap;
  final double borderRadius;

  const AnimatedGlassCard({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.animationType = AnimationType.fadeWithSlide,
    this.blur = 20,
    this.padding = const EdgeInsets.all(20),
    this.margin = const EdgeInsets.all(0),
    this.onTap,
    this.borderRadius = 24,
  }) : super(key: key);

  @override
  State<AnimatedGlassCard> createState() => _AnimatedGlassCardState();
}

class _AnimatedGlassCardState extends State<AnimatedGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = PremiumGlassCard(
      blur: widget.blur,
      padding: widget.padding,
      margin: widget.margin,
      onTap: widget.onTap,
      borderRadius: widget.borderRadius,
      child: widget.child,
    );

    switch (widget.animationType) {
      case AnimationType.fade:
        return FadeTransition(opacity: _fadeAnimation, child: content);

      case AnimationType.slide:
        return SlideTransition(position: _slideAnimation, child: content);

      case AnimationType.scale:
        return ScaleTransition(scale: _scaleAnimation, child: content);

      case AnimationType.fadeWithSlide:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(position: _slideAnimation, child: content),
        );

      case AnimationType.fadeWithScale:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: content),
        );

      case AnimationType.slideWithScale:
        return SlideTransition(
          position: _slideAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: content),
        );

      case AnimationType.all:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(scale: _scaleAnimation, child: content),
          ),
        );
    }
  }
}

enum AnimationType {
  fade,
  slide,
  scale,
  fadeWithSlide,
  fadeWithScale,
  slideWithScale,
  all,
}

/// Animated Stats Card with Entrance Animation
class AnimatedStatsCard extends StatefulWidget {
  final String title;
  final String value;
  final String? unit;
  final String? subtitle;
  final Color accentColor;
  final Widget? icon;
  final double? progressValue;
  final Duration duration;
  final AnimationType animationType;
  final bool showTrend;
  final double? trendValue;
  final String? trendLabel;
  final VoidCallback? onTap;

  const AnimatedStatsCard({
    Key? key,
    required this.title,
    required this.value,
    this.unit,
    this.subtitle,
    required this.accentColor,
    this.icon,
    this.progressValue,
    this.duration = const Duration(milliseconds: 600),
    this.animationType = AnimationType.fadeWithScale,
    this.showTrend = false,
    this.trendValue,
    this.trendLabel,
    this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedStatsCard> createState() => _AnimatedStatsCardState();
}

class _AnimatedStatsCardState extends State<AnimatedStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _progressAnimation = Tween<double>(begin: 0, end: widget.progressValue ?? 0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = PremiumStatsCard(
      title: widget.title,
      value: widget.value,
      unit: widget.unit,
      subtitle: widget.subtitle,
      accentColor: widget.accentColor,
      icon: widget.icon,
      progressValue: widget.progressValue != null
          ? _progressAnimation.value
          : null,
      isAnimated: false,
      showTrend: widget.showTrend,
      trendValue: widget.trendValue,
      trendLabel: widget.trendLabel,
      onTap: widget.onTap,
    );

    switch (widget.animationType) {
      case AnimationType.fade:
        return FadeTransition(opacity: _fadeAnimation, child: content);

      case AnimationType.scale:
        return ScaleTransition(scale: _scaleAnimation, child: content);

      case AnimationType.fadeWithScale:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: content),
        );

      default:
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(scale: _scaleAnimation, child: content),
        );
    }
  }
}

/// Staggered List of Animated Cards
class StaggeredCardsList extends StatefulWidget {
  final List<CardData> cards;
  final Duration staggerDelay;
  final Duration cardDuration;
  final AnimationType animationType;

  const StaggeredCardsList({
    Key? key,
    required this.cards,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.cardDuration = const Duration(milliseconds: 500),
    this.animationType = AnimationType.fadeWithSlide,
  }) : super(key: key);

  @override
  State<StaggeredCardsList> createState() => _StaggeredCardsListState();
}

class _StaggeredCardsListState extends State<StaggeredCardsList>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;
  late List<Animation<double>> _scaleAnimations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      widget.cards.length,
      (index) => AnimationController(duration: widget.cardDuration, vsync: this),
    );

    _fadeAnimations = _controllers
        .map((c) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOut),
            ))
        .toList();

    _slideAnimations = _controllers
        .map((c) => Tween<Offset>(begin: const Offset(0, 20), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    _scaleAnimations = _controllers
        .map((c) => Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: c, curve: Curves.easeOut),
            ))
        .toList();

    _startStaggeredAnimations();
  }

  void _startStaggeredAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(
        widget.staggerDelay * i,
        () {
          if (mounted) {
            _controllers[i].forward();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildAnimatedCard(int index) {
    final card = widget.cards[index];

    Widget content = PremiumGlassCard(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(vertical: 8),
      onTap: card.onTap,
      child: card.child,
    );

    switch (widget.animationType) {
      case AnimationType.fade:
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: content,
        );

      case AnimationType.slide:
        return SlideTransition(
          position: _slideAnimations[index],
          child: content,
        );

      case AnimationType.scale:
        return ScaleTransition(
          scale: _scaleAnimations[index],
          child: content,
        );

      case AnimationType.fadeWithSlide:
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: SlideTransition(
            position: _slideAnimations[index],
            child: content,
          ),
        );

      case AnimationType.fadeWithScale:
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: ScaleTransition(
            scale: _scaleAnimations[index],
            child: content,
          ),
        );

      case AnimationType.slideWithScale:
        return SlideTransition(
          position: _slideAnimations[index],
          child: ScaleTransition(
            scale: _scaleAnimations[index],
            child: content,
          ),
        );

      case AnimationType.all:
        return FadeTransition(
          opacity: _fadeAnimations[index],
          child: SlideTransition(
            position: _slideAnimations[index],
            child: ScaleTransition(
              scale: _scaleAnimations[index],
              child: content,
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.cards.length,
      itemBuilder: (context, index) => _buildAnimatedCard(index),
    );
  }
}

class CardData {
  final Widget child;
  final VoidCallback? onTap;

  CardData({required this.child, this.onTap});
}

/// Animated Progress Indicator
class AnimatedProgressIndicator extends StatefulWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;
  final double height;
  final Duration animationDuration;

  const AnimatedProgressIndicator({
    Key? key,
    required this.value,
    this.backgroundColor = const Color(0xFF1A1F2E),
    this.valueColor = const Color(0xFF76FF03),
    this.height = 8,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : super(key: key);

  @override
  State<AnimatedProgressIndicator> createState() =>
      _AnimatedProgressIndicatorState();
}

class _AnimatedProgressIndicatorState extends State<AnimatedProgressIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.forward();
  }

  @override
  void didUpdateWidget(AnimatedProgressIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _animation = Tween<double>(begin: _animation.value, end: widget.value)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _animation.value,
            minHeight: widget.height,
            backgroundColor: widget.backgroundColor,
            valueColor: AlwaysStoppedAnimation(widget.valueColor),
          ),
        );
      },
    );
  }
}
