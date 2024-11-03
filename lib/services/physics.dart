import 'package:flutter/material.dart';

class OnlyAllowBackwardScrollPhysics extends ScrollPhysics {
  const OnlyAllowBackwardScrollPhysics({super.parent});

  @override
  OnlyAllowBackwardScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return OnlyAllowBackwardScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // If trying to scroll forward (value > position.pixels), prevent it.
    if (value > position.pixels) {
      return value - position.pixels; // Disallow forward scroll
    }
    // Allow backward scroll
    return 0.0;
  }
}
