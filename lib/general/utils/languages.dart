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

  static const Map<String, dynamic> EN = {
    selectTheme: "Select Theme",
    languages: "Select Language",
    samplingTypeSubtitle: "To avoid for unwanted frequencies to be detected, select an instrument and if needed, add a custom frequency range.",
    options: "Options",
    permissionsWarning: "Allow Microphone Access To Use The App",
    piano : "Piano",
    guitar : "Guitar",
    bass : "Bass",
    violin : "Violin",
    custom : "Custom",
    customText: "Select your frequency range",
    settings: "Settings",
    exitToast: "Double Tap to Exit",
  };

  static const Map<String, dynamic> IT = {
    selectTheme: "Temi",
    languages: "Lingua",
    samplingTypeSubtitle: "Per evitare che vengano rilevate frequenze indesiderate, puo' essere selezionato uno strumento, se necessario puo' essere aggiunto un range di frequenze personalizzato.",
    options: "Opzioni",
    permissionsWarning: "E' Necessario Attivare i Permessi del Microfono",
    piano : "Pianoforte",
    guitar : "Chitarra",
    bass : "Basso",
    violin : "Violino",
    custom : "Personalizzato",
    customText: "Seleziona un range di frequenze",
    settings: "Impostazioni",
    exitToast: "Tocca due volte per uscire",
  };
}
