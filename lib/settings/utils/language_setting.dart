import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/settings/widgets/button_select.dart';
import 'package:pitch_trainer/sampling/widgets/instrument_expansion_tile.dart';
import 'package:pitch_trainer/settings/widgets/text_field_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../general/widgets/home_app_bar.dart';
import '../../sampling/utils/recorder.dart';
import '../../general/utils/theme_cubit.dart';
import '../../general/widgets/ui_utils.dart';

class LanguageSettings extends StatefulWidget {
  const LanguageSettings({super.key});

  @override
  State<LanguageSettings> createState() => _LanguageSettings();
}

class _LanguageSettings extends State<LanguageSettings> {
  late String _selectedLanguage;
  bool _isExpanded = false;

  @override
  void initState() {
    WidgetsFlutterBinding.ensureInitialized();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _selectedLanguage =
          Languages.langsMap[Localizations.localeOf(context).languageCode] ??
          "-";
    });
  }

  //LANGUAGE
  //STYLE
  Widget _languageTitle(size, td) {
    return SizedBox(
      width: size.width * 0.8,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          Languages.languages.getString(context),
          style: TextStyle(
            color: td.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
            fontSize: 18,
            shadows: [UiUtils.widgetsShadow(80, 20, td)],
          ),
        ),
      ),
    );
  }

  Widget _languageSelection(td, subtext, size) {
    return InstrumentExpansionTile(
      leadingIcon: Icon(Icons.language, color: Colors.white70, size: 20),
      isExpanded: _isExpanded,
      text: Languages.languages.getString(context),
      onTap: _onPressedLanguageCard,
      isActive: true,
      subText: _selectedLanguage,
      canOpen: true,
      children: [_languageList(td, size)],
    );
  }

  Widget _languageSection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width * 0.9,
        child: Column(
          children: [
            SizedBox(height: size.height * 0.04),
            _languageTitle(size, td),
            SizedBox(height: size.height * 0.03),
            _languageSelection(td, "", size),
            SizedBox(height: size.height * 0.04),
          ],
        ),
      ),
    );
  }

  //FUNCTIONAL WIDGETS
  Widget _languageList(td, size) {
    List<Widget> tiles = [];

    for (MapEntry<String, dynamic> entry in Languages.langsMap.entries) {
      tiles.add(
        ListTile(
          contentPadding: EdgeInsets.only(left: size.width * 0.07),
          title: Text(
            "${entry.value}",
            style: TextStyle(color: td.colorScheme.onSurface, fontSize: 12),
          ),
          tileColor: td.colorScheme.onPrimaryContainer,
          textColor: td.colorScheme.onSurface,
          onTap: () {
            _onPressedLangTile(entry.key, entry.value);
          },
        ),
      );
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

  //GENERAL
  void _onTapOutOfFocus() {
    Future.delayed(Duration(milliseconds: 200), () {
      if (_isExpanded) {
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

    return Column(
          children: [
            _languageSection(size, td),
            SizedBox(height: size.height * 0.05),
          ],
    );
  }
}
