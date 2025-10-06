import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_animations.dart';

/// Enhanced page transitions for professional animations
class AppPageTransitions {
  /// Slide transition from right (default forward navigation)
  static Page<T> slideRightTransition<T extends Object?>(
    Widget child, {
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: AppDurations.page,
      reverseTransitionDuration: AppDurations.page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: AppCurves.smooth),
        );
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  /// Slide transition from bottom (modal presentations)
  static Page<T> slideUpTransition<T extends Object?>(
    Widget child, {
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: AppDurations.page,
      reverseTransitionDuration: AppDurations.normal,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: AppCurves.smooth),
        );
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Fade transition (subtle navigation)
  static Page<T> fadeTransition<T extends Object?>(
    Widget child, {
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: AppDurations.normal,
      reverseTransitionDuration: AppDurations.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Scale transition (modal dialogs)
  static Page<T> scaleTransition<T extends Object?>(
    Widget child, {
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: AppDurations.normal,
      reverseTransitionDuration: AppDurations.fast,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(
              parent: animation,
              curve: AppCurves.elasticOut,
            ),
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
    );
  }

  /// Shared axis transition (Material Design 3 style)
  static Page<T> sharedAxisTransition<T extends Object?>(
    Widget child, {
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
      transitionDuration: AppDurations.page,
      reverseTransitionDuration: AppDurations.page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.05),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: AppCurves.smooth,
            )),
            child: child,
          ),
        );
      },
    );
  }

  /// No transition (instant)
  static Page<T> noTransition<T extends Object?>(
    Widget child, {
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return MaterialPage<T>(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      child: child,
    );
  }
}