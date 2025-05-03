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
    this.iconSize = 20,
  });

  final Function()? onPressed;
  final String text;
  final String leadingIcon;
  final bool isActive;
  final String subText;
  final bool canOpen;
  final double iconSize;

  @override
  State<InstrumentCard> createState() => _InstrumentCardState();
}

class _InstrumentCardState extends State<InstrumentCard> {

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
      tileColor: td.colorScheme.onPrimaryContainer,
      leading: SvgPicture.asset(
        widget.leadingIcon,
        width: widget.iconSize,
        height: widget.iconSize,
        colorFilter: ColorFilter.mode(_getIconColor(td), BlendMode.srcIn),
      ),
      subtitle: Text(
        widget.subText,
        style: TextStyle(
          fontWeight: FontWeight.w100,
          fontSize: 12,
          color: _getTextColor(td),
        ),
      ),
      title: Text(
        widget.text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
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
