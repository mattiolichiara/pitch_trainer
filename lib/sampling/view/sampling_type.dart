import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:pitch_trainer/sampling/view/sound_sampling.dart';
import 'package:pitch_trainer/sampling/widgets/instrument_card.dart';
import 'package:pitch_trainer/sampling/widgets/instrument_expansion_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../general/utils/languages.dart';
import '../../general/widgets/home_app_bar.dart';
import '../../general/widgets/ui_utils.dart';
import '../utils/frequencies.dart';

class SamplingType extends StatefulWidget {
  const SamplingType({super.key,});

  @override
  State<SamplingType> createState() => _SamplingType();
}

class _SamplingType extends State<SamplingType> {
  double _minFrequency = 0.0;
  double _maxFrequency = 0.0;
  bool _isNotCustom = true;
  double _selectedMin = 0.0;
  double _selectedMax = 0.0;
  String _selectedInstrument = "";
  bool _isExpanded = false;
  int? _minIndex;
  bool _isLoading = true;
  List<Widget> _frequenciesListMin = [];
  List<Widget> _frequenciesListMax = [];

  @override
  void initState() {
    _loadPreferences().then((_){});

    super.initState();
  }

  //STYLING
  final Map<String, String> _instrumentIcons = {
    'Piano': 'assets/icons/piano-instrument-keyboard-svgrepo-com.svg',
    'Guitar': 'assets/icons/guitar-svgrepo-com.svg',
    'Bass Guitar': 'assets/icons/bass-svgrepo-com.svg',
    //'Bass Guitar': 'bass-guitar-svgrepo-com.svg',
    'Violin': 'assets/icons/violin-svgrepo-com.svg',
    'Ukulele': 'assets/icons/ukulele-svgrepo-com (1).svg',
    'Custom': 'assets/icons/sound-0-svgrepo-com.svg',
  };

