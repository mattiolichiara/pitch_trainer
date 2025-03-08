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
        required this.onTap});

  final String text;
  final String leadingIcon;
  final bool isActive;
  final String subText;
  final bool canOpen;
  final List<Widget> children;
  final bool isExpanded;
  final void Function()? onTap;

  @override
  State<InstrumentExpansionTile> createState() =>
      _InstrumentExpansionTileState();
}

class _InstrumentExpansionTileState extends State<InstrumentExpansionTile> {

  //STYLE
  Color selectColor() {
    return widget.isActive == true ? Colors.white : Colors.white38;
  }

  //FUNCTIONAL WIDGETS
  Widget _animationWidget(bgLerp) {
    return AnimatedCrossFade(
      duration: const Duration(milliseconds: 200),
      crossFadeState: widget.isExpanded
          ? CrossFadeState.showSecond
          : CrossFadeState.showFirst,
      firstChild: const SizedBox.shrink(),
      secondChild: Container(
          height: MediaQuery.of(context).size.height * 0.2,
          width: MediaQuery.of(context).size.width * 0.85,
          color: bgLerp,
          child: Column(
            children: widget.children,
          )
      ),
    );
  }

  Widget _selectTrailing() {
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
    return SvgPicture.asset(
      leadingIcon,
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(
        widget.isActive == true ? Colors.white70 : Colors.white38,
        BlendMode.srcIn,
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    String text = widget.text;
    String leadingIcon = widget.leadingIcon;
    Color purpleLerpy =
    Color.lerp(const Color(0xFF9168B6), Colors.white, 0.35)!;
    Color bgLerp =
    Color.lerp(const Color.fromARGB(255, 70, 70, 70), Colors.black, 0.30)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: purpleLerpy,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            onTap: widget.onTap,
            tileColor: bgLerp,
            leading: _leadingIcon(leadingIcon),
            subtitle: Text(
              widget.subText,
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 12,
                color: selectColor(),
              ),
            ),
            title: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: selectColor(),
              ),
            ),
            trailing: _selectTrailing(),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(3.5)),
            ),
          ),
          _animationWidget(bgLerp),
        ],
      ),
    );
  }
}
