import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../general/widgets/home_app_bar.dart';
import '../utils/theme_cubit.dart';
import '../widgets/ui_utils.dart';

class Settings extends StatefulWidget {
  const Settings({super.key,});

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {

  //STYLE
  Widget _themeTitle(size) {
    return SizedBox(
      width: size.width*0.8,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "Select Theme",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 17, shadows: [UiUtils.widgetsShadow(80, 20),],),
        ),
      ),
    );
  }

  Widget _wrapTheWrap(Size size, BuildContext context) {
    final themeCubit = BlocProvider.of<ThemeCubit>(context);
    final themes = themeCubit.availableThemes;

    return SizedBox(
      width: size.width * 0.8,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: _themeWrapper(size, themes, themeCubit),
      ),
    );
  }

  Widget _themeWrapper(Size size, Map<AppThemeMode, ThemeData> themes, ThemeCubit themeCubit) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      direction: Axis.horizontal,
      children: _getThemeColors(size, themes, themeCubit),
    );
  }

  Widget _themeSection(size) {
    return Center(
      child: SizedBox(
        width: size.width*0.9,
        child: Column(
          children: [
            SizedBox(height: size.height*0.04,),
            _themeTitle(size),
            SizedBox(height: size.height*0.03,),
            _wrapTheWrap(size, context),
            SizedBox(height: size.height*0.04,),
          ],
        ),
      ),
    );
  }

  //WIDGETS
  List<Widget> _getThemeColors(Size size, Map<AppThemeMode, ThemeData> themes, ThemeCubit themeCubit) {
    return themes.entries.map((theme) {
      final themeData = theme.value;
      final color = themeData.colorScheme.primary;

      return GestureDetector(
        onTap: () {
          themeCubit.changeTheme(theme.key);
        },
        child: _themeBoxes(size, color),
      );
    }).toList();
  }

  Widget _themeBoxes(Size size, Color color) {
    return Container(
      width: size.width * 0.2,
      height: size.height * 0.1,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: true,
      onPopInvoked: (pop) async {},
      child: Scaffold(
        appBar: HomeAppBar(
          title: 'Pitch Trainer - Settings',
          action1: Container(),
          action2: Container(),
          action3: Container(),
        ),
        body: Column(
          children: [
            _themeSection(size),
          ],
        ),
      ),
    );
  }
}
