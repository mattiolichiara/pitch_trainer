import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/sampling/widgets/instrument_expansion_tile.dart';
import 'package:pitch_trainer/sampling/widgets/text_field_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../general/widgets/home_app_bar.dart';
import '../../sampling/utils/recorder.dart';
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
  final TextEditingController _sampleRateController = TextEditingController();
  final TextEditingController _bitRateController = TextEditingController();
  late SharedPreferences _prefs;
  late Recorder recorder;
  bool _isCleanWave = true;

  @override
  void initState() {
    recorder = Recorder();
    recorder.initialize();
    WidgetsFlutterBinding.ensureInitialized();
    _getPreferences();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      _selectedLanguage = Languages.langsMap[Localizations.localeOf(context).languageCode] ?? "-";
    });
  }

  void _getPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _getBitRate();
    _getSampleRate();
    _getWaveState();

    setState(() {

    });
  }

  //WAVE VIEW
  //STYLE
  Widget _waveTitle(size, td) {
    return SizedBox(
      width: size.width*0.4,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "Sound Wave",
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _waveTypeText(String text, ThemeData td) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 12,
        shadows: [UiUtils.widgetsShadow(80, 20, td),],
        fontWeight: FontWeight.w300,
      ),
    );
  }

  Widget _switchWaveWrapper(String rawText, ThemeData td, String polishedText, Size size) {
    return SizedBox(
      width: size.width*0.7,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _waveTypeText(rawText, td),
          _switchWave(size, td),
          _waveTypeText(polishedText, td),
        ],
      ),
    );
  }

  Widget _waveSection(size, td) {
    return Center(
      child: SizedBox(
        width: size.width*0.9,
        child: Column(
          children: [
            SizedBox(height: size.height*0.04,),
            _waveTitle(size, td),
            SizedBox(height: size.height*0.03,),
            _switchWaveWrapper(Languages.rawWave.getString(context), td, Languages.polishedWave.getString(context), size),
          ],
        ),
      ),
    );
  }

  //WIDGETS


  Widget _switchWave(Size size, ThemeData td) {
    return SizedBox(
      height: size.height*0.04,
      width: size.width*0.4,
      child: Switch(
        value: _isCleanWave,
        onChanged: (value) {
          _setWaveState(value);
        },
        inactiveTrackColor: td.colorScheme.onSurfaceVariant,
        inactiveThumbColor: td.colorScheme.primary,
        activeColor: td.colorScheme.onSurfaceVariant,
        activeTrackColor: td.colorScheme.primary,
        trackOutlineColor: WidgetStateProperty.all(td.colorScheme.secondary),
      ),
    );
  }

  //METHODS
  void _getWaveState() async {
    _isCleanWave = (_prefs.getBool('isCleanWave') ?? true);
  }

  void _setWaveState(value) async {
    setState(() {
      _isCleanWave = !_isCleanWave;
    });
    _prefs.setBool('isCleanWave', _isCleanWave);
  }

  //BIT RATE
  //STYLE
  Widget _bitRateTitle(size, td) {
    return SizedBox(
      width: size.width*0.4,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "Bit Rate",
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _bitRateField(Size size) {
    return SizedBox(
      width: size.width*0.4,
      child: TextFieldCard(
        controller: _bitRateController,
        hintText: recorder.defaultBitRate.toString(),
        isEnabled: true,
        trailingIcon: Icons.save_outlined,
        onTrailingIconPressed: () => _setBitRate(_bitRateController.text),
        onChanged: (value) {
          _bitRateController.text = value;
        },
      ),
    );
  }

  Widget _bitRate(Size size, td) {
    return Column(
      children: [
        _bitRateTitle(size, td),
        SizedBox(height: size.height*0.03,),
        _bitRateField(size),
      ],
    );
  }

  //METHODS
  void _getBitRate() async {
    _bitRateController.text = (_prefs.getInt('bitRate') ?? recorder.defaultBitRate).toString();
  }

  VoidCallback? _setBitRate(String bitRate) {
    if(bitRate=="") {
      setState(() {
        bitRate = recorder.defaultBitRate.toString();
      });
    }
    setState(() {
      _bitRateController.text = bitRate;
    });
    _prefs.setInt('bitRate', int.parse(bitRate));
    Fluttertoast.showToast(msg: Languages.savedBitRate.getString(context));
    return null;
  }

  //SAMPLE RATE
  //STYLE
  Widget _sampleRateTitle(size, td) {
    return SizedBox(
      width: size.width*0.4,
      child: Align(
        alignment: Alignment.center,
        child: Text(
          "Sample Rate",
          style: TextStyle(color: td.colorScheme.onSurface, fontWeight: FontWeight.w500, fontSize: 18, shadows: [UiUtils.widgetsShadow(80, 20, td),]),
        ),
      ),
    );
  }

  Widget _sampleRateField(Size size) {
    return SizedBox(
      width: size.width*0.4,
      child: TextFieldCard(
          controller: _sampleRateController,
          hintText: recorder.defaultSampleRate.toString(),
          isEnabled: true,
          onChanged: (value) {
            _sampleRateController.text = value;
          },
          onTrailingIconPressed: () => _setSampleRate(_sampleRateController.text),
          trailingIcon: Icons.save_outlined,
      ),
    );
  }

  Widget _sampleRate(Size size, td) {
    return Column(
        children: [
          _sampleRateTitle(size, td),
          SizedBox(height: size.height*0.03,),
          _sampleRateField(size),
        ],
    );
  }

  //METHODS
  void _getSampleRate() async {
    _sampleRateController.text = (_prefs.getInt('sampleRate') ?? recorder.defaultSampleRate).toString();
  }

  VoidCallback? _setSampleRate(String sampleRate) {
    if(sampleRate=="") {
      setState(() {
        sampleRate = recorder.defaultSampleRate.toString();
      });
    }
    setState(() {
      _sampleRateController.text = sampleRate;
    });
    _prefs.setInt('sampleRate', int.parse(sampleRate));
    Fluttertoast.showToast(msg: Languages.savedSampleRate.getString(context));
    return null;
  }

  //SAMPLE + BIT RATE
  Widget _audioOptions(Size size, ThemeData td) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _sampleRate(size, td),
        SizedBox(width: size.width*0.06,),
        _bitRate(size, td),
      ],
    );
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

  //GENERAL
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
          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                _languageSection(size, td),
                SizedBox(height: size.height*0.05,),
                _audioOptions(size, td),
                SizedBox(height: size.height*0.05,),
                _waveSection(size, td),
                SizedBox(height: size.height*0.04,),
                _themeSection(size, td),
                SizedBox(height: size.height*0.05,),
              ],
            ),
          )
        ),
      ),
    );
  }
}

