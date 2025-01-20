import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intro_views_flutter/src/helpers/constants.dart';
import 'package:intro_views_flutter/src/models/slide_update_model.dart';

/// This class provides the animation controller
/// used when then user stops dragging and page
/// reveal is not completed.
class AnimatedPageDragger {
  AnimatedPageDragger({
    required this.slideDirection,
    required this.transitionGoal,
    required double slidePercent,
    required StreamController<SlideUpdate> slideUpdateStream,
    required TickerProvider vsync,
    this.autoSlideDuration = const Duration(seconds: 3),
  }) {
    final startSlidePercent = slidePercent;
    double endSlidePercent;
    Duration duration;

    // We have to complete the page reveal
    if (transitionGoal == TransitionGoal.open) {
      endSlidePercent = 1.0;

      final slideRemaining = 1.0 - slidePercent;
      // Standard value take for drag velocity to avoid complex calculations.
      duration = Duration(
          milliseconds: (slideRemaining / PERCENT_PER_MILLISECOND).round());
    }
    // We have to close the page reveal
    else {
      endSlidePercent = 0.0;

      duration = Duration(
          milliseconds: (slidePercent / PERCENT_PER_MILLISECOND).round());
    }

    // Adding listener to animation controller
    // Also value to animation controller vary from 0.0 to 1.0 according to duration.
    completionAnimationController = AnimationController(
        duration: duration, vsync: vsync)
      ..addListener(() {
        final slidePercent = lerpDouble(startSlidePercent, endSlidePercent,
                completionAnimationController.value) ??
            0.0;

        // Adding to slide update stream
        slideUpdateStream.add(
            SlideUpdate(slideDirection, slidePercent, UpdateType.animating));
      })
      ..addStatusListener((AnimationStatus status) {
        // When animation has done executing
        if (status == AnimationStatus.completed) {
          // Adding to slide update stream
          slideUpdateStream.add(SlideUpdate(
              slideDirection, slidePercent, UpdateType.doneAnimating));

          // Start auto-slide timer after animation completes
          if (_autoSlideEnabled) {
            _startAutoSlideTimer();
          }
        }
      });
  }

  final SlideDirection slideDirection;

  /// This variable tells that whether we have to open or close the page reveal.
  final TransitionGoal transitionGoal;

  /// Animation controller.
  late AnimationController completionAnimationController;

  final Duration autoSlideDuration;

  // Add new fields for auto-slide functionality
  Timer? _autoSlideTimer;
  bool _autoSlideEnabled = false;

  /// This method is used to run animation controller.
  void run() {
    completionAnimationController.forward(from: 0.0);
  }

  // Add new methods for auto-slide control
  void startAutoSlide() {
    _autoSlideEnabled = true;
    _startAutoSlideTimer();
  }

  void stopAutoSlide() {
    _autoSlideEnabled = false;
    _autoSlideTimer?.cancel();
  }

  void _startAutoSlideTimer() {
    _autoSlideTimer?.cancel();
    _autoSlideTimer = Timer(autoSlideDuration, () {
      if (_autoSlideEnabled) {
        run();
      }
    });
  }

  /// This method is used to dispose animation controller.
  void dispose() {
    _autoSlideTimer?.cancel();
    completionAnimationController.dispose();
  }
}
