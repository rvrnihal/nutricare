/// Advanced Animation System for NutriCare+ v2.0
/// Professional animations with smooth transitions and micro-interactions

import 'package:flutter/material.dart';

/// Premium Animation Durations
class AnimationDurations {
  // Short animations for micro-interactions
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration short = Duration(milliseconds: 300);
  
  // Standard animations for UI elements
  static const Duration standard = Duration(milliseconds: 400);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration long = Duration(milliseconds: 600);
  
  // Page transitions
  static const Duration pageTransition = Duration(milliseconds: 500);
  static const Duration slowPageTransition = Duration(milliseconds: 800);
}

/// Premium Animation Curve Presets
class AnimationCurves {
  // Standard curves
  static const Curve easeIn = Curves.easeIn;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeInOut = Curves.easeInOut;
  
  // Premium curves
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve soft = Curves.easeOutQuad;
  
  // Fast/responsive
  static const Curve snappy = Curves.easeOutQuint;
  static const Curve sharp = Curves.easeInQuart;
  
  // Slow/graceful
  static const Curve graceful = Curves.easeInOutCubic;
  static const Curve elegant = Curves.easeInOutQuart;
}

/// Fade In Animation
class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final bool autoStart;

  const FadeInAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );
    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

/// Slide In Animation
class SlideInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final SlideDirection direction;
  final bool autoStart;

  const SlideInAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    this.curve = Curves.easeOut,
    this.direction = SlideDirection.up,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<SlideInAnimation> createState() => _SlideInAnimationState();
}

class _SlideInAnimationState extends State<SlideInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    final offset = _getOffset(widget.direction);
    _animation = Tween<Offset>(begin: offset, end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  Offset _getOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.up:
        return const Offset(0, 0.5);
      case SlideDirection.down:
        return const Offset(0, -0.5);
      case SlideDirection.left:
        return const Offset(-0.5, 0);
      case SlideDirection.right:
        return const Offset(0.5, 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}

enum SlideDirection { up, down, left, right }

/// Scale In Animation
class ScaleInAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final double startScale;
  final bool autoStart;

  const ScaleInAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeOut,
    this.startScale = 0.8,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<ScaleInAnimation> createState() => _ScaleInAnimationState();
}

class _ScaleInAnimationState extends State<ScaleInAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _scaleAnimation = Tween<double>(begin: widget.startScale, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.autoStart) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}

/// Rotation Animation
class RotateAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double rotationAmount;
  final bool isInfinite;
  final bool autoStart;

  const RotateAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.rotationAmount = 1.0,
    this.isInfinite = false,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<RotateAnimation> createState() => _RotateAnimationState();
}

class _RotateAnimationState extends State<RotateAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(begin: 0, end: widget.rotationAmount).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );

    if (widget.autoStart) {
      if (widget.isInfinite) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(turns: _animation, child: widget.child);
  }
}

/// Bounce Animation
class BounceAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double bounceHeight;
  final bool isInfinite;
  final bool autoStart;

  const BounceAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 600),
    this.bounceHeight = 20,
    this.isInfinite = false,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(0, -widget.bounceHeight / 100),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    if (widget.autoStart) {
      if (widget.isInfinite) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(position: _animation, child: widget.child);
  }
}

/// Pulse Animation
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minOpacity;
  final bool autoStart;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.minOpacity = 0.5,
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(begin: 1.0, end: widget.minOpacity).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.autoStart) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(opacity: _animation, child: widget.child);
  }
}

/// Staggered Animation (for multiple children)
class StaggeredAnimation extends StatefulWidget {
  final List<Widget> children;
  final Duration staggerDelay;
  final Duration childDuration;
  final bool autoStart;

  const StaggeredAnimation({
    Key? key,
    required this.children,
    this.staggerDelay = const Duration(milliseconds: 100),
    this.childDuration = const Duration(milliseconds: 400),
    this.autoStart = true,
  }) : super(key: key);

  @override
  State<StaggeredAnimation> createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<StaggeredAnimation>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(duration: widget.childDuration, vsync: this),
    );

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeOut),
            ))
        .toList();

    if (widget.autoStart) {
      _startAnimations();
    }
  }

  void _startAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(
        widget.staggerDelay * i,
        () => _controllers[i].forward(),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        widget.children.length,
        (index) => FadeTransition(
          opacity: _animations[index],
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
                .animate(_animations[index]),
            child: widget.children[index],
          ),
        ),
      ),
    );
  }
}

/// Animated Container with Premium Transitions
class PremiumAnimatedContainer extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxShadow? boxShadow;
  final Duration duration;
  final Curve curve;

  const PremiumAnimatedContainer({
    Key? key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.boxShadow,
    this.duration = const Duration(milliseconds: 400),
    this.curve = Curves.easeInOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: duration,
      curve: curve,
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius,
        boxShadow: boxShadow != null ? [boxShadow!] : null,
      ),
      child: child,
    );
  }
}

/// Animated Visibility with Premium Transitions
class PremiumAnimatedVisibility extends StatelessWidget {
  final Widget child;
  final bool visible;
  final Duration enterDuration;
  final Duration exitDuration;
  final Curve curve;
  final AnimationType type;

  const PremiumAnimatedVisibility({
    Key? key,
    required this.child,
    required this.visible,
    this.enterDuration = const Duration(milliseconds: 400),
    this.exitDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.type = AnimationType.fade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (type == AnimationType.fade) {
      return AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: visible ? enterDuration : exitDuration,
        curve: curve,
        child: child,
      );
    } else if (type == AnimationType.scale) {
      return ScaleTransition(
        scale: AlwaysStoppedAnimation(visible ? 1.0 : 0.0),
        child: child,
      );
    } else {
      return SlideTransition(
        position: AlwaysStoppedAnimation(visible ? Offset.zero : const Offset(0, 0.2)),
        child: child,
      );
    }
  }
}

enum AnimationType { fade, scale, slide }

/// Animation Utility Builder
class PremiumAnimatedValueBuilder extends StatefulWidget {
  final Duration duration;
  final Curve curve;
  final Widget Function(BuildContext context, double value) builder;
  final bool autoStart;
  final bool isInfinite;

  const PremiumAnimatedValueBuilder({
    Key? key,
    required this.duration,
    required this.builder,
    this.curve = Curves.easeInOut,
    this.autoStart = true,
    this.isInfinite = false,
  }) : super(key: key);

  @override
  State<PremiumAnimatedValueBuilder> createState() => _PremiumAnimatedValueBuilderState();
}

class _PremiumAnimatedValueBuilderState extends State<PremiumAnimatedValueBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: widget.curve),
    );

    if (widget.autoStart) {
      if (widget.isInfinite) {
        _controller.repeat();
      } else {
        _controller.forward();
      }
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
      builder: (context, _) => widget.builder(context, _animation.value),
    );
  }
}
