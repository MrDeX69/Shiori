import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// Global bouncing scroll physics for a premium, elastic feel.
class ShioriScrollBehavior extends MaterialScrollBehavior {
  const ShioriScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
  }
}
