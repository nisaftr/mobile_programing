import 'package:flutter/widgets.dart';

abstract final class Responsive {
  static const double maxContentWidth = 840;
  static const double maxFormWidth = 440;

  static bool isTablet(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 720;

  static int statColumns(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= 600 ? 4 : 2;

  static EdgeInsets pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final horizontal = width >= 720 ? 32.0 : 20.0;
    return EdgeInsets.fromLTRB(horizontal, 16, horizontal, 32);
  }

  static Widget centered(Widget child, {double maxWidth = maxContentWidth}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
