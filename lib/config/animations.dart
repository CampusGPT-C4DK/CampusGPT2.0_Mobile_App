import 'package:flutter/material.dart';

class AnimationDuration {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);
}

class AnimationCurves {
  static const Curve smooth = Curves.easeInOutCubic;
  static const Curve easeIn = Curves.easeInCubic;
  static const Curve easeOut = Curves.easeOutCubic;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.elasticInOut;
}