  TextStyle textStyling(size, fontSize, td) {
    return TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      shadows: [
        BoxShadow(
          color: td.colorScheme.primary,
          spreadRadius: 20,
          blurRadius: 80,
          offset: Offset(0, 1),
        )
      ],
    );
  }

  //WIDGETS
  Widget _wheelsLayout(td) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("Min", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, shadows: [BoxShadow(
          color: td.colorScheme.primary,
          spreadRadius: 1,
          blurRadius: 20,
          offset: const Offset(0, 1),
        )]),),
        Text("Max", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, shadows: [BoxShadow(
          color: td.colorScheme.primary,
          spreadRadius: 1,
          blurRadius: 20,
          offset: const Offset(0, 1),
        )]),),
      ],
    );
  }

  Widget _leftWheel(size, minFrequenciesList) {
    return SizedBox(
        height: size.height*0.15,
        width: size.width*0.4,
        child: ListWheelScrollView(
          itemExtent: 15,
          useMagnifier: true,
          magnification: 1.3,
          children: minFrequenciesList,
          onSelectedItemChanged: (index) {
            setState(() {
              _selectedMin = Frequencies.frequencies.values.toList()[index];
              _selectedMax = Frequencies.frequencies.values.toList()[index+1];
              _selectedInstrument = _instrumentIcons["Custom"]!;
              _saveFrequencyValues(_selectedMin, _selectedMax, false, _instrumentIcons["Custom"]!);
              _minIndex = index;
            });
          },
        )
    );
  }

  Widget _rightWheel(size) {
    return SizedBox(
      height: size.height*0.15,
      width: size.width*0.4,
      child: ListWheelScrollView(
        itemExtent: 15,
        useMagnifier: true,
        magnification: 1.3,
        physics: _selectedMin == 0.0 ? const NeverScrollableScrollPhysics() : null,
        children: _frequenciesListMax,
        onSelectedItemChanged: (index) {
          //if(selectedMin != 0.0) {
          List<double> frequencyList = Frequencies.frequencies.values.toList().sublist(_minIndex!+1, Frequencies.frequencies.length);

          setState(() {
            _selectedMax = frequencyList[index];
          });
          //if(selectedMax > selectedMin) {
          _saveFrequencyValues(_selectedMin, _selectedMax, false, _instrumentIcons["Custom"]!);
          //}
          //}
        },
      ),
    );
  }

  //FUNCTIONAL WIDGETS
  List<Widget> _minFrequenciesList(size, td) {
    _frequenciesListMin = [];

    for (int i = 0; i < Frequencies.frequencies.length - 1; i++) {
      var entry = Frequencies.frequencies.entries.elementAt(i);
      _frequenciesListMin.add(
        Text(
          "${entry.key} (${entry.value})",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            shadows: [
              BoxShadow(
                color: td.colorScheme.primary,
                spreadRadius: 1,
                blurRadius: 20,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      );
    }

    return _frequenciesListMin;
  }

  Widget _maxFrequenciesList(size, minFrequenciesList, td) {
    _frequenciesListMax = [];

    for (int i = 1; i < Frequencies.frequencies.length; i++) {
      var entry = Frequencies.frequencies.entries.elementAt(i);

      if(entry.value > _selectedMin) {
        _frequenciesListMax.add(
          Text(
            "${entry.key} (${entry.value})",
            style: TextStyle(
              color: _minFrequency == 0.0 ? Colors.white38 : Colors.white70,
              fontSize: 12,
              shadows: [
                BoxShadow(
                  color: td.colorScheme.primary,
                  spreadRadius: 1,
                  blurRadius: 20,
                  offset: Offset(0, 1),
                ),
              ],
            ),
          ),
        );
      }
    }

    return Container(
      color: td.colorScheme.onPrimaryContainer,
      width: size.width * 0.85,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _leftWheel(size, minFrequenciesList),
          _rightWheel(size),
        ],
      ),
    );
  }

  Widget _cardList(size, td) {
    String selectedMinFrequency = Frequencies.frequencies.entries.firstWhere((entry) => entry.value == _minFrequency).key;
    String selectedMaxFrequency = Frequencies.frequencies.entries.firstWhere((entry) => entry.value == _maxFrequency).key;

    return Center(
      child: SizedBox(
        width: size.width * 0.85,
        height: size.height,
        child: ListView(
          shrinkWrap: true,
          physics: AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          children: [
            InstrumentCard(
              text: Languages.piano.getString(context),
              subText: "A0 (27.50) - C8 (4186.01)",
              isActive: !(_minFrequency == 27.50 && _maxFrequency == 4186.01 && _isNotCustom),
              leadingIcon: _instrumentIcons["Piano"]!,
              onPressed: () {
                _saveFrequencyValues(27.50, 4186.01, true, _instrumentIcons["Piano"]);
              },
            ),
            SizedBox(height: size.height * 0.006),
            InstrumentCard(
              text: "${Languages.guitar.getString(context)}",
              subText: "E2 (82.41) - E4 (329.63)",
              isActive: !(_minFrequency == 82.41 && _maxFrequency == 329.63 && _isNotCustom),
              leadingIcon: _instrumentIcons["Guitar"]!,
              onPressed: () {
                _saveFrequencyValues(82.41, 329.63, true, _instrumentIcons["Guitar"]);
              },
            ),
            SizedBox(height: size.height * 0.006),
            InstrumentCard(
              text: Languages.bass.getString(context),
              subText: "E1 (41.20) - G2 (98.00)",
              isActive: !(_minFrequency == 41.20 && _maxFrequency == 98.00 && _isNotCustom),
              leadingIcon: _instrumentIcons["Bass Guitar"]!,
              onPressed: () {
                _saveFrequencyValues(41.20, 98.00, true, _instrumentIcons["Bass Guitar"]);
              },
            ),
            SizedBox(height: size.height * 0.006),
            InstrumentCard(
              text: Languages.violin.getString(context),
              subText: "G3 (196.00) - E7 (2637.02)",
              isActive: !(_minFrequency == 196.00 && _maxFrequency == 2637.02 && _isNotCustom),
              leadingIcon: _instrumentIcons["Violin"]!,
              onPressed: () {
                _saveFrequencyValues(196.00, 2637.02, true, _instrumentIcons["Violin"]);
              },
            ),
            SizedBox(height: size.height * 0.006),
            InstrumentCard(
              text: "Ukulele",
              subText: "G4 (392.00) - A6 (1760.00)",
              isActive: !(_minFrequency == 392.00 && _maxFrequency == 1760.00 && _isNotCustom),
              leadingIcon: _instrumentIcons["Ukulele"]!,
              onPressed: () {
                _saveFrequencyValues(392.00, 1760.00, true, _instrumentIcons["Ukulele"]);
              },
            ),
            SizedBox(height: size.height * 0.006),
            InstrumentExpansionTile(
              subText: _isNotCustom ? Languages.customText.getString(context) : "$selectedMinFrequency($_minFrequency) - $selectedMaxFrequency($_maxFrequency)",
              text: Languages.custom.getString(context),
              isActive: _isNotCustom,
              leadingIcon: _instrumentIcons["Custom"]!,
              isExpanded: _isExpanded,
              onTap: _onPressedCustomCard,
              canOpen: true,
              children: [
                _wheelsLayout(td),
                _maxFrequenciesList(size, _minFrequenciesList(size, td), td),
              ],
            )
          ],
        ),
      ),
    );
  }

  //SCAFFOLD
  Widget _scaffoldContent(size, td) {
    return Column(
      children: [
        SizedBox(
          height: size.height*0.02,
        ),
        SizedBox(
          width: size.width*0.85,
          child: Text(Languages.samplingTypeSubtitle.getString(context),
            style: const TextStyle(
              fontWeight: FontWeight.w300,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(
          height: size.height*0.02,
        ),
        _isLoading ? UiUtils.loadingStyle(td) :
        Expanded(flex: 1, child: _cardList(size, td)),
      ],
    );
  }

  //METHODS
  Future<void> _loadPreferences() async {
    await _loadFrequencyValues();
    //debugPrint("Min: $_minFrequency - Max: $_maxFrequency");

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadFrequencyValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _minFrequency = prefs.getDouble('minFrequency') ?? 27.50;
      _maxFrequency = prefs.getDouble('maxFrequency') ?? 4186.01;
      _isNotCustom = prefs.getBool('isNotCustom') ?? true;
      _selectedInstrument = prefs.getString('instrumentIcon') ?? 'assets/icons/piano-instrument-keyboard-svgrepo-com.svg';
    });
  }

  Future<void> _saveFrequencyValues(min, max, notCustom, selectedInstrument) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('minFrequency', min);
    prefs.setDouble('maxFrequency', max);
    prefs.setBool('isNotCustom', notCustom);
    prefs.setString('instrumentIcon', selectedInstrument);

    setState(() {
      _minFrequency = min;
      _maxFrequency = max;
      _isNotCustom = notCustom;
      _selectedInstrument = selectedInstrument;
      if(_isNotCustom) {
        _resetWheels();
      }
    });
  }

  void _resetWheels() {
    _selectedMin = 0.0;
    _selectedMax = 0.0;
    _minIndex = null;
    _onTapOutOfFocus();
    _frequenciesListMin = [];
    _frequenciesListMax = [];
  }

  void _onPressedCustomCard() {
    setState(() {
      _isExpanded = !_isExpanded;
      debugPrint("expanded $_isExpanded");
      if (_isExpanded == false) {
        setState(() {
          _frequenciesListMin = [];
          _frequenciesListMax = [];
        });
      }
    });
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
      canPop: false,
      onPopInvoked: (pop) async {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) => const SoundSampling()),
                (Route<dynamic> route) => false);
      },
      child: Scaffold(
        appBar: HomeAppBar(
          title: 'Pitch Trainer - ${Languages.options.getString(context)}',
          action1: Container(),
          action2: Container(),
          action3: Container(),
        ),
        body: _scaffoldContent(size, td),
      ),
    );
  }
}
