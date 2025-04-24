mixin Languages {
  static const Map<String, String> langsMap = {"en": "English", "it": "Italiano"};

  static const String selectTheme = "selectTheme";
  static const String languages = "languages";
  static const String samplingTypeSubtitle = "samplingTypeSubtitle";
  static const String options = "options";
  static const String permissionsWarning = "permissionsWarning";
  static const String piano = "piano";
  static const String guitar = "guitar";
  static const String bass = "bass";
  static const String violin = "violin";
  static const String custom = "custom";
  static const String customText = "customText";
  static const String settings = "settings";
  static const String exitToast = "exitToast";
  static const String savedSampleRate = "savedSampleRate";
  static const String savedBitRate = "savedBitRate";
  static const String rawWave = "rawWave";
  static const String polishedWave = "naturalWave";
  static const String accuracyThreshold = "accuracyThreshold";

  static const Map<String, dynamic> EN = {
    selectTheme: "Themes",
    languages: "Language",
    samplingTypeSubtitle: "To avoid for unwanted frequencies to be detected, select an instrument and if needed, add a custom frequency range.",
    options: "Options",
    permissionsWarning: "Allow Microphone Access To Use The App",
    piano : "Piano - 88 Keys",
    guitar : "Guitar - 6 Strings",
    bass : "Bass",
    violin : "Violin",
    custom : "Custom",
    customText: "Select your frequency range",
    settings: "Settings",
    exitToast: "Double Tap to Exit",
    savedSampleRate: "Sample Rate Saved",
    savedBitRate: "Bit Rate Saved",
    rawWave: "Raw",
    polishedWave: "Polished",
    accuracyThreshold: "Accuracy Threshold",//TODO
  };

  static const Map<String, dynamic> IT = {
    selectTheme: "Temi",
    languages: "Lingua",
    samplingTypeSubtitle: "Per evitare che vengano rilevate frequenze indesiderate, puo' essere selezionato uno strumento, se necessario puo' essere aggiunto un range di frequenze personalizzato.",
    options: "Opzioni",
    permissionsWarning: "E' Necessario Attivare i Permessi del Microfono",
    piano : "Pianoforte - 88 Tasti",
    guitar : "Chitarra - 6 Corde",
    bass : "Basso",
    violin : "Violino",
    custom : "Personalizzato",
    customText: "Seleziona un range di frequenze",
    settings: "Impostazioni",
    exitToast: "Tocca due volte per uscire",
    savedSampleRate: "Sample Rate Aggiornato",
    savedBitRate: "Bit Rate Aggiornato",
    rawWave: "Naturale",
    polishedWave: "Elaborata",
    accuracyThreshold: "Soglia di Precisione",
  };
}
