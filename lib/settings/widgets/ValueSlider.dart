import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class ValueSlider extends StatefulWidget {
  const ValueSlider({super.key, required this.activeColor, required this.inactiveColor, required this.boxWidth, required this.boxHeight,
    required this.min, required this.max, required this.selectedValue, required this.onChanged, required this.boxColor, required this.boxShadow,
    required this.textColor, this.fontFamily, required this.fontSize, required this.fontWeight, required this.ticksHeight, required this.ticksWidth, required this.ticksMargin,
    required this.boxBorderColor,});

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

  @override
  State<ValueSlider> createState() => _ValueSliderState();
}

class _ValueSliderState extends State<ValueSlider> {
  late int _selectedValue;
  final ScrollController _scrollController = ScrollController();
  late double _fullTickSize;
  bool _isFirstScroll = false;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.selectedValue;
    _fullTickSize = widget.ticksWidth*(widget.max-widget.min) + widget.ticksMargin*2;

    _scrollController.addListener(_handleScrollUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToIndex(_selectedValue);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScrollUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToIndex(int index) {
    if (!_scrollController.hasClients) return;

    _isFirstScroll = true;

    final double tickSizeWithMargin = widget.ticksWidth + (widget.ticksMargin * 2);
    final double targetOffset = index * tickSizeWithMargin -
        (MediaQuery.of(context).size.width * (0.435)) +
        (tickSizeWithMargin / 2);

    _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    ).then((_) {
      _isFirstScroll = false;
    });
  }


  int _getCenterIndex() {
    if (!_scrollController.hasClients) return _selectedValue;

    final double scrollOffset = _scrollController.offset;
    final double viewportWidth = _scrollController.position.viewportDimension;
    final double centerX = scrollOffset + (viewportWidth / 2);

    final double tickSizeWithMargin = widget.ticksWidth + (widget.ticksMargin * 2);
    final double totalTicksWidth = tickSizeWithMargin * (widget.max - widget.min + 1);
    final double totalWidth = totalTicksWidth + viewportWidth;

    final double listViewPadding = (totalWidth - totalTicksWidth) / 2;


    final double adjustedCenterX = centerX - listViewPadding;
    final int centerIndex = (adjustedCenterX / tickSizeWithMargin).round();

    return (widget.min + centerIndex).clamp(widget.min, widget.max);
  }

  void _handleScrollUpdate() {
    if (_isFirstScroll) return;

    final newIndex = _getCenterIndex();
    if (newIndex != _selectedValue) {
      setState(() {
        _selectedValue = newIndex;
      });
      widget.onChanged(newIndex);
    }
  }

  Widget _scrollBar(Size size) {
    return SizedBox(
      height: max(widget.ticksHeight + 10, widget.boxHeight),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: size.width*0.435),
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: _generateTicks(),
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

  // List<Widget> _generateTicks() {
  //   return List.generate(widget.max - widget.min + 1, (index) {
  //     final currentValue = widget.min + index;
  //     final isSelected = currentValue == _selectedValue;
  //
  //     return Container(
  //         margin: EdgeInsets.symmetric(horizontal: widget.ticksMargin),
  //         width: widget.ticksWidth,
  //         height: isSelected ? widget.ticksHeight+10 : widget.ticksHeight,
  //         decoration: BoxDecoration(
  //           color: isSelected ? widget.activeColor : widget.inactiveColor,
  //           borderRadius: BorderRadius.circular(2),
  //         ),
  //       );
  //   });
  // }

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
                _selectedValue.toString(),
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

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      height: max(widget.ticksHeight+10, widget.boxHeight),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _scrollBar(size),
            _valueBox(),
          ],
        ),
    );
  }
}