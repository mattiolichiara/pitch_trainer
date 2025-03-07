import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InstrumentCard extends StatefulWidget {
  const InstrumentCard({
    super.key,
    required this.onPressed,
    required this.text,
    required this.leadingIcon,
    this.isActive = true,
    required this.subText,
    this.canOpen = false,
  });

  final Function()? onPressed;
  final String text;
  final String leadingIcon;
  final bool isActive;
  final String subText;
  final bool canOpen;

  @override
  State<InstrumentCard> createState() => _InstrumentCardState();
}

class _InstrumentCardState extends State<InstrumentCard> {
  late Color _purpleLerpy;
  late Color _bgLerp;

  @override
  void initState() {
    super.initState();
    _purpleLerpy = Color.lerp(const Color(0xFF9168B6), Colors.white, 0.35)!;
    _bgLerp = Color.lerp(const Color.fromARGB(255, 70, 70, 70), Colors.black, 0.30)!;
  }

  //STYLE
  Color _getTextColor() {
    return widget.isActive ? Colors.white : Colors.white38;
  }

  Color _getIconColor() {
    return widget.isActive ? Colors.white70 : Colors.white38;
  }

  //FUNCTIONAL WIDGETS
  Widget _buildTrailingIcon() {
    if (widget.canOpen) {
      return Icon(
        Icons.arrow_forward_ios,
        color: _getIconColor(),
        size: 11,
      );
    } else {
      return const Icon(
        Icons.arrow_forward_ios,
        color: Colors.transparent,
        size: 11,
      );
    }
  }

  Widget _instrumentListTile() {
    return ListTile(
      onTap: widget.isActive ? widget.onPressed : null,
      tileColor: _bgLerp,
      leading: SvgPicture.asset(
        widget.leadingIcon,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(_getIconColor(), BlendMode.srcIn),
      ),
      subtitle: Text(
        widget.subText,
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 12,
          color: _getTextColor(),
        ),
      ),
      title: Text(
        widget.text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: _getTextColor(),
        ),
      ),
      trailing: _buildTrailingIcon(),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(3.5)),
      ),
    );
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: _purpleLerpy,
          width: 1.5,
        ),
      ),
      child: _instrumentListTile(),
    );
  }
}
