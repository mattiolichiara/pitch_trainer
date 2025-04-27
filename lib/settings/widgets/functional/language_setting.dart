import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/sampling/widgets/instrument_expansion_tile.dart';

import '../../../general/widgets/ui_utils.dart';

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
        alignment: Alignment.centerLeft,
        child: Text(
          Languages.languages.getString(context),
          style: TextStyle(
            color: td.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            shadows: [UiUtils.widgetsShadow(80, 20, td)],
          ),
        ),
      ),
    );
  }

  Widget _languageSelection(td, subtext, size) {
    return InstrumentExpansionTile(
      leadingIcon: SvgPicture.asset(
        "assets/icons/globe-2-svgrepo-com.svg",
        height: size.height * 0.025,
        width: size.width * 0.025,
        colorFilter: ColorFilter.mode(td.colorScheme.onSurface, BlendMode.srcIn),
      ),
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

    return _languageSection(size, td);
  }
}
