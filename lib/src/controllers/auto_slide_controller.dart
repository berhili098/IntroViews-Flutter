import 'package:flutter/material.dart';

class AutoSlideController extends ChangeNotifier {
  bool _isAutoSliding = false;
  Duration _slideDuration;

  AutoSlideController({Duration slideDuration = const Duration(seconds: 3)})
      : _slideDuration = slideDuration;

  bool get isAutoSliding => _isAutoSliding;
  Duration get slideDuration => _slideDuration;

  void startAutoSlide() {
    _isAutoSliding = true;
    notifyListeners();
  }

  void stopAutoSlide() {
    _isAutoSliding = false;
    notifyListeners();
  }

  void setSlideDuration(Duration duration) {
    _slideDuration = duration;
    notifyListeners();
  }

  void toggleAutoSlide() {
    _isAutoSliding = !_isAutoSliding;
    notifyListeners();
  }
}
