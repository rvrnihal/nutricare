/// Premium Page Route Transitions
/// Advanced animations for navigating between screens

import 'package:flutter/material.dart';
import 'premium_animations.dart';

/// Fade Page Transition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  FadePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

/// Slide Page Transition (from right)
class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final SlideDirection direction;

  SlidePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
    this.direction = SlideDirection.right,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offset = _getOffset(direction);
      return SlideTransition(
        position: animation.drive(
          Tween<Offset>(begin: offset, end: Offset.zero)
              .chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: child,
      );
    },
  );

  static Offset _getOffset(SlideDirection direction) {
    switch (direction) {
      case SlideDirection.up:
        return const Offset(0, 1);
      case SlideDirection.down:
        return const Offset(0, -1);
      case SlideDirection.left:
        return const Offset(1, 0);
      case SlideDirection.right:
        return const Offset(-1, 0);
    }
  }
}

/// Scale Page Transition
class ScalePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  ScalePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: animation.drive(
          Tween<double>(begin: 0.8, end: 1.0)
              .chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

/// Rotation Page Transition
class RotatePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  RotatePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return RotationTransition(
        turns: animation.drive(
          Tween<double>(begin: 0, end: 0.1)
              .chain(CurveTween(curve: Curves.easeOut)),
        ),
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0.5, end: 1.0)
                .chain(CurveTween(curve: Curves.easeOut)),
          ),
          child: FadeTransition(opacity: animation, child: child),
        ),
      );
    },
  );
}

/// Bounce Page Transition
class BouncePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  BouncePageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 600),
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: animation.drive(
          Tween<double>(begin: 0.7, end: 1.0)
              .chain(CurveTween(curve: Curves.elasticOut)),
        ),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}

/// Blur Page Transition
class BlurPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;

  BlurPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 400),
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0.95, end: 1.0),
          ),
          child: child,
        ),
      );
    },
  );
}

/// Shared Axis Transition (Material Design)
class SharedAxisPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Duration duration;
  final SharedAxisTransitionType transitionType;

  SharedAxisPageRoute({
    required this.page,
    this.duration = const Duration(milliseconds: 500),
    this.transitionType = SharedAxisTransitionType.horizontal,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return _buildSharedAxisTransition(
        context,
        animation,
        secondaryAnimation,
        child,
        transitionType,
      );
    },
  );

  static Widget _buildSharedAxisTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
    SharedAxisTransitionType transitionType,
  ) {
    switch (transitionType) {
      case SharedAxisTransitionType.horizontal:
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case SharedAxisTransitionType.vertical:
        return SlideTransition(
          position: animation.drive(
            Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      case SharedAxisTransitionType.scaled:
        return ScaleTransition(
          scale: animation.drive(
            Tween<double>(begin: 0.8, end: 1.0)
                .chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
    }
  }
}

enum SharedAxisTransitionType { horizontal, vertical, scaled }

/// Navigation with Premium Transitions Helper
class PremiumNavigation {
  /// Navigate with Fade transition
  static Future<T?> toWithFade<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Navigator.of(context).push(
      FadePageRoute<T>(page: page, duration: duration),
    );
  }

  /// Navigate with Slide transition
  static Future<T?> toWithSlide<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
    SlideDirection direction = SlideDirection.right,
  }) {
    return Navigator.of(context).push(
      SlidePageRoute<T>(page: page, duration: duration, direction: direction),
    );
  }

  /// Navigate with Scale transition
  static Future<T?> toWithScale<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Navigator.of(context).push(
      ScalePageRoute<T>(page: page, duration: duration),
    );
  }

  /// Navigate with Rotate transition
  static Future<T?> toWithRotate<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 500),
  }) {
    return Navigator.of(context).push(
      RotatePageRoute<T>(page: page, duration: duration),
    );
  }

  /// Navigate with Bounce transition
  static Future<T?> toWithBounce<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return Navigator.of(context).push(
      BouncePageRoute<T>(page: page, duration: duration),
    );
  }

  /// Navigate with Shared Axis transition
  static Future<T?> toWithSharedAxis<T>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 500),
    SharedAxisTransitionType transitionType = SharedAxisTransitionType.horizontal,
  }) {
    return Navigator.of(context).push(
      SharedAxisPageRoute<T>(
        page: page,
        duration: duration,
        transitionType: transitionType,
      ),
    );
  }

  /// Replace with transition
  static Future<T?> replaceWith<T, TO>({
    required BuildContext context,
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
    TransitionType transitionType = TransitionType.fade,
  }) {
    return Navigator.of(context).pushReplacement(
      _getRouteByType<T>(
        page,
        duration,
        transitionType,
      ),
    );
  }

  static PageRoute<T> _getRouteByType<T>(
    Widget page,
    Duration duration,
    TransitionType type,
  ) {
    switch (type) {
      case TransitionType.fade:
        return FadePageRoute<T>(page: page, duration: duration);
      case TransitionType.slide:
        return SlidePageRoute<T>(page: page, duration: duration);
      case TransitionType.scale:
        return ScalePageRoute<T>(page: page, duration: duration);
      case TransitionType.rotate:
        return RotatePageRoute<T>(page: page, duration: duration);
      case TransitionType.bounce:
        return BouncePageRoute<T>(page: page, duration: duration);
    }
  }
}

enum TransitionType { fade, slide, scale, rotate, bounce }
