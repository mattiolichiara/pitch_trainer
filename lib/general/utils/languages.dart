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
  static const String bufferSize = "bufferSize";
  static const String sampleRate = "sampleRate";
  static const String advancedSettings = "advancedSettings";
  static const String advancedSettingsSubText = "advancedSettingsSubText";
  static const String resetSettings = "resetSettings";
  static const String resetSettingsSubText = "resetSettingsSubText";
  static const String settingsResetToast = "settingsResetToast";
  static const String other = "other";
  static const String precision = "precision";
  static const String tolerance = "tolerance";
  static const String resetWarning = "resetWarning";
  static const String resetWarningSubText = "resetWarningSubText";
  static const String sampleRateWarning = "sampleRateWarning";
  static const String sampleRateWarningSubText = "sampleRateWarningSubText";
  static const String yes = "yes";
  static const String no = "no";
  static const String resetOnSilence = "resetOnSilence";
  static const String dynamicSilence = "dynamic";
  static const String staticSilence = "static";

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
    bufferSize: "Buffer Size",
    sampleRate: "Sample Rate",
    advancedSettings: "Advanced Settings",
    advancedSettingsSubText: "Modify Configuration Settings",
    resetSettings: "Reset Settings",
    resetSettingsSubText: "Reset Settings to Default Values",
    settingsResetToast: "Default Settings Restored",
    other: "Other",
    precision: "Precision",
    tolerance: "Tolerance",
    resetWarning: "Reset Settings?",
    resetWarningSubText: "This action will reset all settings to their default values.",
    sampleRateWarning: "Low Sample Rate Selected",
    sampleRateWarningSubText: "22.05 kHz may not accurately capture higher frequencies.",
    yes: "Yes",
    no: "No",
    resetOnSilence: "Reset On Silence",
    dynamicSilence: "Dynamic",
    staticSilence: "Static",
  };

  static const Map<String, dynamic> IT = {
    selectTheme: "Temi",
    languages: "Lingua",
    samplingTypeSubtitle: "Per evitare che vengano rilevate frequenze indesiderate, puo' essere selezionato uno strumento, se necessario puo' essere aggiunto un range di frequenze personalizzato.",
    options: "Opzioni",
    permissionsWarning: "Attivare i Permessi del Microfono",
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
    bufferSize: "Dimensione Buffer",
    sampleRate: "Frequenza di Campionamento",
    advancedSettings: "Impostazioni Avanzate",
    advancedSettingsSubText: "Modifiche di Configurazione",
    resetSettings: "Reset Impostazioni",
    resetSettingsSubText: "Reimposta le Impostazioni ai Valori di Default",
    settingsResetToast: "Impostazioni Ripristinate",
    other: "Altro",
    precision: "Precisione",
    tolerance: "Tolleranza",
    resetWarning: "Ripristinare le impostazioni?",
    resetWarningSubText: "Questa azione ripristinerà tutte le impostazioni ai valori predefiniti.",
    sampleRateWarning: "Campionamento basso selezionato",
    sampleRateWarningSubText: "22,05 kHz potrebbe non catturare accuratamente le frequenze più alte.",
    yes: "Si",
    no: "No",
    resetOnSilence: "Azzera Al silenzio",
    dynamicSilence: "Dinamico",
    staticSilence: "Statico",
  };
}
