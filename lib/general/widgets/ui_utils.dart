import 'package:flutter/material.dart';

class UiUtils {

  static Widget loadingStyle(td) {
    return Center(
      child: CircularProgressIndicator(
        color: td.colorScheme.secondary,
        strokeWidth: 1,
      ),
    );
  }

  static BoxShadow widgetsShadow(double spreadRadius, double blurRadius, td) {
    return BoxShadow(
      color: td.colorScheme.primary,
      spreadRadius: spreadRadius,
      blurRadius: blurRadius,
      offset: const Offset(0, 1),
    );
  }

  static Widget detectEmptyTaps(void Function()? onTap, Widget child) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Container(),
        ),
        child,
      ],
    );
  }

}