import 'package:flutter/material.dart';

class UiUtils {

  static Widget loadingStyle() {
    Color purpleLerpy = Color.lerp(
        const Color(0xFF9168B6), Colors.white, 0.35)!;

    return Center(
      child: CircularProgressIndicator(
        color: purpleLerpy,
        strokeWidth: 1,
      ),
    );
  }

  static BoxShadow widgetsShadow(double spreadRadius, double blurRadius) {
    return BoxShadow(
      color: const Color(0xFF9168B6),
      spreadRadius: spreadRadius,
      blurRadius: blurRadius,
      offset: const Offset(0, 1),
    );
  }

}