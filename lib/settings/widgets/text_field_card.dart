import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldCard extends StatefulWidget {
  const TextFieldCard({
    super.key,
    required this.controller,
    required this.hintText,
    this.isEnabled = true,
    this.onChanged,
    required this.trailingIcon,
    required this.onTrailingIconPressed,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isEnabled;
  final Function(String)? onChanged;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingIconPressed;


  @override
  State<TextFieldCard> createState() => _TextFieldCardState();
}

class _TextFieldCardState extends State<TextFieldCard> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      if (widget.onTrailingIconPressed != null) {
        widget.onTrailingIconPressed!();
      }
    }
  }

  Color _getTextColor(ThemeData td) {
    return widget.isEnabled ? td.colorScheme.onSurface : Colors.white38;
  }

  Color _getBorderColor(ThemeData td) {
    return widget.isEnabled ? td.colorScheme.primary : Colors.white38;
  }

  @override
  Widget build(BuildContext context) {
    ThemeData td = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: td.colorScheme.onPrimaryContainer,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: _getBorderColor(td),
          width: 1.5,
        ),
      ),
      child: TextField(
        focusNode: _focusNode,
        controller: widget.controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        enabled: widget.isEnabled,
        onChanged: widget.onChanged,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
          color: _getTextColor(td),
        ),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 12,
            color: _getTextColor(td).withOpacity(0.6),
          ),
          border: InputBorder.none,
          suffixIcon: widget.trailingIcon != null
              ? IconButton(
            icon: Icon(widget.trailingIcon, color: _getTextColor(td)),
            onPressed: widget.onTrailingIconPressed,
          )
              : null,
        ),
        ),
    );
  }
}
