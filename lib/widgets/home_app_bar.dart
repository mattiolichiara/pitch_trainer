import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../sampling/sound_sampling.dart';

class HomeAppBar extends StatefulWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key, this.title = '', required this.action1, required this.action2, required this.action3, this.isHome = false});

  final String title;
  final Widget action1;
  final Widget action2;
  final Widget action3;
  final bool isHome;

  @override
  State<HomeAppBar> createState() => _HomeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(60);
}

class _HomeAppBar extends State<HomeAppBar> {

  //FUNCTIONAL WIDGETS
  Widget titleText() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        widget.title,
        style: const TextStyle(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.w500,
            shadows: [
              BoxShadow(
                color: Color(0xFF9168B6),
                spreadRadius: 1,
                blurRadius: 30,
                offset: Offset(0, 1),
              )
            ]
        ),
      ),
    );
  }

  Widget _homeButtonStyle() {
    return IconButton(
      icon: SvgPicture.asset(
        "assets/icons/sound-waves-svgrepo-com.svg",
        height: 40,
        width: 40,
        //colorFilter: ColorFilter.mode(const Color(0xFF9168B6), BlendMode.srcIn),
      ),
      onPressed: _onPressedHome,
    );
  }

  //METHODS
  void _onPressedHome() {
    if(!widget.isHome) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SoundSampling()),
              (Route<dynamic> route) => false);
    }
  }

  Widget _homeButton() {
    return Container(
      decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0xFF9168B6),
              spreadRadius: 1,
              blurRadius: 40,
              offset: Offset(0, 1),
            ),
          ]
      ),
      child: _homeButtonStyle(),
    );
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF252525),
      title: titleText(),
      leading: _homeButton(),
      actions: [
        widget.action1,
        widget.action2,
        widget.action3,
      ],
      shadowColor: const Color(0xFF9168B6),
      elevation: 10,
    );
  }
}