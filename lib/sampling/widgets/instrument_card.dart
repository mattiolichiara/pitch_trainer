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
  late Color _bgLerp;

  @override
  void initState() {
    _bgLerp = Color.lerp(const Color.fromARGB(255, 70, 70, 70), Colors.black, 0.30)!;

    super.initState();
  }

  //STYLE
  Color _getTextColor(td) {
    return widget.isActive ? td.colorScheme.onSurface : Colors.white38;
  }

  Color _getIconColor(td) {
    return widget.isActive ? Colors.white70 : Colors.white38;
  }

  //FUNCTIONAL WIDGETS
  Widget _buildTrailingIcon(td) {
    if (widget.canOpen) {
      return Icon(
        Icons.arrow_forward_ios,
        color: _getIconColor(td),
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

  Widget _instrumentListTile(td) {
    return ListTile(
      onTap: widget.isActive ? widget.onPressed : null,
      tileColor: _bgLerp,
      leading: SvgPicture.asset(
        widget.leadingIcon,
        width: 20,
        height: 20,
        colorFilter: ColorFilter.mode(_getIconColor(td), BlendMode.srcIn),
      ),
      subtitle: Text(
        widget.subText,
        style: TextStyle(
          fontWeight: FontWeight.w300,
          fontSize: 12,
          color: _getTextColor(td),
        ),
      ),
      title: Text(
        widget.text,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: _getTextColor(td),
        ),
      ),
      trailing: _buildTrailingIcon(td),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(3.5)),
      ),
    );
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    ThemeData td = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: td.colorScheme.primary,
          width: 1.5,
        ),
      ),
      child: _instrumentListTile(td),
    );
  }
}
