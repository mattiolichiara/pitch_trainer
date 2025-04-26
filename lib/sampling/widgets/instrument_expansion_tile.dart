import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InstrumentExpansionTile extends StatefulWidget {
  const InstrumentExpansionTile(
      {super.key,
        required this.text,
        required this.leadingIcon,
        this.isActive = true,
        required this.subText,
        this.canOpen = false,
        required this.children,
        required this.isExpanded,
        required this.onTap,
        this.iconSize = 20});

  final String text;
  final Object leadingIcon;
  final bool isActive;
  final String subText;
  final bool canOpen;
  final List<Widget> children;
  final bool isExpanded;
  final void Function()? onTap;
  final double iconSize;

  @override
  State<InstrumentExpansionTile> createState() =>
      _InstrumentExpansionTileState();
}

class _InstrumentExpansionTileState extends State<InstrumentExpansionTile> {

  //STYLE
  Color selectColor(td) {
    return widget.isActive == true ? td.colorScheme.onSurface : Colors.white38;
  }

  //FUNCTIONAL WIDGETS
  Widget _animationWidget(td) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: widget.isExpanded
            ? Container(
          width: double.infinity,
          color: td.colorScheme.onPrimaryContainer,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.children,
          ),
        )
            : const SizedBox.shrink(),
      ),
    );
  }




  Widget _selectTrailing(td) {
    return widget.canOpen
        ? Icon(
      widget.isExpanded
          ? Icons.keyboard_arrow_down_rounded
          : Icons.keyboard_arrow_right_rounded,
      color: widget.isActive == true
          ? Colors.white70
          : Colors.white38,
      size: 20,
    )
        : const SizedBox.shrink();
  }

  Widget _leadingIcon(leadingIcon) {
    if(leadingIcon.runtimeType != String) return leadingIcon;

    return SvgPicture.asset(
      leadingIcon,
      width: widget.iconSize,
      height: widget.iconSize,
      colorFilter: ColorFilter.mode(
        widget.isActive == true ? Colors.white70 : Colors.white38,
        BlendMode.srcIn,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    String text = widget.text;
    Object leadingIcon = widget.leadingIcon;
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
      child: Column(
        children: [
          ListTile(
            onTap: widget.onTap,
            tileColor: td.colorScheme.onPrimaryContainer,
            leading: _leadingIcon(leadingIcon),
            subtitle: Text(
              widget.subText,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 12,
                color: selectColor(td),
              ),
            ),
            title: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: selectColor(td),
              ),
            ),
            trailing: _selectTrailing(td),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3.5)),
            ),
          ),
          _animationWidget(td),
        ],
      ),
    );
  }
}
