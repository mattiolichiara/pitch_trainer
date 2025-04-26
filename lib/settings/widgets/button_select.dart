import 'package:flutter/material.dart';

class ButtonSelect extends StatefulWidget {
  const ButtonSelect({
    super.key,
    required this.children,
    required this.selectionValues,
    required this.onPressed,
    this.hintText,
    this.isEnabled = true,
    this.direction = Axis.horizontal,
    this.minWidth,
  });

  final List<Widget> children;
  final List<bool> selectionValues;
  final Function(int)? onPressed;
  final String? hintText;
  final bool isEnabled;
  final Axis direction;
  final double? minWidth;

  @override
  State<ButtonSelect> createState() => _ButtonSelectState();
}

class _ButtonSelectState extends State<ButtonSelect> {


  @override
  Widget build(BuildContext context) {
    ThemeData td = Theme.of(context);
    Size size = MediaQuery.of(context).size;
    // TextStyle stringStyle = TextStyle(
    //   color: Color.lerp(td.colorScheme.primary, Colors.white, 0.6)!,
    //   fontWeight: FontWeight.w800,
    //   fontSize: 18,
    // );

    return Container(
      color: td.colorScheme.onPrimaryContainer,
      child: ToggleButtons(
        direction: Axis.horizontal,
        onPressed: widget.onPressed,
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        splashColor: td.colorScheme.secondary,
        borderWidth: 1.5,
        borderColor: td.colorScheme.primary,
        selectedBorderColor: td.colorScheme.primary,
        fillColor: td.colorScheme.primary.withAlpha(2750),
        constraints: BoxConstraints(minHeight: size.height*0.07, minWidth: widget.minWidth ?? size.width*0.28),
        isSelected: widget.selectionValues,
        //textStyle: stringStyle,
        children: widget.children,
      ),
    );
  }
}