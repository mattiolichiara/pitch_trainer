import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ValueSlider extends StatefulWidget {
  const ValueSlider({super.key, required this.activeColor, required this.inactiveColor, required this.boxWidth, required this.boxHeight,
    required this.min, required this.max, required this.selectedValue, required this.onChanged, required this.boxColor, required this.boxShadow,
    required this.textColor, this.fontFamily, required this.fontSize, required this.fontWeight, required this.ticksHeight, required this.ticksWidth, required this.ticksMargin,
    required this.boxBorderColor, required this.initialPosition, required this.onScrollPositionChanged, required this.canReset});

  final Color activeColor;
  final Color inactiveColor;
  final double boxWidth;
  final double boxHeight;
  final int min;
  final int max;
  final int selectedValue;
  final ValueChanged<int> onChanged;
  final Color boxColor;
  final List<BoxShadow> boxShadow;
  final Color textColor;
  final String? fontFamily;
  final double fontSize;
  final FontWeight fontWeight;
  final double ticksHeight;
  final double ticksWidth;
  final double ticksMargin;
  final Color boxBorderColor;
  final double initialPosition;
  final ValueChanged<double> onScrollPositionChanged;
  final bool canReset;

  @override
  State<ValueSlider> createState() => _ValueSliderState();
}

class _ValueSliderState extends State<ValueSlider> {
  late int _selectedValue;
  final ScrollController _scrollController = ScrollController();
  bool _initialScrollDone = false;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;

    _scrollController.addListener(_handleScrollUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(widget.initialPosition);
      }
      setState(() => _initialScrollDone = true);
    });
  }

  int _indexToValue(int index) => widget.min + index;
  int _valueToIndex(int value) => (value - widget.min).clamp(0, widget.max - widget.min);

  void _handleScrollUpdate() {
    if (!_initialScrollDone) return;

    widget.onScrollPositionChanged(_scrollController.offset);

    final double tickSizeWithMargin = widget.ticksWidth + (widget.ticksMargin * 2);
    final int newIndex = (_scrollController.offset / tickSizeWithMargin).round().clamp(widget.min, widget.max);

    if (newIndex != _selectedValue) {
      setState(() => _selectedValue = newIndex);
      widget.onChanged(newIndex);
    }
  }

  @override
  void didUpdateWidget(ValueSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    debugPrint("[Can Reset]: ${widget.canReset}");

    if(widget.canReset) {
      if (widget.initialPosition != oldWidget.initialPosition && _initialScrollDone) {
        _scrollController.animateTo(
          widget.initialPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }

      if (widget.selectedValue != oldWidget.selectedValue) {
        _scrollToIndex(widget.selectedValue);
      }
      setState(() {

      });
    }
  }

  Future<void> _scrollToIndex(int index) async {
    if (!_scrollController.hasClients) return;

    final double tickSizeWithMargin = widget.ticksWidth + (widget.ticksMargin * 2);
    final double targetOffset = index * tickSizeWithMargin;

    await _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _scrollBar(Size size) {
    return GestureDetector(
      child: SizedBox(
        height: max(widget.ticksHeight + 10, widget.boxHeight),
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: size.width * 0.435),
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          shrinkWrap: true,
          children: _generateTicks(),
        ),
      ),
    );
  }

  List<Widget> _generateTicks() {
    return List.generate(widget.max - widget.min + 1, (index) {
      return Container(
          margin: EdgeInsets.symmetric(horizontal: widget.ticksMargin),
          width: widget.ticksWidth,
          height: widget.ticksHeight,
          decoration: BoxDecoration(
            color: widget.inactiveColor,
            borderRadius: BorderRadius.circular(2),
          ),
        );
    });
  }

  Widget _valueBox() {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: widget.ticksWidth,
            height: widget.ticksHeight+10,
            decoration: BoxDecoration(
              color: widget.activeColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Container(
            width: widget.boxWidth,
            height: widget.boxHeight,
            decoration: BoxDecoration(
              color: widget.boxColor,
              borderRadius: BorderRadius.circular(5),
              boxShadow: widget.boxShadow,
              border: Border.all(color: widget.boxColor, width: 1.5),
            ),
            child: Center(
              child: Text(
                _indexToValue(_selectedValue).toString(),
                style: TextStyle(
                  color: widget.textColor,
                  fontWeight: widget.fontWeight,
                  fontSize: widget.fontSize,
                  fontFamily: widget.fontFamily,
                ),
              ),
            ),
          ),
        ]
      );
  }

  Widget _shadowEffetct(ThemeData td, Size size) {
    double blurRadius = 100;
    double spreadRadius = 40;
    double offset = 0.9;

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: td.colorScheme.surface, blurRadius: blurRadius, spreadRadius: spreadRadius, offset: Offset(size.width*offset, 0),),
            BoxShadow(color: td.colorScheme.surface, blurRadius: blurRadius, spreadRadius: spreadRadius, offset: Offset(size.width*-offset, 0))],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return SizedBox(
      height: max(widget.ticksHeight+10, widget.boxHeight),
        child: Stack(
            alignment: Alignment.center,
            children: [
              _scrollBar(size),
              _valueBox(),
              //_shadowEffetct(td, size),
            ],
          ),
    );
  }
}