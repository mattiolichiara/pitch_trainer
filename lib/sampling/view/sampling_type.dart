import 'package:flutter/material.dart';
import 'package:pitch_trainer/sampling/utils/frequencies.dart';
import 'package:pitch_trainer/sampling/view/sound_sampling.dart';
import 'package:pitch_trainer/sampling/widgets/instrument_card.dart';
import 'package:pitch_trainer/sampling/widgets/instrument_expansion_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../general/widgets/home_app_bar.dart';
import '../../general/widgets/ui_utils.dart';

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
    'Violin': 'assets/icons/violin-svgrepo-com.svg',
    'Ukulele': 'assets/icons/ukulele-svgrepo-com (1).svg',
    'Custom': 'assets/icons/sound-0-svgrepo-com.svg',
  };

  TextStyle textStyling(size, fontSize) {
    return TextStyle(
      color: Colors.white,
      fontSize: fontSize,
      shadows: const [
        BoxShadow(
          color: Color(0xFF9168B6),
          spreadRadius: 20,
          blurRadius: 80,
          offset: Offset(0, 1),
        )
      ],
    );
  }

  //WIDGETS
  Widget _wheelsLayout() {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text("Min", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, shadows: [BoxShadow(
          color: Color(0xFF9168B6),
          spreadRadius: 1,
          blurRadius: 20,
          offset: Offset(0, 1),
        )]),),
        Text("Max", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500, shadows: [BoxShadow(
          color: Color(0xFF9168B6),
          spreadRadius: 1,
          blurRadius: 20,
          offset: Offset(0, 1),
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
  List<Widget> _minFrequenciesList(size) {
    _frequenciesListMin = [];

    for (int i = 0; i < Frequencies.frequencies.length - 1; i++) {
      var entry = Frequencies.frequencies.entries.elementAt(i);
      _frequenciesListMin.add(
        Text(
          "${entry.key} (${entry.value})",
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            shadows: [
              BoxShadow(
                color: Color(0xFF9168B6),
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

  Widget _maxFrequenciesList(size, minFrequenciesList) {
    _frequenciesListMax = [];

    Color bgLerp = Color.lerp(const Color.fromARGB(255, 70, 70, 70), Colors.black, 0.30)!;

    for (int i = 1; i < Frequencies.frequencies.length; i++) {
      var entry = Frequencies.frequencies.entries.elementAt(i);

      if(entry.value > _selectedMin) {
        _frequenciesListMax.add(
          Text(
            "${entry.key} (${entry.value})",
            style: TextStyle(
              color: _minFrequency == 0.0 ? Colors.white38 : Colors.white70,
              fontSize: 12,
              shadows: const [
                BoxShadow(
                  color: Color(0xFF9168B6),
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
      color: bgLerp,
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

  Widget _cardList(size) {
    String selectedMinFrequency = Frequencies.frequencies.entries.firstWhere((entry) => entry.value == _minFrequency).key;
    String selectedMaxFrequency = Frequencies.frequencies.entries.firstWhere((entry) => entry.value == _maxFrequency).key;

    return Center(
      child: SizedBox(
        width: size.width * 0.85,
        height: size.height* 0.8,
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [
            InstrumentCard(
              text: "Piano - 88 Keys",
              subText: "A0 (27.50) - C8 (4186.01)",
              isActive: !(_minFrequency == 27.50 && _maxFrequency == 4186.01 && _isNotCustom),
              leadingIcon: _instrumentIcons["Piano"]!,
              onPressed: () {
                _saveFrequencyValues(27.50, 4186.01, true, _instrumentIcons["Piano"]);
              },
            ),
            SizedBox(height: size.height * 0.006),
            InstrumentCard(
              text: "Guitar - 6 Strings",
              subText: "E2 (82.41) - E4 (329.63)",
              isActive: !(_minFrequency == 82.41 && _maxFrequency == 329.63 && _isNotCustom),
              leadingIcon: _instrumentIcons["Guitar"]!,
              onPressed: () {
                _saveFrequencyValues(82.41, 329.63, true, _instrumentIcons["Guitar"]);
              },
            ),
            SizedBox(height: size.height * 0.006),
            InstrumentCard(
              text: "Bass Guitar",
              subText: "E1 (41.20) - G2 (98.00)",
              isActive: !(_minFrequency == 41.20 && _maxFrequency == 98.00 && _isNotCustom),
              leadingIcon: _instrumentIcons["Bass Guitar"]!,
              onPressed: () {
                _saveFrequencyValues(41.20, 98.00, true, _instrumentIcons["Bass Guitar"]);
              },
            ),
            SizedBox(height: size.height * 0.006),
            InstrumentCard(
              text: "Violin",
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
              subText: _isNotCustom ? "Select your frequency range" : "${selectedMinFrequency}($_minFrequency) - ${selectedMaxFrequency}($_maxFrequency)",
              text: "Custom",
              isActive: _isNotCustom,
              leadingIcon: _instrumentIcons["Custom"]!,
              isExpanded: _isExpanded,
              onTap: _onPressedCustomCard,
              canOpen: true,
              children: [
                _wheelsLayout(),
                _maxFrequenciesList(size, _minFrequenciesList(size)),
              ],
            )
          ],
        ),
      ),
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
    _isExpanded = false;
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

  //BUILD
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return PopScope(
      canPop: false,
      onPopInvoked: (pop) async {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
            builder: (context) => const SoundSampling()),
                (Route<dynamic> route) => false);
      },
      child: Scaffold(
        appBar: HomeAppBar(
          title: 'Pitch Trainer - Options',
          action1: Container(),
          action2: Container(),
          action3: Container(),
        ),
        body: Column(
          children: [
            SizedBox(
              height: size.height*0.02,
            ),
            SizedBox(
              width: size.width*0.85,
              child: const Text("To avoid for unwanted frequencies to be detected, select an instrument and if needed, add a custom frequency range.",
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 12,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(
              height: size.height*0.02,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: _isLoading ? UiUtils.loadingStyle() : _cardList(size),
            )
          ],
        ),
      ),
    );
  }
}
