import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../general/cubit/reset_cubit.dart';

class ValueSlider extends StatefulWidget {
  const ValueSlider({
    super.key,
    required this.activeColor,
    required this.inactiveColor,
    required this.boxWidth,
    required this.boxHeight,
    required this.min,
    required this.max,
    required this.selectedValue,
    required this.onChanged,
    required this.boxColor,
    required this.boxShadow,
    required this.textColor,
    this.fontFamily,
    required this.fontSize,
    required this.fontWeight,
    required this.ticksHeight,
    required this.ticksWidth,
    required this.ticksMargin,
    required this.boxBorderColor,
  });

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
  bool _initialScrollDone = false;
  bool _shouldPerformReset = false;

  @override
  void initState() {
    super.initState();
    _initialScrollDone = false;
    _selectedValue = _valueToIndex(widget.selectedValue);

    _scrollController.addListener(_handleScrollUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToIndex(_selectedValue);
      }
      setState(() => _initialScrollDone = true);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final resetState = context.watch<ResetCubit>().state;

    if (resetState.shouldReset) {
      _shouldPerformReset = true;
    }
  }

  @override
  void didUpdateWidget(covariant ValueSlider oldWidget) {
    super.didUpdateWidget(oldWidget);

    if(_shouldPerformReset) {
      int currentValue = widget.selectedValue-widget.min;
      if (currentValue!=0) {
        setState(() {
          _selectedValue = currentValue;
          _scrollToIndex(_selectedValue);
          //debugPrint("[NEW SELECTED INDEX]: $_selectedValue, [WIDGET SELECTED VALUE]: ${currentValue}, [OLD WIDGET SELECTED VALUE]: ${oldWidget.selectedValue}");
        });
      }
    }
    BlocProvider.of<ResetCubit>(context).denyRebuild();
    _shouldPerformReset = false;

  }

  int _valueToIndex(int selectedValue) {
    return selectedValue - widget.min;
  }

  int _indexToValue(int selectedIndex) {
    return selectedIndex + widget.min;
  }

  void _handleScrollUpdate() {
    if (!_initialScrollDone) return;

    final double tickSizeWithMargin =
        widget.ticksWidth + (widget.ticksMargin * 2);
    final int newIndex = (_scrollController.offset / tickSizeWithMargin)
        .round()
        .clamp(widget.min - widget.min, widget.max - widget.min);

    if (newIndex != _selectedValue) {
      setState(() => _selectedValue = newIndex);
      widget.onChanged(_indexToValue(newIndex));
    }
  }

  Future<void> _scrollToIndex(int index) async {
    if (!_scrollController.hasClients) return;

    final double tickSizeWithMargin =
        widget.ticksWidth + (widget.ticksMargin * 2);
    final double targetOffset = index * tickSizeWithMargin;

    await _scrollController.animateTo(
      targetOffset.clamp(0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _scrollBar(Size size, key) {
    return GestureDetector(
      child: SizedBox(
        height: max(widget.ticksHeight + 10, widget.boxHeight),
        child: ListView(
          key: key,
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
    int displayValue = _indexToValue(_selectedValue);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: widget.ticksWidth,
          height: widget.ticksHeight + 10,
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
              displayValue.toString(),
              style: TextStyle(
                color: widget.textColor,
                fontWeight: widget.fontWeight,
                fontSize: widget.fontSize,
                fontFamily: widget.fontFamily,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _shadowEffect(ThemeData td, Size size) {
    double blurRadius = 100;
    double spreadRadius = 40;
    double offset = 0.9;

    return IgnorePointer(
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: td.colorScheme.surface,
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
              offset: Offset(size.width * offset, 0),
            ),
            BoxShadow(
              color: td.colorScheme.surface,
              blurRadius: blurRadius,
              spreadRadius: spreadRadius,
              offset: Offset(size.width * -offset, 0),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return BlocBuilder<ResetCubit, ResetState>(
        builder: (context, key) {
          return SizedBox(
            height: max(widget.ticksHeight + 10, widget.boxHeight),
            child: Stack(
              key: key.key,
              alignment: Alignment.center,
              children: [_scrollBar(size, key.key), _valueBox()],
            ),
          );
        });
  }
}
