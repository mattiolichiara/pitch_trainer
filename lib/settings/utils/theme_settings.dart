import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/settings/utils/accuracy_settings.dart';
import 'package:pitch_trainer/settings/utils/language_setting.dart';
import 'package:pitch_trainer/settings/utils/rates_settings.dart';
import 'package:pitch_trainer/settings/utils/sound_wave_settings.dart';
import '../../general/widgets/home_app_bar.dart';
import '../../sampling/utils/recorder.dart';
import '../../general/utils/theme_cubit.dart';
import '../../general/widgets/ui_utils.dart';

class ThemeSettings extends StatefulWidget {
  const ThemeSettings({super.key,});

  @override
  State<ThemeSettings> createState() => _ThemeSettings();
}

class _ThemeSettings extends State<ThemeSettings> {

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  //THEME
  //STYLE
  Widget _themeTitle(size, td) {
    return SizedBox(
      width: size.width*0.8,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          Languages.selectTheme.getString(context),
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _themeWrapper(Size size, Map<AppThemeMode, ThemeData> themes, ThemeCubit themeCubit, td) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      direction: Axis.horizontal,
      children: _getThemeColors(size, themes, themeCubit, td),
    );
  }

  Widget _wrapTheWrap(Size size, BuildContext context, td) {
    ThemeCubit themeCubit = BlocProvider.of<ThemeCubit>(context);
    Map<AppThemeMode, ThemeData> themes = themeCubit.availableThemes;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: _themeWrapper(size, themes, themeCubit, td),
    );
  }

  Widget _themeSection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width*0.9,
        child: Column(
          children: [
            SizedBox(height: size.height*0.04,),
            _themeTitle(size, td),
            SizedBox(height: size.height*0.03,),
            _wrapTheWrap(size, context, td),
            SizedBox(height: size.height*0.04,),
          ],
        ),
      ),
    );
  }

  //FUNCTIONAL WIDGETS
  Widget _themeBoxes(Size size, Color color, isSelected, td) {
    return Container(
      width: size.width * 0.2,
      height: size.height * 0.1,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected ? Colors.white54 : Colors.black,
          width: isSelected ? 3 : 1,
        ),
      ),
      child: isSelected
          ? Icon(Icons.check, color: Colors.white54)
          : null,
    );
  }

  List<Widget> _getThemeColors(Size size, Map<AppThemeMode, ThemeData> themes, ThemeCubit themeCubit, td) {
    return themes.entries.map((theme) {
      ThemeData themeData = theme.value;
      Color color = themeData.colorScheme.primary;
      bool isSelected = themeCubit.state == themeData;

      return GestureDetector(
        onTap: () {
          setState(() {
            themeCubit.changeTheme(theme.key);
          });

        },
        child: _themeBoxes(size, color, isSelected, td),
      );
    }).toList();
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  _themeSection(size, td),
                  SizedBox(height: size.height*0.04,),
                ],
              ),
    );
  }
}

