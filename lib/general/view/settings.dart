import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/sampling/widgets/instrument_expansion_tile.dart';
import '../../general/widgets/home_app_bar.dart';
import '../utils/theme_cubit.dart';
import '../widgets/ui_utils.dart';

class Settings extends StatefulWidget {
  const Settings({super.key,});

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  bool _isExpanded = false;
  late String _selectedLanguage;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _selectedLanguage = Languages.langsMap[Localizations.localeOf(context).languageCode] ?? "-";
    });
  }

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
          _onTapOutOfFocus();

        },
        child: _themeBoxes(size, color, isSelected, td),
      );
    }).toList();
  }

  //LANGUAGE
  //STYLE
  Widget _languageTitle(size, td) {
    return SizedBox(
      width: size.width*0.8,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          Languages.languages.getString(context),
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _languageSelection(td, subtext, size) {

    return InstrumentExpansionTile(
      leadingIcon: Icon(Icons.language, color: Colors.white70, size: 20,),
      isExpanded: _isExpanded,
      text: Languages.languages.getString(context),
      onTap: _onPressedLanguageCard,
      isActive: true,
      subText: _selectedLanguage,
      canOpen: true,
      children: [
        _languageList(td, size),
      ],
    );
  }

  Widget _languageSection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width*0.9,
        child: Column(
          children: [
            SizedBox(height: size.height*0.04,),
            _languageTitle(size, td),
            SizedBox(height: size.height*0.03,),
            _languageSelection(td, "", size),
            SizedBox(height: size.height*0.04,),
          ],
        ),
      ),
    );
  }

  //FUNCTIONAL WIDGETS
  Widget _languageList(td, size) {
    List<Widget> tiles = [];

    for (MapEntry<String, dynamic> entry in Languages.langsMap.entries) {
      tiles.add(ListTile(
        contentPadding: EdgeInsets.only(left: size.width*0.07),
        title: Text(
          "${entry.value}",
          style: TextStyle(color: td.colorScheme.onSurface, fontSize: 12),
        ),
        tileColor: td.colorScheme.onPrimaryContainer,
        textColor: td.colorScheme.onSurface,
        onTap: () {
          _onPressedLangTile(entry.key, entry.value);
        },
      ));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: Material(
        color: td.colorScheme.onSurfaceVariant,
        child: ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: tiles,
        ),
      ),
    );
  }

  //METHODS
  void _onPressedLanguageCard() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _onPressedLangTile(keyLang, valueLang) {
    setState(() {
      _selectedLanguage = valueLang;
      _onTapOutOfFocus();
    });
    FlutterLocalization.instance.translate(keyLang);
  }

  void _onTapOutOfFocus() {
    Future.delayed(Duration(milliseconds: 200), () {
      if(_isExpanded) {
        setState(() {
          _isExpanded = false;
        });
      }
    });
  }

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    ThemeData td = Theme.of(context);

    return PopScope(
      canPop: true,
      onPopInvoked: (pop) async {},
      child: Scaffold(
        appBar: HomeAppBar(
          title: 'Pitch Trainer - ${Languages.settings.getString(context)}',
          action1: Container(),
          action2: Container(),
          action3: Container(),
        ),
        body: UiUtils.handleEmptyTaps(
          _onTapOutOfFocus,
          Column(
            children: [
              _languageSection(size, td),
              _themeSection(size, td),
            ],
          ),
        ),
      ),
    );
  }
}

