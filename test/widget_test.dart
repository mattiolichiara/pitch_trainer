import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pitch_trainer/app.dart';
import 'package:pitch_trainer/general/utils/languages.dart';
import 'package:pitch_trainer/general/utils/theme_cubit.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    WidgetsFlutterBinding.ensureInitialized();

    final themeCubit = ThemeCubit();
    await themeCubit.loadTheme();

    final FlutterLocalization localization = FlutterLocalization.instance;
    localization.init(
      mapLocales: [
        const MapLocale('en', Languages.EN),
        const MapLocale('it', Languages.IT),
      ],
      initLanguageCode: 'en',
    );

    await tester.pumpWidget(MyApp(themeCubit: themeCubit, localization: localization));

    expect(find.text('Select Theme'), findsOneWidget);

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
