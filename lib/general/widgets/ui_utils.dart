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

  static BoxShadow widgetsShadowColor(double spreadRadius, double blurRadius, Color color) {
    return BoxShadow(
      color: color,
      spreadRadius: spreadRadius,
      blurRadius: blurRadius,
      offset: const Offset(0, 1),
    );
  }

  static Widget handleEmptyTaps(void Function()? onTap, Widget child) {
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: Container(),
        ),
        child,
      ],
    );
  }

  static Widget handleUnfocusedTaps(void Function() onTap, PreferredSizeWidget? appBar, FocusNode focusNode, Widget scaffoldBody) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Scaffold(
        appBar: appBar,
        body: Focus(
          focusNode: focusNode,
          child: scaffoldBody,
        ),
      )
    );
  }

  static TextStyle getSubTextStyle(ThemeData td) {
    return TextStyle(
        color: td.colorScheme.onSurface,
        fontWeight: FontWeight.w100,
        fontSize: 12
    );
  }

}